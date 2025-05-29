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

    private lazy var paginator: Paginator<ResponseModel.Item> = {
        Paginator<ResponseModel.Item>(start: 0, pageSize: size, fetchPage: fetchPage)
    }()
    
    var hasMoreData: Bool {
        paginator.hasMoreData
    }

    init() {
        bindPaginator()
        paginator.loadNextPage()
    }

    func fetchPage(offset: Int, pageSize: Int) async throws -> [ResponseModel.Item] {
        let urlString = "https://pokeapi.co/api/v2/pokemon?offset=\(offset)&limit=\(pageSize)"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay for demo
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(ResponseModel.self, from: data)
        print("Fetched page: offset \(offset), count: \(decoded.results.count)")
        return decoded.results
    }

    func loadMoreIfNeeded() {
        paginator.loadNextPage()
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
