//
//  EnLikedPostsView.swift
//  Readify
//
//  Created by Тимофей Юдин on 15.11.2024.
//

import SwiftUI

@MainActor
final class EnLikedPostsViewModel: ObservableObject {
    @Published var isReadViewPresented = false
    @Published var articles: [EnArticle] = []
    @Published var likedPostsIndexes: [String] = []
    @Published var errorText = ""
    @Published var isErrorPopupPresented = false
    @Published var isDescriptionPopupPresented = false
    
    var description = ""
    var title = ""
    var image = UIImage()
    var dateCreated = Date()
    var text = ""
    var likesCount = 0
    var id = ""
    
    func loadLikedPosts() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        let user = try await UserManager.shared.getUser(userId: authDataResult.uid)
        
        self.likedPostsIndexes = user.likedPosts ?? []
    }
    
    func getArticles() async throws {
        articles = []
        
        for index in likedPostsIndexes {
            articles.append(try await ArticlesManager.shared.getEnArticle(id: index))
        }
    }
}

struct EnLikedPostsView: View {
    @StateObject var viewModel = EnLikedPostsViewModel()
    
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
                            ArticleView(id: article.id, title: article.enTitle, isPremium: article.isPremium)
                                .onTapGesture {
                                    viewModel.description = article.enDescription ?? ""
                                    viewModel.title = article.enTitle ?? ""
                                    viewModel.text =  article.enText ?? ""
                                    viewModel.image = StorageManager.shared.getImage(id: article.id) ?? UIImage()
                                    viewModel.dateCreated = article.dateCreated ?? Date()
                                    viewModel.likesCount = article.likesCount ?? 0
                                    viewModel.id = article.id
                                    
                                    
                                    viewModel.isDescriptionPopupPresented = true
                                }
                                .padding(.top, 10)
                        }
                    }
                    
                }
                
            }
            .padding(.top, 10)
            .refreshable {
                Task {
                    Task {
                        do {
                            try await viewModel.loadLikedPosts()
                            return
                        } catch {
                            withAnimation {
                                viewModel.errorText = error.localizedDescription
                            }
                        }
                        
                        viewModel.isErrorPopupPresented = true
                    }
                }
            }
            .onChange(of: viewModel.likedPostsIndexes, perform: { newValue in
                Task {
                    do {
                        try await viewModel.getArticles()
                        return
                    } catch {
                        viewModel.errorText = error.localizedDescription
                    }
                    
                    viewModel.isErrorPopupPresented = true
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
                    title: viewModel.title,
                    text: viewModel.text,
                    image: viewModel.image,
                    dateCreated: viewModel.dateCreated,
                    likesCount: viewModel.likesCount,
                    likedPosts: $viewModel.likedPostsIndexes
                    
                )
            })
            .popup(isPresented: $viewModel.isErrorPopupPresented) {
                Text(viewModel.errorText)
                    .frame(width: UIScreen.main.bounds.width - 72)
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
                if viewModel.likedPostsIndexes == [] {
                    Task {
                        do {
                            try await viewModel.loadLikedPosts()
                            return
                        } catch {
                            withAnimation {
                                viewModel.errorText = error.localizedDescription
                            }
                        }
                        
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
                            .shadow(radius: 5)
                        
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

#Preview {
    EnLikedPostsView()
}

