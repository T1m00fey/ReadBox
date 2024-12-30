//
//  ArticlesManager.swift
//  Readify
//
//  Created by Тимофей Юдин on 05.11.2024.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

struct ArticleImage: Codable {
    let id: String
    let image: Data?
}

struct EnArticle: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let dateCreated: Date?
    let enTitle: String?
    let enText: String?
    let enDescription: String?
    let likesCount: Int?
    let isPremium: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case dateCreated = "date_created"
        case enTitle = "en_title"
        case enText = "en_text"
        case enDescription = "en_description"
        case likesCount = "likes_count"
        case isPremium = "is_premium"
    }
}

struct RuArticle: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let dateCreated: Date?
    let ruTitle: String?
    let ruText: String?
    let ruDescription: String?
    let likesCount: Int?
    let isPremium: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case dateCreated = "date_created"
        case ruTitle = "ru_title"
        case ruText = "ru_text"
        case ruDescription = "ru_description"
        case likesCount = "likes_count"
        case isPremium = "is_premium"
    }
}

struct TopArticlesIndexes: Codable {
    let topArticlesIndexes: [String]?
    
    enum CodingKeys: String, CodingKey {
        case topArticlesIndexes = "top_articles_indexes"
    }
}

struct MaxIndex: Codable {
    let maxIndex: String
    
    enum CodingKeys: String, CodingKey {
        case maxIndex = "max_index"
    }
}

final class ArticlesManager {
    static let shared = ArticlesManager()
    private init() {}
    
    private let articlesCollection = Firestore.firestore().collection("articles")
    
    private func articleDocument(id: String) -> DocumentReference {
        articlesCollection.document(id)
    }
    
    func getRuArticle(id: String) async throws -> RuArticle {
        try await articleDocument(id: id).getDocument(as: RuArticle.self)
    }
    
    func getEnArticle(id: String) async throws -> EnArticle {
        try await articleDocument(id: id).getDocument(as: EnArticle.self)
    }
    
    func getTopArticlesIndexes() async throws -> [String]? {
        let topArticlesIndexes = try await Firestore.firestore().collection("topArticlesIndexes").document("0").getDocument(as: TopArticlesIndexes.self)
        
        return topArticlesIndexes.topArticlesIndexes
    }
    
    func updateLikes(at articleId: String, likesCount: Int) async throws {
        let data: [String: Any] = [
            "likes_count": likesCount
        ]
        
        try await articleDocument(id: articleId).updateData(data)
    }
    
    func getAllEnArticles() async throws -> [EnArticle?] {
        let snapshot = try await articlesCollection.getDocuments()
        
        var articles: [EnArticle] = []
        
        for document in snapshot.documents {
            let article = try document.data(as: EnArticle.self)
            articles.append(article)
        }
        
        return articles
    }
    
    func getAllRuArticles() async throws -> [RuArticle?] {
        let snapshot = try await articlesCollection.getDocuments()
        
        var articles: [RuArticle] = []
        
        for document in snapshot.documents {
            let article = try document.data(as: RuArticle.self)
            articles.append(article)
        }
        
        return articles
    }
    
    func getMaxIndex() async throws -> String? {
        let maxIndex = try await Firestore.firestore().collection("maxIndex").document("0").getDocument(as: MaxIndex.self)
        
        return maxIndex.maxIndex
    }
}
