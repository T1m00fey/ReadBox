//
//  TestReadView.swift
//  Readify
//
//  Created by Тимофей Юдин on 17.12.2024.
//

import SwiftUI
import SwiftyMarkdown

final class ReadViewModel: ObservableObject {
    @Published var timeLeft = 60
    @Published var isPostLiked = false
    @Published var errorText = ""
    @Published var isErrorPopupPresented = false
    @Published var likesCount = 0
    
    func plusReadArticle(userId: String, articlesRead: Int) async throws {
        try await UserManager.shared.plusReadArticle(userId: userId, articlesRead: articlesRead)
    }
    
    func addLikedPost(userId: String, articleId: String) async throws {
        try await UserManager.shared.addLikedPost(id: userId, likedPost: articleId)
    }
    
    func removeLikedPost(userId: String, articleId: String) async throws {
        try await UserManager.shared.removeLikedPost(id: userId, likedPost: articleId)
    }
    
    func updateLikes(at article: String, likesCount: Int) async throws {
        try await ArticlesManager.shared.updateLikes(at: article, likesCount: likesCount)
    }
    
    func parseTextSections(_ text: String) -> [String] {
        text.components(separatedBy: "+++").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    }
    
    func getMarkdownText(_ text: String) -> AttributedString {
        let markdownString = SwiftyMarkdown(string: text)
        markdownString.bold.fontSize = 30
        markdownString.body.fontStyle = .italic
        markdownString.body.fontSize = 30
        markdownString.blockquotes.fontSize = 30
        markdownString.italic.fontSize = 30
        markdownString.code.fontSize = 30
        markdownString.strikethrough.fontSize = 30
        markdownString.link.fontSize = 30
        
        return AttributedString(markdownString.attributedString())
    }
    
    func getDateCreated(regDate: Date) -> String {
        let timeInterval = Int(Date().timeIntervalSince(regDate)) / 60 / 60 / 24
        var date = ""
        
        if StorageManager.shared.getLanguage() == "ru" {
            if timeInterval > 30 && timeInterval < 365 {
                if timeInterval / 30 == 1 {
                    date = "\(timeInterval / 30) месяц назад"
                } else if (2...4).contains(timeInterval / 30) {
                    date = "\(timeInterval / 30) месяца назад"
                } else {
                    date = "\(timeInterval / 30) месяцев назад"
                }
            } else if timeInterval >= 365 {
                if (11...14).contains(timeInterval / 365) {
                    date = "\(timeInterval / 365) лет назад"
                } else if timeInterval / 365 % 10 == 1 {
                    date = "\(timeInterval / 365) год назад"
                } else if timeInterval / 365 % 10 == 2 || timeInterval / 365 % 10 == 4 || timeInterval / 365 % 10 == 3 {
                    date = "\(timeInterval) года назад"
                } else {
                    date = "\(timeInterval) лет назад"
                }
            } else {
                if timeInterval == 11 || timeInterval == 12 || timeInterval == 13 || timeInterval == 14 {
                    date = "\(timeInterval) дней назад"
                } else if timeInterval % 10 == 1 {
                    date = "\(timeInterval) день назад"
                } else if timeInterval % 10 == 2 || timeInterval % 10 == 4 || timeInterval % 10 == 3 {
                    date = "\(timeInterval) дня назад"
                } else if timeInterval == 0 {
                    date = "Сегодня"
                } else {
                    date = "\(timeInterval) дней назад"
                }
            }
            
        } else {
            if timeInterval > 30 && timeInterval < 365 {
                if timeInterval / 30 == 1 {
                    date = "\(timeInterval / 30) month ago"
                } else {
                    date = "\(timeInterval / 30) months ago"
                }
            } else if timeInterval >= 365 {
                if timeInterval / 365 == 1 {
                    date = "\(timeInterval / 365) year ago"
                } else {
                    date = "\(timeInterval / 365) years ago"
                }
            } else {
                if timeInterval == 1 {
                    date = "\(timeInterval) day ago"
                } else if timeInterval == 0 {
                    date = "Today"
                } else {
                    date = "\(timeInterval) days ago"
                }
            }
        }
        
        return date
    }
}

struct ReadView: View {
    let id: String
    let userId: String
    let title: String
    let text: String
    let image: UIImage
    let dateCreated: Date
    let likesCount: Int
    
    @Binding var articlesRead: Int
    @Binding var likedPosts: [String]
    
