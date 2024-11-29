//
//  DescriptionView.swift
//  Readify
//
//  Created by Тимофей Юдин on 10.11.2024.
//

import SwiftUI

struct DescriptionView: View {
    @Binding var isReadViewPresented: Bool
    
    let description: String
    
    var body: some View {
        VStack {
            Capsule()
                .frame(width: 25, height: 5)
                .foregroundStyle(Color.gray)
                .padding(.top, 5)
            
            Text(LocalizedStringKey("descriptionLabel"))
                .frame(width: UIScreen.main.bounds.width - 32, alignment: .leading)
                .font(.title)
                .fontWeight(.light)
                .fontDesign(.rounded)
                .padding(.top, 10)
            
            Text(description)
                .frame(width: UIScreen.main.bounds.width - 32, alignment: .leading)
                .font(.title3)
                .padding(.top, 5)
            
            Button {
                isReadViewPresented = true
            } label: {
                
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: UIScreen.main.bounds.width - 40, height: 50)
                        .foregroundStyle(Color(uiColor: .systemBackground))
                        .shadow(radius: 2)
                    
                    Text(LocalizedStringKey("readButton"))
                        .font(.title2)
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 100)
        }
        .frame(width: UIScreen.main.bounds.width)
        .frame(minHeight: 100)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 30))
    }
}

#Preview {
    DescriptionView(isReadViewPresented: .constant(true), description: "")
}
