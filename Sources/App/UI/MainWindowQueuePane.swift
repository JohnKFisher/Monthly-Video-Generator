import SwiftUI

struct MainWindowQueuePane: View {
    @ObservedObject var viewModel: MainWindowViewModel

    @State private var selectedQueuedJobID: MainWindowViewModel.QueuedRenderJob.ID?
    @State private var pendingRemoval: PendingQueueRemoval?
    @State private var isClearQueueConfirmationPresented = false

    private let rowSpacing: CGFloat = 8

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: rowSpacing) {
                if viewModel.queuedRenderJobs.isEmpty {
                    emptyQueueIntro
                    emptyQueueActions
                } else {
                    queueActions
                    queueFlightStrip

                    if let selectedQueuedJob {
                        MainWindowQueueJobDetailCard(
                            job: selectedQueuedJob,
                            isExplicitlySelected: selectedQueuedJobID == selectedQueuedJob.id
                        ) {
                            pendingRemoval = PendingQueueRemoval(job: selectedQueuedJob)
                        }
                    }
                }

                if !viewModel.queuedRenderJobs.isEmpty {
                    MainWindowCaption(text: viewModel.queueStatusDescription)
                }

                if viewModel.showsSelectedYearQueueAction {
                    MainWindowCaption(text: viewModel.selectedYearQueueDescription)
                }

                if viewModel.isPreparingYearQueue {
                    HStack(spacing: 8) {
                        ProgressView()
                        MainWindowCaption(text: "Scanning \(viewModel.yearQueueLabelYear) for non-empty months…")
                        Button("Cancel Scan") {
                            viewModel.cancelSelectedYearQueueScan()
                        }
                        .disabled(!viewModel.canCancelYearQueueScan)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } label: {
            MainWindowSectionLabel(title: "Batch Exports", accent: MainWindowTheme.accentNavy)
        }
        .alert(
            "Remove queued job?",
            isPresented: Binding(
                get: { pendingRemoval != nil },
                set: { isPresented in
                    if !isPresented {
                        pendingRemoval = nil
                    }
                }
            )
        ) {
            Button("Remove Job", role: .destructive) {
                if let pendingRemoval {
                    if selectedQueuedJobID == pendingRemoval.id {
                        selectedQueuedJobID = nil
                    }
                    viewModel.removeQueuedRenderJob(id: pendingRemoval.id)
                }
                pendingRemoval = nil
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Remove \(pendingRemoval?.label ?? "this job") from the queue. Completed output files are not deleted.")
        }
        .alert(
            "Clear all queued jobs?",
            isPresented: $isClearQueueConfirmationPresented,
        ) {
            Button("Clear Queue", role: .destructive) {
                selectedQueuedJobID = nil
                viewModel.clearQueuedRenderJobs()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This removes queued job records and result summaries. Exported video files are not deleted.")
        }
    }

    private var selectedQueuedJob: MainWindowViewModel.QueuedRenderJob? {
        if
            let selectedQueuedJobID,
            let selectedJob = viewModel.queuedRenderJobs.first(where: { $0.id == selectedQueuedJobID })
        {
            return selectedJob
        }

        guard let preferredID = viewModel.preferredQueueDetailJobID else {
            return nil
        }
        return viewModel.queuedRenderJobs.first(where: { $0.id == preferredID })
    }

    private var queueFlightStrip: some View {
        VStack(alignment: .leading, spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(viewModel.queuedRenderJobs) { job in
                        Button {
                            selectedQueuedJobID = job.id
                        } label: {
                            MainWindowQueueJobTile(
                                label: viewModel.queueTileLabel(for: job),
                                state: job.state,
                                isSelected: selectedQueuedJob?.id == job.id
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(job.state.displayLabel): \(job.sourceSummary)")
                    }
                }
                .padding(.vertical, 2)
            }

            ProgressView(value: viewModel.queueProgress)
                .tint(MainWindowTheme.accentAmber)

            MainWindowCaption(text: "Queue: \(viewModel.queueProgressLabel) complete")
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(queueCardBackground)
        )
    }

    private var queueActions: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 10) {
                Button(viewModel.addCurrentSettingsToQueueLabel) {
                    viewModel.addCurrentSettingsToQueue()
                }
                .disabled(!viewModel.canAddCurrentSettingsToQueue)

                if viewModel.showsSelectedYearQueueAction {
                    Button(viewModel.isPreparingYearQueue ? "Scanning Year…" : "Queue Full Year") {
                        viewModel.addSelectedYearToQueue()
                    }
                    .disabled(!viewModel.canAddSelectedYearToQueue)
                }

                Spacer(minLength: 0)

                if viewModel.isQueueRunning {
                    Button(viewModel.isQueuePauseRequested ? "Pausing after this item…" : "Pause After Current Item") {
                        viewModel.pauseQueueAfterCurrentItem()
                    }
                    .disabled(!viewModel.canPauseQueueAfterCurrentItem)
                }

                Button("Start Queue") {
                    viewModel.startQueue()
                }
                .disabled(!viewModel.canStartQueue)

                Button("Clear Queue") {
                    isClearQueueConfirmationPresented = true
                }
                .disabled(!viewModel.canClearQueue)
            }

            VStack(alignment: .leading, spacing: rowSpacing) {
                Button(viewModel.addCurrentSettingsToQueueLabel) {
                    viewModel.addCurrentSettingsToQueue()
                }
                .disabled(!viewModel.canAddCurrentSettingsToQueue)

                if viewModel.showsSelectedYearQueueAction {
                    Button(viewModel.isPreparingYearQueue ? "Scanning Year…" : "Queue Full Year") {
                        viewModel.addSelectedYearToQueue()
                    }
                    .disabled(!viewModel.canAddSelectedYearToQueue)
                }

                HStack(spacing: 10) {
                    if viewModel.isQueueRunning {
                        Button(viewModel.isQueuePauseRequested ? "Pausing after this item…" : "Pause After Current Item") {
                            viewModel.pauseQueueAfterCurrentItem()
                        }
                        .disabled(!viewModel.canPauseQueueAfterCurrentItem)
                    }

                    Button("Start Queue") {
                        viewModel.startQueue()
                    }
                    .disabled(!viewModel.canStartQueue)

                    Button("Clear Queue") {
                        isClearQueueConfirmationPresented = true
                    }
                    .disabled(!viewModel.canClearQueue)
                }
            }
        }
    }

    private var emptyQueueIntro: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Need more than one video?")
                .font(.subheadline.weight(.semibold))

            MainWindowCaption(text: viewModel.queueStatusDescription)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var emptyQueueActions: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 10) {
                Button(viewModel.addCurrentSettingsToQueueLabel) {
                    viewModel.addCurrentSettingsToQueue()
                }
                .disabled(!viewModel.canAddCurrentSettingsToQueue)

                if viewModel.showsSelectedYearQueueAction {
                    Button(viewModel.isPreparingYearQueue ? "Scanning Year…" : "Queue Full Year") {
                        viewModel.addSelectedYearToQueue()
                    }
                    .disabled(!viewModel.canAddSelectedYearToQueue)
                }
            }

            VStack(alignment: .leading, spacing: rowSpacing) {
                Button(viewModel.addCurrentSettingsToQueueLabel) {
                    viewModel.addCurrentSettingsToQueue()
                }
                .disabled(!viewModel.canAddCurrentSettingsToQueue)

                if viewModel.showsSelectedYearQueueAction {
                    Button(viewModel.isPreparingYearQueue ? "Scanning Year…" : "Queue Full Year") {
                        viewModel.addSelectedYearToQueue()
                    }
                    .disabled(!viewModel.canAddSelectedYearToQueue)
                }
            }
        }
    }

    private struct PendingQueueRemoval: Identifiable {
        let id: MainWindowViewModel.QueuedRenderJob.ID
        let label: String

        init(job: MainWindowViewModel.QueuedRenderJob) {
            id = job.id
            label = job.outputNamePreview.isEmpty ? job.sourceSummary : job.outputNamePreview
        }
    }

    private var queueCardBackground: Color {
        #if canImport(AppKit)
        Color(nsColor: .controlBackgroundColor).opacity(0.72)
        #else
        Color.secondary.opacity(0.08)
        #endif
    }
}
