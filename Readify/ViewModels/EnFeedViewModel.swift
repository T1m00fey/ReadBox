//
//  EnFeedViewModel.swift
//  Readify
//
//  Created by Тимофей Юдин on 19.12.2024.
//

import SwiftUI

@MainActor
final class EnFeedViewModel: ObservableObject {
    @Published var topArticlesIndexes: [String] = []
    @Published var topArticles: [EnArticle] = []
    @Published var articles: [EnArticle] = []
    @Published var errorText = ""
    @Published var isErrorPopupPresented = false
    @Published var isDescriptionPopupPresented = false
    @Published var isReadViewPresented = false
    @Published var likedPosts: [String] = []
    @Published var fromIndex = -1
    @Published var maxIndex = ""
    @Published var articlesRead = 0
    
    @Published var user: DBUser? = nil
    
    func loadUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        let user = try await UserManager.shared.getUser(userId: authDataResult.uid)
        
        self.user = user
    }
    
    func getMaxIndex() async throws {
        maxIndex = try await ArticlesManager.shared.getMaxIndex() ?? "10"
    }
    
    var description = ""
    var title = ""
    var image = UIImage()
    var dateCreated = Date()
    var text = ""
    var likesCount = 0
    var id = ""
    var userId = ""
    
    func getArticle(id: String) async throws -> EnArticle {
        try await ArticlesManager.shared.getEnArticle(id: id)
    }
    
    func getTopArticles() async throws {
        Task {
            do {
                topArticles = []
                
                for index in topArticlesIndexes {
                    topArticles.append(try await getArticle(id: index))
                }
                
                return
            } catch {
                withAnimation {
                    errorText = error.localizedDescription
                }
            }
            
            isErrorPopupPresented = true
        }
    }
    
    func getTopIndexes() async throws {
        topArticlesIndexes = try await ArticlesManager.shared.getTopArticlesIndexes() ?? ["0"]
    }
    
    func getArticles() async throws {
        for _ in 0..<10 {
            if !topArticlesIndexes.contains(String(fromIndex)) && fromIndex >= 0 {
                do {
                    articles.append(try await getArticle(id: String(fromIndex)))
                } catch {
                    withAnimation {
                        errorText = NSLocalizedString("someArticlesNotFoundLabel", comment: "")
                        isErrorPopupPresented = true
                    }
                }
            }
            
            fromIndex -= 1
        }
    }
}
