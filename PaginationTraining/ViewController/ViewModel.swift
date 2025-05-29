//
//  ViewModel.swift
//  PaginationTraining
//
//  Created by Pooyan J on 5/29/25.
//

import Foundation
import Combine

@MainActor
final class ViewModel: ObservableObject {

    enum PageState {
        case loading, error, completed
    }

    @Published var items: [ResponseModel.Item] = []
    @Published var pageState: PageState?
    private var cancellables: Set<AnyCancellable> = []
    private let size: Int = 10
    private var paginator: GenericPaginator<ResponseModel.Item>

    init() {
        let pageSize = size // capture the size value locally

        paginator = GenericPaginator<ResponseModel.Item>(initialPaginationInfo: 0) { currentOffset in
            let offset = currentOffset as? Int ?? 0
            let urlString = "https://pokeapi.co/api/v2/pokemon?offset=\(offset)&limit=\(pageSize)"
            guard let url = URL(string: urlString) else {
                throw URLError(.badURL)
            }
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(ResponseModel.self, from: data)
            let nextOffset = offset + decoded.results.count
            print("URL ===>", urlString)
            return (items: decoded.results, nextPaginationInfo: nextOffset)
        }
        bindPaginator()
        paginator.loadNextPage()
    }

    func loadMoreIfNeeded() {
        paginator.loadNextPage()
    }

    var hasMoreData: Bool {
        paginator.hasMoreData
    }

    private func bindPaginator() {
        paginator.$items.assign(to: &$items)

        paginator.$state.sink { [weak self] state in
            switch state {
            case .loading:
                self?.pageState = .loading
            case .completed:
                self?.pageState = .completed
            case .error:
                self?.pageState = .error
            case .idle:
                break
            }
        }
        .store(in: &cancellables)
    }
}
