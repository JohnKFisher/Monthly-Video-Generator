import Foundation

struct FFmpegProgressiveBatchPlan: Equatable, Sendable {
    let sequenceIndex: Int
    let sourceClipIndices: [Int]
    let plan: FFmpegRenderPlan
}

struct FFmpegHDRProgressiveExecutionPlan: Equatable, Sendable {
    let activationChunkPlan: FFmpegHDRChunkPlan
    let presentationPlans: [FFmpegRenderPlan]
    let slices: [FFmpegAssemblySlice]
    let batchPlans: [FFmpegProgressiveBatchPlan]
    let lastBatchIndexBySourceClip: [Int: Int]
    let concatListURL: URL
    let concatOutputURL: URL
}

struct FFmpegHDRProgressivePipelineBuilder {
    private let epsilon = 0.000_1

    let activationPlanner: FFmpegHDRChunkPlanner
    let maxUniqueSourceClipsPerBatch: Int
    let maxBatchDurationSeconds: Double

    init(
        activationPlanner: FFmpegHDRChunkPlanner = FFmpegHDRChunkPlanner(),
        maxUniqueSourceClipsPerBatch: Int = 12,
        maxBatchDurationSeconds: Double = 90
    ) {
        self.activationPlanner = activationPlanner
        self.maxUniqueSourceClipsPerBatch = max(maxUniqueSourceClipsPerBatch, 1)
        self.maxBatchDurationSeconds = max(maxBatchDurationSeconds, 0.01)
    }

    func makeExecutionPlan(
        for finalPlan: FFmpegRenderPlan,
        presentationOutputURL: (Int) -> URL,
        batchOutputURL: (Int) -> URL,
        concatListURL: () -> URL,
        concatOutputURL: () -> URL,
        forceProgressive: Bool = false
    ) -> FFmpegHDRProgressiveExecutionPlan? {
        guard finalPlan.dynamicRange == .hdr,
              finalPlan.videoCodec == .hevc,
              finalPlan.renderIntent == .finalDelivery else {
            return nil
        }

        let activationChunkPlan = activationPlanner.plan(for: finalPlan)
        guard forceProgressive || activationChunkPlan.requiresChunking || finalPlan.executionFPSBakeoffVariant == .mixedCadenceVFR else {
            return nil
        }
        let cadenceVariant = finalPlan.executionFPSBakeoffVariant

        let presentationPlans = finalPlan.clips.enumerated().map { index, clip in
            let presentationFrameRate = preferredPresentationFrameRate(
                for: clip,
                fallbackFrameRate: finalPlan.frameRate,
                variant: cadenceVariant
            )
            return FFmpegRenderPlan(
                clips: [clip],
                transitionDurationSeconds: 0,
                endFadeToBlackDurationSeconds: 0,
                outputURL: presentationOutputURL(index),
                renderSize: finalPlan.renderSize,
                frameRate: presentationFrameRate,
                audioLayout: finalPlan.audioLayout,
                bitrateMode: finalPlan.bitrateMode,
                container: .mov,
                videoCodec: .hevc,
                dynamicRange: .hdr,
                hdrHEVCEncoderMode: finalPlan.hdrHEVCEncoderMode,
                x265ThreadProfile: finalPlan.x265ThreadProfile,
                embeddedMetadata: nil,
                chapters: [],
                chapterMetadataURL: nil,
                renderIntent: .presentationIntermediate,
                executionFPSBakeoffVariant: cadenceVariant
            )
        }

        let presentationClips = finalPlan.clips.enumerated().map { index, clip in
            FFmpegRenderClip(
                url: presentationPlans[index].outputURL,
                durationSeconds: clip.durationSeconds,
                includeAudio: true,
                hasAudioTrack: true,
                colorInfo: .hlgBT2020Intermediate,
                sourceDescription: clip.sourceDescription,
                sourceFrameRate: clip.sourceFrameRate,
                preferredFrameRate: presentationPlans[index].frameRate,
                auditInfo: clip.auditInfo
            )
        }

        let slices = makeAssemblySlices(
            clips: presentationClips,
            transitionDurationSeconds: finalPlan.transitionDurationSeconds,
            fallbackFrameRate: finalPlan.frameRate,
            variant: cadenceVariant
        )
        guard !slices.isEmpty else {
            return nil
        }

        let batchPlans = makeBatchPlans(
            slices: slices,
            presentationClips: presentationClips,
            finalPlan: finalPlan,
            batchOutputURL: batchOutputURL
        )
        guard !batchPlans.isEmpty else {
            return nil
        }

        var lastBatchIndexBySourceClip: [Int: Int] = [:]
        for batch in batchPlans {
            for sourceClipIndex in batch.sourceClipIndices {
                lastBatchIndexBySourceClip[sourceClipIndex] = batch.sequenceIndex
            }
        }

        return FFmpegHDRProgressiveExecutionPlan(
            activationChunkPlan: activationChunkPlan,
            presentationPlans: presentationPlans,
            slices: slices,
            batchPlans: batchPlans,
            lastBatchIndexBySourceClip: lastBatchIndexBySourceClip,
            concatListURL: concatListURL(),
            concatOutputURL: concatOutputURL()
        )
    }

