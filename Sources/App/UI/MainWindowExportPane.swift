import Core
import SwiftUI

struct MainWindowExportPane: View {
    @ObservedObject var viewModel: MainWindowViewModel

    @SceneStorage("MainWindowExportPane.isFilenameEditorExpanded")
    private var isFilenameEditorExpanded = false

    @SceneStorage("MainWindowExportPane.isDescriptionEditorExpanded")
    private var isDescriptionEditorExpanded = false

    private let rowSpacing: CGFloat = 6

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: rowSpacing) {
                libraryMetadataSection

                Divider()

                saveLocationSection

                descriptionEditor

                if viewModel.showsManualMonthYearOverride {
                    Divider()
                    manualMonthYearOverrideSection
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } label: {
            MainWindowSectionLabel(title: "Video Details", accent: MainWindowTheme.accentNavy)
        }
    }

    private var libraryMetadataSection: some View {
        VStack(alignment: .leading, spacing: rowSpacing) {
            Text("Library Metadata")
                .font(.subheadline.weight(.medium))

            Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: rowSpacing) {
                GridRow {
                    Text("Series")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 88, alignment: .leading)
                    TextField("Series Title", text: $viewModel.plexShowTitle)
                }
            }

            MainWindowCaption(text: "Used for Plex metadata and the automatic filename.")
            metadataStatusRow
        }
    }

    private var metadataStatusRow: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 8) {
                statusChip(viewModel.isOutputNameAutoManaged ? "Auto name" : "Custom name")
                statusChip(viewModel.isPlexDescriptionAutoManaged ? "Auto description" : "Custom description")
                statusChip(viewModel.showsManualMonthYearOverride ? "Manual month/year" : "Month/year from media")
            }

            VStack(alignment: .leading, spacing: 6) {
                statusChip(viewModel.isOutputNameAutoManaged ? "Auto name" : "Custom name")
                statusChip(viewModel.isPlexDescriptionAutoManaged ? "Auto description" : "Custom description")
                statusChip(viewModel.showsManualMonthYearOverride ? "Manual month/year" : "Month/year from media")
            }
        }
    }

    private func statusChip(_ text: String) -> some View {
        Text(text)
            .font(.caption.weight(.medium))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(.secondary.opacity(0.10), in: Capsule())
    }

    private var saveLocationSection: some View {
        VStack(alignment: .leading, spacing: rowSpacing) {
            Text("Save Location")
                .font(.subheadline.weight(.medium))

            Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: rowSpacing) {
                GridRow {
                    Text("Final file")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 88, alignment: .leading)

                    Text(viewModel.currentRenderResolvedOutputFilenamePreview)
                        .font(.callout.weight(.semibold))
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .textSelection(.enabled)
                }

                GridRow {
                    Text("Folder")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 88, alignment: .leading)

                    Text(viewModel.outputDirectoryURL.path)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .textSelection(.enabled)
                }
            }

            if let collisionDescription = viewModel.currentRenderOutputCollisionDescription {
                MainWindowCaption(text: collisionDescription)
            }

            filenameEditor
            outputControls
        }
    }

    @ViewBuilder
    private var filenameEditor: some View {
        if shouldShowFilenameEditor {
            Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: rowSpacing) {
                GridRow {
                    Text("Custom name")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 88, alignment: .leading)
                    TextField("Filename", text: $viewModel.outputFilename)
                }
            }

            MainWindowCaption(text: viewModel.outputNameAutomationDescription)
        }
    }

    private var outputControls: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 10) {
                filenameButtons
                Spacer(minLength: 0)
                folderButtons
            }

            VStack(alignment: .leading, spacing: rowSpacing) {
                filenameButtons
                folderButtons
            }
        }
    }

    @ViewBuilder
    private var filenameButtons: some View {
        if viewModel.isOutputNameAutoManaged {
            Button("Customize Name…") {
                isFilenameEditorExpanded.toggle()
            }

            Button("Regenerate") {
                regenerateOutputName()
            }
        } else {
            Button("Use Auto Name") {
                regenerateOutputName()
            }
        }
    }

    private var folderButtons: some View {
        HStack(spacing: 10) {
            Button("Change Folder…") {
                viewModel.chooseOutputFolder()
            }
            .disabled(!viewModel.canChooseOutputFolder)

            Button("Reveal") {
                viewModel.openConfiguredOutputFolder()
            }
            .disabled(!viewModel.canOpenConfiguredOutputFolder)
        }
    }

    private var descriptionEditor: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 10) {
                Text("Description")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer(minLength: 8)

                descriptionButtons
            }

            if shouldShowDescriptionEditor {
                TextEditor(text: $viewModel.plexDescriptionText)
                    .font(.body)
                    .frame(minHeight: 56, idealHeight: 64)

                MainWindowCaption(text: viewModel.plexDescriptionAutomationDescription)
            } else {
                Text(descriptionPreview)
                    .font(.callout)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .textSelection(.enabled)
            }
        }
    }

    @ViewBuilder
    private var descriptionButtons: some View {
        if viewModel.isPlexDescriptionAutoManaged {
            Button("Edit…") {
                isDescriptionEditorExpanded.toggle()
            }

            Button("Regenerate") {
                regenerateDescription()
            }
        } else {
            Button("Use Default") {
                regenerateDescription()
            }
        }
    }

    private var manualMonthYearOverrideSection: some View {
        VStack(alignment: .leading, spacing: rowSpacing) {
            Text("Month/Year for Naming")
                .font(.subheadline)
                .fontWeight(.medium)
            MainWindowCaption(text: viewModel.manualMonthYearOverrideMessage)

            ViewThatFits(in: .horizontal) {
                HStack(spacing: 10) {
                    Picker("Month", selection: $viewModel.manualMonthYearOverrideMonth) {
                        ForEach(viewModel.months, id: \.self) { month in
                            Text(viewModel.monthLabel(for: month)).tag(month)
                        }
                    }

                    Picker("Year", selection: $viewModel.manualMonthYearOverrideYear) {
                        ForEach(viewModel.years, id: \.self) { year in
                            Text(String(year)).tag(year)
                        }
                    }

                    Button("Clear Override") {
                        viewModel.clearManualMonthYearOverride()
                    }
                }

                VStack(alignment: .leading, spacing: rowSpacing) {
                    Picker("Month", selection: $viewModel.manualMonthYearOverrideMonth) {
                        ForEach(viewModel.months, id: \.self) { month in
                            Text(viewModel.monthLabel(for: month)).tag(month)
                        }
                    }

                    Picker("Year", selection: $viewModel.manualMonthYearOverrideYear) {
                        ForEach(viewModel.years, id: \.self) { year in
                            Text(String(year)).tag(year)
                        }
                    }

                    Button("Clear Override") {
                        viewModel.clearManualMonthYearOverride()
                    }
                }
            }

            MainWindowCaption(text: "Used only when the app cannot safely determine a single month/year from the selected media.")
        }
    }

    private var shouldShowFilenameEditor: Bool {
        isFilenameEditorExpanded || !viewModel.isOutputNameAutoManaged
    }

    private var shouldShowDescriptionEditor: Bool {
        isDescriptionEditorExpanded || !viewModel.isPlexDescriptionAutoManaged
    }

    private var descriptionPreview: String {
        let trimmed = viewModel.plexDescriptionText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return "Description will be generated from the resolved month/year."
        }
        return trimmed
    }

    private func regenerateOutputName() {
        viewModel.useAutoGeneratedOutputName()
        isFilenameEditorExpanded = false
    }

    private func regenerateDescription() {
        viewModel.useDefaultPlexDescription()
        isDescriptionEditorExpanded = false
    }
}

