//
//  StorageManager.swift
//  Readify
//
//  Created by Тимофей Юдин on 09.11.2024.
//

import SwiftUI

final class StorageManager {
    static let shared = StorageManager()
    private init() {}
    
    private let userDefaults = UserDefaults.standard
    
    func saveImage(id: String, image: UIImage) {
        let article = ArticleImage(id: id, image: image.jpegData(compressionQuality: 1))
        
        guard let data = try? JSONEncoder().encode(article) else { return }
        userDefaults.set(data, forKey: id)
    }
    
    func getImage(id: String) -> UIImage? {
        guard let data = userDefaults.data(forKey: id) else { return nil }
        guard let articleImage = try? JSONDecoder().decode(ArticleImage.self, from: data) else { return nil }
        
        if let imageData = articleImage.image {
            return UIImage(data: imageData)
        } else {
            return nil
        }
    }
    
    func setLanguage(to language: String) {
        userDefaults.set(language, forKey: "language")
    }
    
    func getLanguage() -> String {
        userDefaults.string(forKey: "language") ?? ""
    }
}