    func requiresProgressiveExecution(for finalPlan: FFmpegRenderPlan) -> Bool {
        guard finalPlan.dynamicRange == .hdr,
              finalPlan.videoCodec == .hevc,
              finalPlan.renderIntent == .finalDelivery else {
            return false
        }
        return activationPlanner.plan(for: finalPlan).requiresChunking
    }

    private func makeAssemblySlices(
        clips: [FFmpegRenderClip],
        transitionDurationSeconds: Double,
        fallbackFrameRate: Int,
        variant: FPSBakeoffVariant?
    ) -> [FFmpegAssemblySlice] {
        guard !clips.isEmpty else {
            return []
        }

        let transition = max(transitionDurationSeconds, 0)
        var slices: [FFmpegAssemblySlice] = []
        var nextSequenceIndex = 0

        for index in clips.indices {
            let clip = clips[index]
            let incomingTransition = index == 0 ? 0 : transition
            let outgoingTransition = index == clips.count - 1 ? 0 : transition
            let bodyStart = min(max(incomingTransition, 0), clip.durationSeconds)
            let bodyDuration = max(clip.durationSeconds - incomingTransition - outgoingTransition, 0)
            if bodyDuration > epsilon {
                slices.append(
                    FFmpegAssemblySlice(
                        sequenceIndex: nextSequenceIndex,
                        kind: .body,
                        segments: [
                            FFmpegAssemblySegment(
                                clipIndex: index,
                                startTimeSeconds: bodyStart,
                                durationSeconds: bodyDuration
                            )
                        ],
                        outputDurationSeconds: bodyDuration,
                        preferredFrameRate: preferredBodyFrameRateOverride(
                            for: clip,
                            fallbackFrameRate: fallbackFrameRate,
                            variant: variant
                        )
                    )
                )
                nextSequenceIndex += 1
            }

            if index < clips.count - 1, transition > epsilon {
                let nextClip = clips[index + 1]
                let leftStart = max(clip.durationSeconds - transition, 0)
                let leftDuration = min(transition, max(clip.durationSeconds - leftStart, 0))
                let rightDuration = min(transition, nextClip.durationSeconds)
                let bridgeDuration = min(leftDuration, rightDuration)
                if bridgeDuration > epsilon {
                    slices.append(
                        FFmpegAssemblySlice(
                            sequenceIndex: nextSequenceIndex,
                            kind: .bridge,
                            segments: [
                                FFmpegAssemblySegment(
                                    clipIndex: index,
                                    startTimeSeconds: leftStart,
                                    durationSeconds: bridgeDuration
                                ),
                                FFmpegAssemblySegment(
                                    clipIndex: index + 1,
                                    startTimeSeconds: 0,
                                    durationSeconds: bridgeDuration
                                )
                            ],
                            outputDurationSeconds: bridgeDuration,
                            preferredFrameRate: preferredBridgeFrameRateOverride(
                                left: clip,
                                right: nextClip,
                                fallbackFrameRate: fallbackFrameRate,
                                variant: variant
                            )
                        )
                    )
                    nextSequenceIndex += 1
                }
            }
        }

        return slices
    }

