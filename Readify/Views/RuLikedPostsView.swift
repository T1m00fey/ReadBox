//
//  RuLikedPostsView.swift
//  Readify
//
//  Created by Тимофей Юдин on 15.11.2024.
//

import SwiftUI

@MainActor
final class RuLikedPostsViewModel: ObservableObject {
    @Published var isReadViewPresented = false
    @Published var articles: [RuArticle] = []
    @Published var errorText = ""
    @Published var isErrorPopupPresented = false
    @Published var isDescriptionPopupPresented = false
    @Published var user: DBUser? = nil
    @Published var likedPosts: [String] = []
    @Published var articlesRead = 0
    
    var description = ""
    var title = ""
    var image = UIImage()
    var dateCreated = Date()
    var text = ""
    var likesCount = 0
    var id = ""
    var userId = ""
    
    func getArticle(id: String) async throws -> RuArticle {
        try await ArticlesManager.shared.getRuArticle(id: id)
    }
    
    func loadUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        let user = try await UserManager.shared.getUser(userId: authDataResult.uid)
        
        self.user = user
    }
    
    func getArticles() async throws {
        articles = []
        
        for index in likedPosts {
            do {
                articles.append(try await ArticlesManager.shared.getRuArticle(id: index))
            } catch {
                withAnimation {
                    errorText = NSLocalizedString("someArticlesNotFoundLabel", comment: "")
                    isErrorPopupPresented = true
                }
            }
        }
    }
}

struct RuLikedPostsView: View {
    @StateObject var viewModel = RuLikedPostsViewModel()
    
    var body: some View {
        
        NavigationStack {
            
            ScrollView(showsIndicators: false) {
                
                VStack {
                    
                    if viewModel.articles == [] {
                        
                        VStack(spacing: 20) {
                            
                            Image(systemName: "list.bullet.below.rectangle")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .foregroundStyle(Color.gray)
                            
                            Text(LocalizedStringKey("noArticlesAddedLabel"))
                                .font(.title)
                                .bold()
                                .fontDesign(.rounded)
                                .foregroundStyle(Color.gray)
                                .multilineTextAlignment(.center)
                        }
                        .frame(height: UIScreen.main.bounds.height - 200, alignment: .center)
                        
                    } else {
                        ForEach(viewModel.articles) { article in
                            ArticleView(id: article.id, title: article.ruTitle, isPremium: article.isPremium)
                                .onTapGesture {
                                    viewModel.description = article.ruDescription ?? ""
                                    viewModel.title = article.ruTitle ?? ""
                                    viewModel.text = article.ruText ?? ""
                                    viewModel.image = StorageManager.shared.getImage(id: article.id) ?? UIImage()
                                    viewModel.dateCreated = article.dateCreated ?? Date()
                                    viewModel.likesCount = article.likesCount ?? 0
                                    viewModel.id = article.id
                                    
                                    if viewModel.user != nil {
                                        if viewModel.articlesRead == 0 {
                                            viewModel.articlesRead = viewModel.user?.articlesRead ?? 0
                                        }
                                        
                                        if viewModel.userId == "" {
                                            viewModel.userId = viewModel.user?.userId ?? ""
                                        }
                                        
                                        viewModel.isDescriptionPopupPresented = true
                                    } else {
                                        withAnimation {
                                            viewModel.errorText = NSLocalizedString("loadDataErrorText", comment: "")
                                            viewModel.isErrorPopupPresented = true
                                        }
                                    }
                                }
                                .padding(.top, 10)
                        }
                    }
                    
                }
                
            }
            .padding(.top, 10)
            .refreshable {
                Task {
                    try? await viewModel.loadUser()
                }
            }
            .onChange(of: viewModel.likedPosts, perform: { newValue in
                if viewModel.likedPosts != [] {
                    Task {
                        do {
                            try await viewModel.getArticles()
                            return
                        } catch {
                            withAnimation {
                                viewModel.errorText = error.localizedDescription
                            }
                        }
                        
                        viewModel.isErrorPopupPresented = true
                    }
                } else {
                    viewModel.articles = []
                }
            })
            .popup(isPresented: $viewModel.isDescriptionPopupPresented) {
                DescriptionView(
                    isReadViewPresented: $viewModel.isReadViewPresented,
                    description: viewModel.description
                )
                .shadow(radius: 3)
            } customize: {
                $0
                    .type(.toast)
                    .appearFrom(.bottomSlide)
                    .dragToDismiss(true)
            }
            .fullScreenCover(isPresented: $viewModel.isReadViewPresented, content: {
                ReadView(
                    id: viewModel.id,
                    userId: viewModel.userId,
                    title: viewModel.title,
                    text: viewModel.text,
                    image: viewModel.image,
                    dateCreated: viewModel.dateCreated,
                    likesCount: viewModel.likesCount,
                    articlesRead: $viewModel.articlesRead,
                    likedPosts: $viewModel.likedPosts
                )
            })
            .popup(isPresented: $viewModel.isErrorPopupPresented) {
                Text(viewModel.errorText)
                    .frame(width: UIScreen.main.bounds.width - 72, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .foregroundStyle(Color.white)
                    .background(Color.red)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.top, 20)
            } customize: {
                $0
                    .type(.floater())
                    .position(.top)
                    .animation(.bouncy)
                    .dragToDismiss(true)
                    .autohideIn(5)
            }
            .onAppear {
                if viewModel.user == nil {
                    Task {
                        try? await viewModel.loadUser()
                    }
                }
            }
            .onChange(of: viewModel.user) { newValue in
                if viewModel.user?.likedPosts != nil {
                    viewModel.likedPosts = viewModel.user?.likedPosts ?? []
                } else {
                    withAnimation {
                        viewModel.errorText = NSLocalizedString("loadErrorText", comment: "")
                        viewModel.isErrorPopupPresented = true
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
//                    Text(LocalizedStringKey("favoritesLabel"))
//                        .font(.largeTitle)
//                        .fontDesign(.rounded)
//                        .fontWeight(.light)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .frame(width: UIScreen.main.bounds.width, height: 130)
                            .foregroundStyle(Color(uiColor: .secondarySystemBackground))
                            .padding(.bottom, 40)
                            .shadow(radius: 10)
                        
                        Text(LocalizedStringKey("favoritesLabel"))
                            .font(.largeTitle)
                            .fontWeight(.light)
                            .fontDesign(.rounded)
                            .frame(width: UIScreen.main.bounds.width - 32, alignment: .leading)
                    }
                    .padding(.leading, 6)
                }
            }
        }
    }
}

