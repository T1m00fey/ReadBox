//
//  EnFeedView.swift
//  Readify
//
//  Created by Тимофей Юдин on 13.11.2024.
//

import SwiftUI
import FirebaseStorage

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
                            
                            ForEach(viewModel.topArticles) { article in
                                TopArticleView(id: article.id, title: article.enTitle, isPremium: article.isPremium)
                                    .onTapGesture {
                                        viewModel.description = article.enDescription ?? ""
                                        viewModel.title = article.enTitle ?? ""
                                        viewModel.text = article.enText ?? ""
                                        viewModel.image = StorageManager.shared.getImage(id: article.id) ?? UIImage()
                                        viewModel.dateCreated = article.dateCreated ?? Date()
                                        viewModel.likesCount = article.likesCount ?? 0
                                        viewModel.id = article.id
                                        
                                        if viewModel.user != nil {
                                            if viewModel.likedPosts == [] && viewModel.articlesRead == 0 {
                                                viewModel.likedPosts = viewModel.user?.likedPosts ?? []
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
                                    .tabItem {}
                            }
                            
                        }
                        .tabViewStyle(.page)
                        .frame(height: 270)
                        .padding(.top, 20)
                        
                        ForEach(viewModel.articles) { article in
                            ArticleView(
                                id: article.id,
                                title: article.enTitle,
                                isPremium: article.isPremium
                            )
                            .padding(.top, 10)
                            .onTapGesture {
                                viewModel.description = article.enDescription ?? "Not found"
                                viewModel.title = article.enTitle ?? "Not found"
                                viewModel.text = article.enText ?? "Not found"
                                viewModel.image = StorageManager.shared.getImage(id: article.id) ?? UIImage()
                                viewModel.dateCreated = article.dateCreated ?? Date()
                                viewModel.likesCount = article.likesCount ?? 0
                                viewModel.id = article.id
                                
                                if viewModel.user != nil {
                                    if viewModel.likedPosts == [] && viewModel.articlesRead == 0 {
                                        viewModel.likedPosts = viewModel.user?.likedPosts ?? []
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
                            
                        }
                        
                        if viewModel.articles != [] && viewModel.fromIndex >= 0 {
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
                                        .fontWeight(.light)
                                    
                                    Text(LocalizedStringKey("loadMore"))
                                        .font(.title3)
                                        .fontDesign(.rounded)
                                        .fontWeight(.light)
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
                        try? await viewModel.loadUser()
                    }
                    
                    if viewModel.maxIndex == "" && viewModel.fromIndex == -1 {
                        Task {
                            do {
                                try await viewModel.getMaxIndex()
                                viewModel.fromIndex = Int(viewModel.maxIndex) ?? 15
                                return
                            } catch {
                                withAnimation {
                                    viewModel.errorText = error.localizedDescription
                                }
                            }
                            
                            viewModel.isErrorPopupPresented = true
                        }
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
                .refreshable {
                    withAnimation {
                        
                        viewModel.topArticlesIndexes = []
                        viewModel.topArticles = []
                        viewModel.articles = []
                    }
                    
                    Task {
                        do {
                            try await viewModel.getTopIndexes()
                            viewModel.fromIndex = Int(viewModel.maxIndex) ?? 15
                            return
                        } catch {
                            withAnimation {
                                viewModel.errorText = error.localizedDescription
                            }
                        }
                        
                        viewModel.isErrorPopupPresented = true
                    }
                    
                    Task {
                        try? await viewModel.loadUser()
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