    private func makeBatchPlans(
        slices: [FFmpegAssemblySlice],
        presentationClips: [FFmpegRenderClip],
        finalPlan: FFmpegRenderPlan,
        batchOutputURL: (Int) -> URL
    ) -> [FFmpegProgressiveBatchPlan] {
        guard !slices.isEmpty else {
            return []
        }

        var groupedSlices: [[FFmpegAssemblySlice]] = []
        var workingSlices: [FFmpegAssemblySlice] = []
        var workingClipIndices: Set<Int> = []
        var workingDuration = 0.0

        func flushWorkingSlices() {
            guard !workingSlices.isEmpty else {
                return
            }
            groupedSlices.append(workingSlices)
            workingSlices = []
            workingClipIndices.removeAll(keepingCapacity: false)
            workingDuration = 0
        }

        for slice in slices {
            let sliceClipIndices = Set(slice.sourceClipIndices)
            let proposedClipIndices = workingClipIndices.union(sliceClipIndices)
            let proposedDuration = workingDuration + slice.outputDurationSeconds
            let exceedsBatchBounds = !workingSlices.isEmpty && (
                proposedClipIndices.count > maxUniqueSourceClipsPerBatch ||
                proposedDuration > maxBatchDurationSeconds
            )

            if exceedsBatchBounds {
                flushWorkingSlices()
            }

            workingSlices.append(slice)
            workingClipIndices.formUnion(sliceClipIndices)
            workingDuration += slice.outputDurationSeconds
        }
        flushWorkingSlices()

        return groupedSlices.enumerated().map { batchIndex, batchSlices in
            let orderedOriginalClipIndices = orderedSourceClipIndices(for: batchSlices)
            let localClipIndexByOriginal = Dictionary(
                uniqueKeysWithValues: orderedOriginalClipIndices.enumerated().map { localIndex, originalIndex in
                    (originalIndex, localIndex)
                }
            )
            let localClips = orderedOriginalClipIndices.map { presentationClips[$0] }
            let localSlices = batchSlices.map { slice in
                FFmpegAssemblySlice(
                    sequenceIndex: slice.sequenceIndex,
                    kind: slice.kind,
                    segments: slice.segments.map { segment in
                        FFmpegAssemblySegment(
                            clipIndex: localClipIndexByOriginal[segment.clipIndex] ?? 0,
                            startTimeSeconds: segment.startTimeSeconds,
                            durationSeconds: segment.durationSeconds
                        )
                    },
                    outputDurationSeconds: slice.outputDurationSeconds,
                    preferredFrameRate: slice.preferredFrameRate
                )
            }

            return FFmpegProgressiveBatchPlan(
                sequenceIndex: batchIndex,
                sourceClipIndices: orderedOriginalClipIndices,
                plan: FFmpegRenderPlan(
                    clips: localClips,
                    assemblySlices: localSlices,
                    transitionDurationSeconds: 0,
                    endFadeToBlackDurationSeconds: batchIndex == groupedSlices.count - 1
                        ? finalPlan.endFadeToBlackDurationSeconds
                        : 0,
                    outputURL: batchOutputURL(batchIndex),
                    renderSize: finalPlan.renderSize,
                    frameRate: finalPlan.frameRate,
                    audioLayout: finalPlan.audioLayout,
                    bitrateMode: finalPlan.bitrateMode,
                    container: .mov,
                    videoCodec: .hevc,
                    dynamicRange: .hdr,
                    hdrHEVCEncoderMode: finalPlan.hdrHEVCEncoderMode,
                    x265ThreadProfile: finalPlan.x265ThreadProfile,
                    embeddedMetadata: nil,
                    chapters: [],
                    chapterMetadataURL: nil,
                    renderIntent: .finalBatch,
                    executionFPSBakeoffVariant: finalPlan.executionFPSBakeoffVariant
                )
            )
        }
    }

