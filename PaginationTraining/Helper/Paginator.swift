//
//  Paginator.swift
//  PaginationTraining
//
//  Created by Pooyan J on 5/29/25.
//

import Foundation

@MainActor
final class GenericPaginator<Item>: ObservableObject {
    
    enum PageState {
        case idle, loading, completed, error(Error)
    }
    
    @Published private(set) var items: [Item] = []
    @Published private(set) var state: PageState = .idle
    
    private(set) var hasMoreData: Bool = true
    private var isLoading = false
    
    // The "pagination info" type is generic and opaque here.
    private var paginationInfo: Any?
    
    // The "fetch function" that fetches next page of data.
    // It takes current paginationInfo, returns new items and updated pagination info.
    private let fetchPage: (Any?) async throws -> (items: [Item], nextPaginationInfo: Any?)
    
    init(initialPaginationInfo: Any? = nil,
         fetchPage: @escaping (Any?) async throws -> (items: [Item], nextPaginationInfo: Any?)) {
        self.paginationInfo = initialPaginationInfo
        self.fetchPage = fetchPage
    }
    
    func loadNextPage() {
        guard !isLoading && hasMoreData else { return }
        
        isLoading = true
        state = .loading
        
        Task {
            do {
                let (newItems, newPaginationInfo) = try await fetchPage(paginationInfo)
                items.append(contentsOf: newItems)
                paginationInfo = newPaginationInfo
                hasMoreData = !newItems.isEmpty // or any other custom logic
                state = .completed
            } catch {
                state = .error(error)
            }
            isLoading = false
        }
    }
    
    func reset(with paginationInfo: Any? = nil) {
        self.paginationInfo = paginationInfo
        self.items.removeAll()
        self.hasMoreData = true
        self.state = .idle
        loadNextPage()
    }
}