    @StateObject var viewModel = ReadViewModel()

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .secondarySystemBackground)
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    
                    VStack {
                        
                        Text(title)
                            .fontWeight(.light)
                            .fontDesign(.rounded)
                            .font(.largeTitle)
                            .frame(width: UIScreen.main.bounds.width - 32, alignment: .leading)
                        
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: UIScreen.main.bounds.width - 20)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                        HStack {
                            Text(viewModel.getDateCreated(regDate: dateCreated))
                                .font(.title2)
                                .fontWeight(.light)
                                .fontDesign(.rounded)
                                .foregroundStyle(Color.gray)
                            
                            Spacer()
                            
                            Button {
                                if viewModel.isPostLiked {
                                    withAnimation {
                                        viewModel.isPostLiked.toggle()
                                    }
                                    
                                    likedPosts.removeAll {
                                        id == $0
                                    
                                    }
                                    
                                    viewModel.likesCount -= 1
                                    
                                    print(likedPosts)
                                    
                                    Task {
                                        do {
                                            try await viewModel.removeLikedPost(userId: userId, articleId: id)
                                            try await viewModel.updateLikes(at: id, likesCount: viewModel.likesCount)
                                            return
                                        } catch {
                                            withAnimation {
                                                viewModel.errorText = error.localizedDescription
                                            }
                                        }
                                        
                                        viewModel.isErrorPopupPresented = true
                                    }
                                } else {
                                    withAnimation {
                                        viewModel.isPostLiked.toggle()
                                    }
                                    
                                    viewModel.likesCount += 1
                                    
                                    likedPosts.append(id)
                                    print(likedPosts)
                                    print("APPEND")
                                    
                                    Task {
                                        do {
                                            try await viewModel.addLikedPost(userId: userId, articleId: id)
                                            try await viewModel.updateLikes(at: id, likesCount: viewModel.likesCount)
                                            return
                                        } catch {
                                            withAnimation {
                                                viewModel.errorText = error.localizedDescription
                                            }
                                        }
                                        
                                        viewModel.isErrorPopupPresented = true
                                    }
                                }
                            } label: {
                                Image(systemName: viewModel.isPostLiked ? "hand.thumbsup.fill" : "hand.thumbsup")
                                    .scaleEffect(1.2)
                                    .frame(width: 50, height: 50)
                                    .background(Color(uiColor: .systemBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .shadow(radius: 2)
                            }
                        }
                        .frame(width: UIScreen.main.bounds.width - 32)
                        
                        
                        VStack(alignment: .leading) {
                            ForEach(viewModel.parseTextSections(text), id: \.self) { part in
                                Text(
                                    viewModel.getMarkdownText(part)
                                )
                                .fontDesign(.rounded)
                                .padding(.top, 15)
                            }
                        }
                        .padding(.horizontal, 16)
                        
                    }
                    
                }
                .onAppear {
                    withAnimation {
                        viewModel.isPostLiked = likedPosts.contains(id)
                    }
                    
                    viewModel.likesCount = likesCount
                    
                    viewModel.timeLeft = 60
                }
                .onReceive(timer, perform: { _ in
                    if viewModel.timeLeft > 0 {
                        viewModel.timeLeft -= 1
                    }
                })
                .onDisappear {
                    if viewModel.timeLeft == 0 {
                        Task {
                            try await viewModel.plusReadArticle(userId: userId, articlesRead: articlesRead)

                        }
                        articlesRead += 1
                    }
                }
                .popup(isPresented: $viewModel.isErrorPopupPresented) {
                    Text(viewModel.errorText)
                        .frame(width: UIScreen.main.bounds.width - 72, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .foregroundStyle(Color.white)
                        .background(Color.red)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } customize: {
                    $0
                        .type(.floater())
                        .position(.top)
                        .animation(.bouncy)
                        .dragToDismiss(true)
                        .autohideIn(5)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                        }
                        
//                        ZStack {
//                            RoundedRectangle(cornerRadius: 30)
//                                .frame(width: UIScreen.main.bounds.width, height: 120)
//                                .foregroundStyle(Color(uiColor: .systemBackground))
//                                .padding(.bottom, 30)
//                                .shadow(radius: 3)
//
//                            Image(systemName: "xmark")
//                                .frame(width: UIScreen.main.bounds.width - 32, alignment: .trailing)
//                                .onTapGesture {
//                                    dismiss()
//                                }
//                        }
//                        .padding(.leading, 5)
                        
                    }
                }
                .background(Color(uiColor: .secondarySystemBackground))
                
            }
            .navigationBarBackButtonHidden()
        }
    }
}

#Preview {
    ReadView(id: "", userId: "", title: "", text: "", image: UIImage(), dateCreated: Date(), likesCount: 0, articlesRead: .constant(0), likedPosts: .constant([]))
}