    private func orderedSourceClipIndices(for slices: [FFmpegAssemblySlice]) -> [Int] {
        var orderedIndices: [Int] = []
        var seen: Set<Int> = []
        for slice in slices {
            for sourceClipIndex in slice.sourceClipIndices where seen.insert(sourceClipIndex).inserted {
                orderedIndices.append(sourceClipIndex)
            }
        }
        return orderedIndices
    }

    private func preferredPresentationFrameRate(
        for clip: FFmpegRenderClip,
        fallbackFrameRate: Int,
        variant: FPSBakeoffVariant?
    ) -> Int {
        switch variant {
        case .mixedCadenceVFR:
            return preferredBodyFrameRate(for: clip, fallbackFrameRate: fallbackFrameRate, variant: variant)
        case .stillAwareCFR:
            if clip.auditInfo.kind == .still || clip.auditInfo.kind == .title {
                return 5
            }
            return fallbackFrameRate
        case .currentCFR, nil:
            return fallbackFrameRate
        }
    }

    private func preferredBodyFrameRate(
        for clip: FFmpegRenderClip,
        fallbackFrameRate: Int,
        variant: FPSBakeoffVariant?
    ) -> Int {
        switch variant {
        case .mixedCadenceVFR:
            switch clip.auditInfo.kind {
            case .still:
                return 5
            case .title:
                return 30
            case .video:
                return standardFrameRateBucket(for: clip.sourceFrameRate, fallback: fallbackFrameRate)
            }
        case .stillAwareCFR, .currentCFR, nil:
            return fallbackFrameRate
        }
    }

    private func preferredBodyFrameRateOverride(
        for clip: FFmpegRenderClip,
        fallbackFrameRate: Int,
        variant: FPSBakeoffVariant?
    ) -> Int? {
        guard variant != nil else {
            return nil
        }
        return preferredBodyFrameRate(for: clip, fallbackFrameRate: fallbackFrameRate, variant: variant)
    }

    private func preferredBridgeFrameRateOverride(
        left: FFmpegRenderClip,
        right: FFmpegRenderClip,
        fallbackFrameRate: Int,
        variant: FPSBakeoffVariant?
    ) -> Int? {
        guard variant != nil else {
            return nil
        }
        guard variant == .mixedCadenceVFR else {
            return fallbackFrameRate
        }
        guard left.auditInfo.kind == .video, right.auditInfo.kind == .video else {
            return 30
        }
        return max(
            standardFrameRateBucket(for: left.sourceFrameRate, fallback: fallbackFrameRate),
            standardFrameRateBucket(for: right.sourceFrameRate, fallback: fallbackFrameRate)
        )
    }

    private func standardFrameRateBucket(for sourceFrameRate: Double?, fallback: Int) -> Int {
        guard let sourceFrameRate, sourceFrameRate.isFinite, sourceFrameRate > 0 else {
            return fallback
        }
        let buckets = [24, 25, 30, 50, 60]
        return buckets.min { lhs, rhs in
            abs(Double(lhs) - sourceFrameRate) < abs(Double(rhs) - sourceFrameRate)
        } ?? fallback
    }
}

extension ColorInfo {
    static let hlgBT2020Intermediate = ColorInfo(
        isHDR: true,
        colorPrimaries: "ITU_R_2020",
        transferFunction: "ITU_R_2100_HLG"
    )
}
