import SwiftUI

struct MainWindowInputPane: View {
    @ObservedObject var viewModel: MainWindowViewModel

    private let rowSpacing: CGFloat = 8

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: rowSpacing) {
                sourceModePicker

                Divider()

                switch viewModel.sourceMode {
                case .folder:
                    folderSourceControls
                case .photos:
                    photosSourceControls
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } label: {
            MainWindowSectionLabel(title: "Source", accent: MainWindowTheme.accentTeal)
        }
    }

    private var sourceModePicker: some View {
        VStack(alignment: .leading, spacing: 4) {
            Picker("Movie source", selection: $viewModel.sourceMode) {
                ForEach(MainWindowViewModel.SourceMode.allCases) { mode in
                    Text(mode.label).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 280)

            MainWindowCaption(text: viewModel.sourceMode == .folder
                ? "Use media from a folder on this Mac."
                : "Use photos and videos from Apple Photos.")
        }
    }

    private var folderSourceControls: some View {
        VStack(alignment: .leading, spacing: rowSpacing) {
            HStack(spacing: 10) {
                Button("Choose Source Folder…") {
                    viewModel.chooseInputFolder()
                }
                .disabled(!viewModel.canChooseInputFolder)

                Toggle("Include subfolders", isOn: $viewModel.recursiveScan)
            }

            Text(viewModel.selectedFolderURL?.path ?? "No folder selected")
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .textSelection(.enabled)
        }
    }

    private var photosSourceControls: some View {
        VStack(alignment: .leading, spacing: rowSpacing) {
            Picker("Make video from", selection: $viewModel.selectedPhotosFilterMode) {
                ForEach(MainWindowViewModel.PhotosFilterMode.allCases) { mode in
                    Text(mode.label).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 280)

            switch viewModel.selectedPhotosFilterMode {
            case .monthYear:
                photosMonthYearControls
            case .album:
                photosAlbumControls
            }
        }
    }

    private var photosMonthYearControls: some View {
        VStack(alignment: .leading, spacing: rowSpacing) {
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 10) {
                    Picker("Month", selection: $viewModel.selectedMonth) {
                        ForEach(viewModel.months, id: \.self) { month in
                            Text(viewModel.monthLabel(for: month)).tag(month)
                        }
                    }

                    Picker("Year", selection: $viewModel.selectedYear) {
                        ForEach(viewModel.years, id: \.self) { year in
                            Text(String(year)).tag(year)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: rowSpacing) {
                    Picker("Month", selection: $viewModel.selectedMonth) {
                        ForEach(viewModel.months, id: \.self) { month in
                            Text(viewModel.monthLabel(for: month)).tag(month)
                        }
                    }

                    Picker("Year", selection: $viewModel.selectedYear) {
                        ForEach(viewModel.years, id: \.self) { year in
                            Text(String(year)).tag(year)
                        }
                    }
                }
            }

            MainWindowCaption(text: "Exports one calendar month from Apple Photos.")
        }
    }

    private var photosAlbumControls: some View {
        VStack(alignment: .leading, spacing: rowSpacing) {
            HStack(spacing: 10) {
                Picker("Album", selection: $viewModel.selectedPhotoAlbumID) {
                    if viewModel.photoAlbums.isEmpty {
                        Text("No Albums Available").tag("")
                    } else {
                        ForEach(viewModel.photoAlbums) { album in
                            Text(album.displayLabel).tag(album.localIdentifier)
                        }
                    }
                }
                .disabled(viewModel.isLoadingPhotoAlbums || !viewModel.hasPhotoAlbums)

                Button("Refresh") {
                    viewModel.refreshPhotoAlbums()
                }
                .disabled(viewModel.isLoadingPhotoAlbums)
            }

            if viewModel.isLoadingPhotoAlbums {
                HStack(spacing: 8) {
                    ProgressView()
                    MainWindowCaption(text: "Loading albums…")
                }
            } else if !viewModel.photoAlbumsStatusMessage.isEmpty {
                MainWindowCaption(text: viewModel.photoAlbumsStatusMessage)
            } else {
                MainWindowCaption(text: "Exports the selected Apple Photos album.")
            }
        }
    }
}
