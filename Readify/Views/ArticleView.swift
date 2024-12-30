//
//  ArtcleView.swift
//  Readify
//
//  Created by Тимофей Юдин on 05.11.2024.
//

import SwiftUI
import FirebaseStorage

struct ArticleView: View {
    let id: String
    let title: String?
    let isPremium: Bool?
    
    @State private var image: UIImage? = nil
    
    private func fetchImage() {
        let articleImage = StorageManager.shared.getImage(id: id)
        
        if articleImage != nil {
            image = articleImage
        } else {
            DispatchQueue.main.async {
                let storage = Storage.storage()
                let storageRef = storage.reference()
                
                let islandRef = storageRef.child("images/\(id).jpg")
                
                islandRef.getData(maxSize: 1 * 5012 * 50125) { data, error in
                    if let error = error {
                        print(error .localizedDescription)
                    } else {
                        // Data for "images/island.jpg" is returned
                        self.image = UIImage(data: data!)
                        StorageManager.shared.saveImage(id: id, image: image ?? UIImage())
                    }
                }
            }
        }
    }
    
    
    var body: some View {
        
        VStack(spacing: -45) {
            if let image = image {
                ZStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width - 10)
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                        .padding(.top, 16)
                        .shadow(radius: 2)
                    
//                    if let isPremium {
//                        if isPremium {
//                            Image(systemName: "crown")
//                                .scaleEffect(1.3)
//                                .frame(width: UIScreen.main.bounds.width - 42, height: 200, alignment: .topTrailing)
//                                .foregroundStyle(Color.white)
//                                .bold()
//                                .shadow(color: Color.black, radius: 1)
//                        }
//                    }
                }
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 30)
                        .frame(width: UIScreen.main.bounds.width - 10, height: 250)
                        .foregroundStyle(Color(uiColor: .secondarySystemBackground))
                    
                    ProgressView()
                }
            }
            
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .frame(width: UIScreen.main.bounds.width - 10)
                    .shadow(radius: 2)
                    .foregroundStyle(Color(uiColor: .secondarySystemBackground))
                
                Text(title ?? "")
                    .font(.title3)
                    .fontDesign(.rounded)
                    .frame(width: UIScreen.main.bounds.width - 42, alignment: .leading)
                    .padding(.vertical, 20)
            }
            
        }
        .onAppear{
            if image == nil {
                fetchImage()
            }
        }
        
    }
}

#Preview {
    ArticleView(id: "1", title: "", isPremium: true)
}
