//
//  ViewModel.swift
//  PaginationTraining
//
//  Created by Pooyan J on 5/29/25.
//

import Foundation

final class ViewModel: ObservableObject {

    enum PageState {
        case loading, error, completed
    }

    @Published var items: [ResponseModel.Item] = []
    @Published var pageState: PageState?

    var start = 0
    var size: Int = 10
    private(set) var hasMoreData: Bool = false
    private var isLoading = false

    init() {
        getData(start: start, size: size)
    }
}

// MARK: - API Call
extension ViewModel {

    private enum MyError: Error {
        case urlError
    }

    func getData(start: Int, size: Int) {
        guard !isLoading else { return }

        isLoading = true
        pageState = .loading

        Task {
            do {
                try await Task.sleep(for: .seconds(1))
                let result = try await baseRequest(start: start, size: size)
                await MainActor.run {
                    let newItems = result.results
                    self.items.append(contentsOf: newItems)
                    hasMoreData = newItems.count == size
                    self.start += size
                    self.pageState = .completed
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.pageState = .error
                    self.isLoading = false
                }
                print("Pagination error: \(error.localizedDescription)")
            }
        }
    }

    private func baseRequest(start: Int, size: Int) async throws -> ResponseModel {
        let urlString = "https://pokeapi.co/api/v2/pokemon?offset=\(start)&limit=\(size)"
        guard let url = URL(string: urlString) else { throw MyError.urlError }

        let (data, _) = try await URLSession.shared.data(from: url)
        let decodedData = try JSONDecoder().decode(ResponseModel.self, from: data)
        print("URL ===>" , urlString)
        return decodedData
    }
}
