//
//  EnFeedView.swift
//  Readify
//
//  Created by Тимофей Юдин on 13.11.2024.
//

import SwiftUI
import FirebaseStorage

@MainActor
final class EnFeedViewModel: ObservableObject {
    @Published var topArticlesIndexes: [String] = []
    @Published var topArticles: [EnArticle] = []
    @Published var articles: [EnArticle] = []
    @Published var errorText = ""
    @Published var isErrorPopupPresented = false
    @Published var images: [UIImage?] = []
    @Published var isDescriptionPopupPresented = false
    @Published var isReadViewPresented = false
    @Published var likedPosts: [String] = []
    @Published var fromIndex = 0
    @Published var maxIndex = ""
    
    func loadLikedPosts() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        let user = try await UserManager.shared.getUser(userId: authDataResult.uid)
        
        self.likedPosts = user.likedPosts ?? []
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
        for index in fromIndex...fromIndex + 9 {
            if !topArticlesIndexes.contains(String(index)) && index <= Int(maxIndex) ?? 10 {
                articles.append(try await getArticle(id: String(index)))
            }
        }
        
        fromIndex += 10
    }
}

struct EnFeedView: View {
    @StateObject var viewModel = EnFeedViewModel()
    
    
    var body: some View {
        NavigationStack {
            
            ZStack {
                
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    
                    VStack {
                        
                        TabView {
                            
                            ForEach(viewModel.topArticles, id: \.self) { article in
                                TopArticleView(id: article.id, title: article.enTitle, isPremium: article.isPremium)
                                    .onTapGesture {
                                        viewModel.description = article.enDescription ?? ""
                                        viewModel.title = article.enTitle ?? ""
                                        viewModel.text = article.enText ?? ""
                                        viewModel.image = StorageManager.shared.getImage(id: article.id) ?? UIImage()
                                        viewModel.dateCreated = article.dateCreated ?? Date()
                                        viewModel.likesCount = article.likesCount ?? 0
                                        viewModel.id = article.id
                                        
                                        viewModel.isDescriptionPopupPresented = true
                                    }
                                    .tabItem {}
                            }
                            
                        }
                        .tabViewStyle(.page)
                        .frame(height: 270)
                        .padding(.top, 20)
                        
                        ForEach(viewModel.articles, id: \.self) { article in
                            ArticleView(
                                id: article.id,
                                title: article.enTitle,
                                isPremium: article.isPremium
                            )
                            .padding(.top, 10)
                            .onTapGesture {
                                viewModel.description = article.enDescription ?? ""
                                viewModel.title = article.enTitle ?? ""
                                viewModel.text = article.enText ?? ""
                                viewModel.image = StorageManager.shared.getImage(id: article.id) ?? UIImage()
                                viewModel.dateCreated = article.dateCreated ?? Date()
                                viewModel.likesCount = article.likesCount ?? 0
                                viewModel.id = article.id
                                
                                viewModel.isDescriptionPopupPresented = true
                            }
                            
                        }
                        
                        if viewModel.articles != [] && Int(viewModel.maxIndex) ?? 10 >= viewModel.fromIndex {
                            Button {
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
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.down")
                                        .foregroundStyle(Color(uiColor: .label))
                                        .font(.title3)
                                    
                                    Text(LocalizedStringKey("loadMore"))
                                        .font(.title3)
                                        .fontDesign(.rounded)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color(uiColor: .secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .shadow(radius: 2)
                                .padding(.top, 20)
                            }
                            .padding(.bottom, 10)
                            
                        }
                        
                    }
                    
                }
                .padding(.top, 10)
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
                .onChange(of: viewModel.topArticlesIndexes) { newValue in
                    if viewModel.topArticlesIndexes.count == 5 {
                        Task {
                            do {
                                try await viewModel.getTopArticles()
                                
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
                .onChange(of: viewModel.topArticles) { newValue in
                    if viewModel.topArticles.count == 5 {
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
                    }
                }
                .onAppear {
                    Task {
                        try? await viewModel.loadLikedPosts()
                    }
                    
                    Task {
                        do {
                            try await viewModel.getMaxIndex()
                            return
                        } catch {
                            withAnimation {
                                viewModel.errorText = error.localizedDescription
                            }
                        }
                        
                        viewModel.isErrorPopupPresented = true
                    }
                    
                    Task {
                        do {
                            if viewModel.topArticlesIndexes == [] {
                                try await viewModel.getTopIndexes()
                            }
                            
                            return
                        } catch {
                            withAnimation {
                                viewModel.errorText = error.localizedDescription
                            }
                        }
                        
                        viewModel.isErrorPopupPresented = true
                    }
                }
                .fullScreenCover(isPresented: $viewModel.isReadViewPresented, content: {
                    ReadView(
                        id: viewModel.id,
                        title: viewModel.title,
                        text: viewModel.text,
                        image: viewModel.image,
                        dateCreated: viewModel.dateCreated,
                        likesCount: viewModel.likesCount,
                        likedPosts: $viewModel.likedPosts
                    )
                })
                .refreshable {
                    withAnimation {
                        viewModel.fromIndex = 0
                        
                        viewModel.topArticlesIndexes = []
                        viewModel.topArticles = []
                        viewModel.articles = []
                    }
                    
                    Task {
                        do {
                            try await viewModel.getTopIndexes()
                            
                            
                            return
                        } catch {
                            withAnimation {
                                viewModel.errorText = error.localizedDescription
                            }
                        }
                        
                        viewModel.isErrorPopupPresented = true
                    }
                    
                    Task {
                        do {
                            try await viewModel.getMaxIndex()
                            
                            
                            return
                        } catch {
                            withAnimation {
                                viewModel.errorText = error.localizedDescription
                            }
                        }
                        
                        viewModel.isErrorPopupPresented = true
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        //                        Text("ReadBox")
                        //                            .font(.largeTitle)
                        //                            .fontDesign(.rounded)
                        //                            .fontWeight(.light)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .frame(width: UIScreen.main.bounds.width, height: 130)
                                .foregroundStyle(Color(uiColor: .secondarySystemBackground))
                                .padding(.bottom, 40)
                                .shadow(radius: 5)
                            
                            Text("ReadBox")
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
}



#Preview {
    EnFeedView()
}


