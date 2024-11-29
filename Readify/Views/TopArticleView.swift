//
//  TopArticleView.swift
//  Readify
//
//  Created by Тимофей Юдин on 06.11.2024.
//

import SwiftUI
import FirebaseStorage

struct TopArticleView: View {
    let id: String
    let title: String?
    let isPremium: Bool?
    
    @State private var image: UIImage? = nil
    
    private func fetchImage() {
        let articleImage = StorageManager.shared.getImage(id: id)
        
        if articleImage != nil {
            image = articleImage
            print("Loaded from user defaults")
        } else {
            let storage = Storage.storage()
            let storageRef = storage.reference()
            
            let islandRef = storageRef.child("images/\(id).jpg")

            islandRef.getData(maxSize: 1 * 5012 * 5012) { data, error in
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
    
    var body: some View {
        ZStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width - 10)
                    .frame(maxHeight: 250)
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(radius: 2)
                
                VStack {
                    if let isPremium = isPremium {
                        if isPremium {
                            Image(systemName: "crown")
                                .scaleEffect(1.3)
                                .frame(width: UIScreen.main.bounds.width - 42, alignment: .trailing)
                                .foregroundStyle(Color.white)
                                .bold()
                                .shadow(color: Color.black, radius: 1)
                        }
                    }
                    
                    Spacer()
                    
                    if let title = title {
                        Text(title)
                            .font(.title3)
                            .fontWeight(.bold)
                            .fontDesign(.rounded)
                            .foregroundStyle(Color.white)
                            .shadow(color: Color.black, radius: 5)
                            .frame(width: UIScreen.main.bounds.width - 42, alignment: .bottomLeading)
                    }
                }
                .frame(height: 200)
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: UIScreen.main.bounds.width - 10, height: 250)
                        .foregroundStyle(Color(uiColor: .secondarySystemBackground))
                        
                    ProgressView()
                }
            }
        }
        .onAppear {
            fetchImage()
        }
    }
}

#Preview {
    TopArticleView(id: "", title: "", isPremium: false)
}
