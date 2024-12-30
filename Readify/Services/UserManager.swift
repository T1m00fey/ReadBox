//
//  UserManager.swift
//  Readify
//
//  Created by Тимофей Юдин on 27.10.2024.
//

import Foundation
import FirebaseFirestore

struct DBUser: Codable, Equatable {
    let userId: String
    let name: String?
    let email: String?
    let dateCreated: Date?
    let likedPosts: [String]?
    let articlesRead: Int?
    
    init(auth: AuthDataResultModel) {
        self.userId = auth.uid
        self.name = ""
        self.email = auth.email
        self.dateCreated = Date()
        self.likedPosts = []
        self.articlesRead = 0
    }
    
    init(
        userId: String,
        name: String? = nil,
        email: String? = nil,
        dateCreated: Date? = nil,
        likedPosts: [String]? = nil,
        articlesRead: Int = 0
    ) {
        self.userId = userId
        self.name = name
        self.email = email
        self.dateCreated = dateCreated
        self.likedPosts = likedPosts
        self.articlesRead = articlesRead
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "id"
        case name = "name"
        case email = "email"
        case dateCreated = "date_created"
        case likedPosts = "liked_posts"
        case articlesRead = "articles_read"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.name = try container.decode(String.self, forKey: .name)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        self.likedPosts = try container.decodeIfPresent([String].self, forKey: .likedPosts)
        self.articlesRead = try container.decodeIfPresent(Int.self, forKey: .articlesRead)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userId, forKey: .userId)
        try container.encode(self.name, forKey: .name)
        try container.encodeIfPresent(self.email, forKey: .email)
        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
        try container.encodeIfPresent(self.likedPosts, forKey: .likedPosts)
        try container.encodeIfPresent(self.articlesRead, forKey: .articlesRead)
    }
}

final class UserManager {
    
    static let shared = UserManager()
    private init() {}
    
    private let userCollection = Firestore.firestore().collection("users")
    
    private let encoder: Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        return encoder
    }()
    
    private let decoder: Firestore.Decoder = {
        let decoder = Firestore.Decoder()
        return decoder
    }()
    
    private func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }
    
    func createNewUser(user: DBUser) async throws {
        try userDocument(userId: user.userId).setData(from: user, merge: false)
    }
    
    func deleteUser(user: DBUser) async throws {
        try await userDocument(userId: user.userId).delete()
    }
    
    func getUser(userId: String) async throws -> DBUser {
        try await userDocument(userId: userId).getDocument(as: DBUser.self)
    }
    
//    func updatePremiumStatus(user: DBUser) async throws {
//        try userDocument(userId: user.userId).setData(from: user, merge: true)
//    }
    
    func plusReadArticle(userId: String, articlesRead: Int) async throws {
        let data: [String: Any] = [
            "articles_read": articlesRead + 1
        ]
        
        try await userDocument(userId: userId).updateData(data)
    }
    
    func addLikedPost(id: String, likedPost: String) async throws {
        let data: [String: Any] = [
            "liked_posts": FieldValue.arrayUnion([likedPost])
        ]
        
        try await userDocument(userId: id).updateData(data)
    }
    
    func removeLikedPost(id: String, likedPost: String) async throws {
        let data: [String: Any] = [
            "liked_posts": FieldValue.arrayRemove([likedPost])
        ]
        
        try await userDocument(userId: id).updateData(data)
    }
    
    func changeName(userID: String, to name: String) async throws {
        let data: [String: Any] = [
            "name": name
        ]
        
        try await userDocument(userId: userID).updateData(data)
    }
    
    
}
