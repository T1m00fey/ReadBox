//
//  ReadView.swift
//  Readify
//
//  Created by Тимофей Юдин on 10.11.2024.
//

import SwiftUI

struct TextPart: Hashable {
    let content: String
    let type: PartType
}

enum PartType {
    case title
    case subtitle
    case bold
    case bulletPoint
    case regularText
}

final class ReadViewModel: ObservableObject {
    @Published var timeLeft = 60
    @Published var isPostLiked = false
    @Published var errorText = ""
    @Published var isErrorPopupPresented = false
    @Published var likesCount = 0
    
    @Published var user: DBUser? = nil
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        let user = try await UserManager.shared.getUser(userId: authDataResult.uid)
        
        DispatchQueue.main.async {
            self.user = user
        }
    }
    
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
    
    func parseTextSections(_ text: String) -> [TextPart] {
        // Разделяем текст по двойному переносу строки или "---"
        let paragraphs = text.components(separatedBy: "+++").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        var parts: [TextPart] = []
        
        for paragraph in paragraphs {
            if paragraph.hasPrefix("***") {
                let content = paragraph.replacingOccurrences(of: "***", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                parts.append(TextPart(content: content, type: .title))
            } else if paragraph.hasPrefix("**") {
                let content = paragraph.replacingOccurrences(of: "**", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                parts.append(TextPart(content: content, type: .subtitle))
            } else if paragraph.hasPrefix("*") {
                let content = paragraph.replacingOccurrences(of: "*", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                parts.append(TextPart(content: content, type: .bold))
            } else if paragraph.hasPrefix("-") {
                let content = paragraph.replacingOccurrences(of: "-", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                parts.append(TextPart(content: content, type: .bulletPoint))
            } else if !paragraph.isEmpty {
                parts.append(TextPart(content: paragraph, type: .regularText))
            }
        }
        
        return parts
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
    let title: String
    let text: String
    let image: UIImage
    let dateCreated: Date
    let likesCount: Int
    
    @Binding var likedPosts: [String]
    
    @StateObject var viewModel = ReadViewModel()

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    @Environment(\.dismiss) var dismiss

    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .secondarySystemBackground)
                
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
                                            try await viewModel.removeLikedPost(userId: viewModel.user?.userId ?? "", articleId: id)
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
                                            try await viewModel.addLikedPost(userId: viewModel.user?.userId ?? "", articleId: id)
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
                                
                                switch part.type {
                                case .title:
                                    Text(part.content)
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .padding(.bottom, 8)
                                case .subtitle:
                                    Text(part.content)
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .fontDesign(.rounded)
                                        .padding(.top, 20)
                                case .bold:
                                    Text(part.content)
                                        .font(.body)
                                        .fontWeight(.bold)
                                        .padding(.top, 10)
                                case .bulletPoint:
                                    Text("• " + part.content)
                                        .font(.system(size: 18))
                                        .padding(.leading, 16)
                                        .padding(.top, 5)
                                case .regularText:
                                    Text(part.content)
                                        .font(.system(size: 19))
                                        .padding(.top, 5)
                                    
                                }
                                
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
                    
                    if viewModel.user == nil {
                        Task {
                            try? await viewModel.loadCurrentUser()
                        }
                    }
                }
                .onReceive(timer, perform: { _ in
                    if viewModel.timeLeft > 0 {
                        viewModel.timeLeft -= 1
                    }
                })
                .onDisappear {
                    if viewModel.timeLeft == 0 {
                        if let articlesRead = viewModel.user?.articlesRead, let userId = viewModel.user?.userId {
                            Task {
                                try await viewModel.plusReadArticle(userId: userId, articlesRead: articlesRead)
                            }
                        }
                        
                    }
                }
                .popup(isPresented: $viewModel.isErrorPopupPresented) {
                    Text(viewModel.errorText)
                        .frame(width: UIScreen.main.bounds.width - 72)
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
    ReadView(id: "", title: "", text: "", image: UIImage(), dateCreated: Date(), likesCount: 0, likedPosts: .constant([]))
}


