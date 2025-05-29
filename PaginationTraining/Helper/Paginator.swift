//
//  Paginator.swift
//  PaginationTraining
//
//  Created by Pooyan J on 5/29/25.
//

import Foundation

@MainActor
final class Paginator<Item>: ObservableObject {
    
    enum PageState {
        case idle, loading, completed, error(Error)
    }
    
    @Published private(set) var items: [Item] = []
    @Published private(set) var state: PageState = .idle
    
    private(set) var hasMoreData: Bool = true
    private var isLoading = false
    
    private var start: Int
    private let pageSize: Int
    
    // fetchPage takes current start and pageSize, returns new items
    private let fetchPage: (Int, Int) async throws -> [Item]
    
    init(start: Int = 0, pageSize: Int = 10,
         fetchPage: @escaping (Int, Int) async throws -> [Item]) {
        self.start = start
        self.pageSize = pageSize
        self.fetchPage = fetchPage
    }
    
    func loadNextPage() {
        guard !isLoading && hasMoreData else { return }
        
        isLoading = true
        state = .loading
        
        Task {
            do {
                let newItems = try await fetchPage(start, pageSize)
                items.append(contentsOf: newItems)
                start += newItems.count
                hasMoreData = newItems.count == pageSize
                state = .completed
            } catch {
                state = .error(error)
            }
            isLoading = false
        }
    }
    
    func reset(start: Int = 0) {
        self.start = start
        self.items.removeAll()
        self.hasMoreData = true
        self.state = .idle
        loadNextPage()
    }
}
