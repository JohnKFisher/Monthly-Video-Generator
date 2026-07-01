import SwiftUI

struct MainWindowStylePane: View {
    @ObservedObject var viewModel: MainWindowViewModel

    private let rowSpacing: CGFloat = 6

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: rowSpacing) {
                if viewModel.includeOpeningTitle {
                    Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: rowSpacing) {
                        GridRow {
                            Text("Title")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(width: 74, alignment: .leading)
                            TextField("Title text", text: $viewModel.openingTitleText)
                        }

                        GridRow {
                            Text("Caption")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(width: 74, alignment: .leading)
                            TextField("Small caption", text: $viewModel.openingTitleCaptionText)
                        }
                    }

                    MainWindowCaption(text: "Title auto-follows the selected month/year until edited; blank caption hides it.")
                } else {
                    MainWindowCaption(text: "Opening title cards are disabled in Settings.")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } label: {
            MainWindowSectionLabel(title: "Opening Title", accent: MainWindowTheme.accentPeach)
        }
    }
}

struct MainWindowSettingsSummaryPane: View {
    @ObservedObject var viewModel: MainWindowViewModel

    private let rowSpacing: CGFloat = 6

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: rowSpacing) {
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Label(
                        viewModel.hasCustomStyleOrExportSettings ? "Custom output settings" : "Recommended output",
                        systemImage: viewModel.hasCustomStyleOrExportSettings ? "exclamationmark.triangle.fill" : "checkmark.circle.fill"
                    )
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(viewModel.hasCustomStyleOrExportSettings ? MainWindowTheme.accentAmber : MainWindowTheme.accentGreen)

                    Spacer(minLength: 8)

                    SettingsLink {
                        Text("Review Output…")
                    }

                    if viewModel.hasCustomStyleOrExportSettings {
                        Button("Reset to Defaults") {
                            viewModel.resetStyleAndExportSettingsToPlexDefaults()
                        }
                        .disabled(!viewModel.canResetExportSettings)
                    }
                }

                MainWindowCaption(text: viewModel.outputPresetDescription)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } label: {
            MainWindowSectionLabel(title: "Output Settings", accent: MainWindowTheme.accentTeal)
        }
    }
}