struct MainWindowAdvancedExportSettingsView: View {
    @ObservedObject var viewModel: MainWindowViewModel

    private let rowSpacing: CGFloat = 8

    var body: some View {
        VStack(alignment: .leading, spacing: rowSpacing) {
            Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: rowSpacing) {
                GridRow {
                    Picker("Container", selection: $viewModel.selectedContainer) {
                        ForEach(ContainerFormat.allCases, id: \.self) { format in
                            Text(viewModel.containerOptionLabel(for: format)).tag(format)
                        }
                    }

                    Picker("Codec", selection: $viewModel.selectedVideoCodec) {
                        ForEach(VideoCodec.allCases, id: \.self) { codec in
                            Text(viewModel.videoCodecOptionLabel(for: codec)).tag(codec)
                        }
                    }
                    .disabled(viewModel.isHDRSelectionLocked)
                }

                GridRow {
                    Picker("Audio", selection: $viewModel.selectedAudioLayout) {
                        ForEach(AudioLayout.allCases, id: \.self) { layout in
                            Text(viewModel.audioLayoutOptionLabel(for: layout)).tag(layout)
                        }
                    }

                    Picker("Bitrate", selection: $viewModel.selectedBitrateMode) {
                        ForEach(BitrateMode.allCases, id: \.self) { mode in
                            Text(viewModel.bitrateModeOptionLabel(for: mode)).tag(mode)
                        }
                    }
                }

                GridRow {
                    Picker("Resolution", selection: $viewModel.selectedResolutionPolicy) {
                        Text(viewModel.resolutionPolicyOptionLabel(for: .fixed720p)).tag(ResolutionPolicy.fixed720p)
                        Text(viewModel.resolutionPolicyOptionLabel(for: .fixed1080p)).tag(ResolutionPolicy.fixed1080p)
                        Text(viewModel.resolutionPolicyOptionLabel(for: .fixed4K)).tag(ResolutionPolicy.fixed4K)
                        Text(viewModel.resolutionPolicyOptionLabel(for: .smart)).tag(ResolutionPolicy.smart)
                    }

                    Picker("Frame Rate", selection: $viewModel.selectedFrameRatePolicy) {
                        Text(viewModel.frameRatePolicyOptionLabel(for: .fps30)).tag(FrameRatePolicy.fps30)
                        Text(viewModel.frameRatePolicyOptionLabel(for: .fps60)).tag(FrameRatePolicy.fps60)
                        Text(viewModel.frameRatePolicyOptionLabel(for: .smart)).tag(FrameRatePolicy.smart)
                    }
                }

                GridRow {
                    Picker("Range", selection: $viewModel.selectedDynamicRange) {
                        ForEach(DynamicRange.allCases, id: \.self) { range in
                            Text(viewModel.dynamicRangeOptionLabel(for: range)).tag(range)
                        }
                    }
                    Color.clear
                }
            }

            Picker("HDR HEVC Encoder", selection: $viewModel.selectedHDRHEVCEncoderMode) {
                ForEach(HDRHEVCEncoderMode.allCases, id: \.self) { mode in
                    Text(viewModel.hdrHEVCEncoderOptionLabel(for: mode)).tag(mode)
                }
            }
            .disabled(viewModel.selectedDynamicRange != .hdr)

            Picker("HDR libx265 Speed", selection: $viewModel.selectedHDRX265Speed) {
                ForEach(HDRX265Speed.allCases, id: \.self) { speed in
                    Text(viewModel.hdrX265SpeedOptionLabel(for: speed)).tag(speed)
                }
            }
            .disabled(!viewModel.isHDRX265SpeedControlEnabled)

            if viewModel.isHDRSelectionLocked {
                MainWindowCaption(text: viewModel.hdrSelectionLockReason)
            }

            MainWindowCaption(text: viewModel.ffmpegEngineDescription)
            MainWindowCaption(text: viewModel.hdrHEVCEncoderDescription)
            MainWindowCaption(text: viewModel.hdrX265SpeedDescription)
            MainWindowCaption(text: viewModel.hdrX265SpeedCaution)

            VStack(alignment: .leading, spacing: 4) {
                MainWindowCaption(text: viewModel.bitrateModeDescription)
                MainWindowCaption(text: viewModel.frameRateDescription)

                if let photosSmartFrameRateDescription = viewModel.photosSmartFrameRateDescription {
                    MainWindowCaption(text: photosSmartFrameRateDescription)
                }

                if let photosSmartAudioDescription = viewModel.photosSmartAudioDescription {
                    MainWindowCaption(text: photosSmartAudioDescription)
                }
            }

            ViewThatFits(in: .horizontal) {
                HStack {
                    Toggle("Write diagnostics log (.log)", isOn: $viewModel.writeDiagnosticsLog)
                    Spacer()
                    Button("Reset Style & Export to Plex Defaults") {
                        viewModel.resetStyleAndExportSettingsToPlexDefaults()
                    }
                    .disabled(!viewModel.canResetExportSettings)
                }

                VStack(alignment: .leading, spacing: rowSpacing) {
                    Toggle("Write diagnostics log (.log)", isOn: $viewModel.writeDiagnosticsLog)
                    Button("Reset Style & Export to Plex Defaults") {
                        viewModel.resetStyleAndExportSettingsToPlexDefaults()
                    }
                    .disabled(!viewModel.canResetExportSettings)
                }
            }
        }
        .padding(.top, 4)
    }
}
