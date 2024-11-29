//
//  ProfileView.swift
//  Readify
//
//  Created by Тимофей Юдин on 29.10.2024.
//

import SwiftUI

struct ProfileView: View {
    @Binding var isSignInViewPresented: Bool
    
    @StateObject var viewModel = ProfileViewModel()
    
    @State private var isPremiumViewPresented = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()
                ScrollView {
                    VStack {
                        HStack(spacing: 20) {
                            daysWithApp
                            
                            articlesRead
                        }
                        .padding(.top, 20)
                        
                        VStack {
                            Text(LocalizedStringKey("settingsLabel"))
                                .font(.title)
                                .fontWeight(.light)
                                .frame(width: UIScreen.main.bounds.width - 32, alignment: .leading)
                            
                            if let _ = viewModel.user {
                                Button {
//                                    isPremiumViewPresented = true
                                } label: {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundStyle(Color(uiColor: .secondarySystemBackground))
                                            .shadow(radius: 2)
                                        
                                        HStack {
                                            Image(systemName: "crown")
                                            
                                            Spacer()
                                            
                                            Text("Premium")
                                                .font(.title)
                                                .fontWeight(.light)
                                            
                                            Spacer()
                                            
                                            Image(systemName: "crown")
                                        }
                                        .padding(.horizontal, 16)
                                    }
                                }
                                .navigationDestination(isPresented: $isPremiumViewPresented, destination: {
                                    
                                })
                                .frame(width: UIScreen.main.bounds.width - 32, height: 60)
                                
                                NavigationLink(destination: NewNameView(isSuccessPopupPresented: $viewModel.isSuccessPopupPresented, successText: $viewModel.successText, userID: viewModel.user?.userId)) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundStyle(Color(uiColor: .secondarySystemBackground))
                                            .shadow(radius: 2)
                                        
                                        HStack {
                                            Image(systemName: "person.circle.fill")
                                                .foregroundStyle(Color.gray)
                                                .font(.system(size: 35))
                                            
                                            Text(LocalizedStringKey("nameLabel"))
                                                .font(.title3)
                                                .fontWeight(.light)
                                            
                                            Spacer()
                                            
                                            Image(systemName: "chevron.right")
                                                .font(.title2)
                                                .foregroundStyle(Color.gray)
                                        }
                                        .padding(.horizontal, 16)
                                    }
                                }
                                .frame(width: UIScreen.main.bounds.width - 32, height: 60)
                                .padding(.top, 20)
                                
                                NavigationLink {
                                    NewPasswordView(isSuccessPopupPresented: $viewModel.isSuccessPopupPresented, successText: $viewModel.successText)
                                } label: {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundStyle(Color(uiColor: .secondarySystemBackground))
                                            .shadow(radius: 2)
                                        
                                        HStack {
                                            Image(systemName: "lock.circle.fill")
                                                .foregroundStyle(Color.blue)
                                                .font(.system(size: 35))
                                            
                                            Text(LocalizedStringKey("passwordTFPlaceholder"))
                                                .font(.title3)
                                                .fontWeight(.light)
                                            
                                            Spacer()
                                            
                                            Image(systemName: "chevron.right")
                                                .font(.title2)
                                                .foregroundStyle(Color.gray)
                                        }
                                        .padding(.horizontal, 16)
                                    }
                                }
                                .frame(width: UIScreen.main.bounds.width - 32, height: 60)
                                
//                                Button {
//                                    viewModel.isLanguagePopupPresented = true
//                                } label: {
//                                    ZStack {
//                                        RoundedRectangle(cornerRadius: 10)
//                                            .foregroundStyle(Color(uiColor: .secondarySystemBackground))
//                                            .shadow(radius: 2)
//                                        
//                                        HStack {
//                                            Image(systemName: "flag.circle.fill")
//                                                .foregroundStyle(Color.green)
//                                                .font(.system(size: 35))
//                                            
//                                            Text(LocalizedStringKey("languageLabel"))
//                                                .font(.title3)
//                                                .fontWeight(.light)
//                                            
//                                            Spacer()
//                                            
//                                            Image(systemName: "chevron.right")
//                                                .font(.title2)
//                                                .foregroundStyle(Color.gray)
//                                        }
//                                        .padding(.horizontal, 16)
//                                    }
//                                }
//                                .frame(width: UIScreen.main.bounds.width - 32, height: 60)

                            }
                            
                            HStack {
                                Button {
                                    viewModel.isSignOutDialogPresented = true
                                } label: {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundStyle(Color(uiColor: .secondarySystemBackground))
                                            .frame(width: (UIScreen.main.bounds.width - 50) / 2, height: 60)
                                            .shadow(radius: 2)
                                        
                                        HStack {
                                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                                .font(.system(size: 20))
                                                .foregroundStyle(Color.red)
                                            
                                            Text(LocalizedStringKey("signOutLabel"))
                                                .foregroundStyle(Color.red)
                                                .fontWeight(.light)
                                                .font(.title3)
                                        }
                                    }
                                }
                                
                                Spacer()
                                
                                Button {
                                    viewModel.isDeleteAccDialogPresented = true
                                } label: {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundStyle(Color(uiColor: .secondarySystemBackground))
                                            .frame(width: (UIScreen.main.bounds.width - 50) / 2, height: 60)
                                            .shadow(radius: 2)
                                        
                                        HStack {
                                            Image(systemName: "xmark.circle")
                                                .font(.system(size: 20))
                                                .foregroundStyle(Color.red)
                                            
                                            Text(LocalizedStringKey("deleteLabel"))
                                                .foregroundStyle(Color.red)
                                                .fontWeight(.light)
                                                .font(.title3)
                                        }
                                    }
                                }
                            }
                            .frame(width: UIScreen.main.bounds.width - 32)
                            .padding(.top, 5)
                            
                            Spacer()
                        }
                        .padding(.top, 20)
                        
                    }
                    .frame(width: UIScreen.main.bounds.width)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
//                            Text(viewModel.user?.name ?? "")
//                                .font(.largeTitle)
//                                .fontWeight(.light)
//                                .fontDesign(.rounded)
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .frame(width: UIScreen.main.bounds.width, height: 130)
                                    .foregroundStyle(Color(uiColor: .secondarySystemBackground))
                                    .padding(.bottom, 40)
                                    .shadow(radius: 5)
                                
                                Text(viewModel.user?.name ?? "")
                                    .font(.largeTitle)
                                    .fontWeight(.light)
                                    .fontDesign(.rounded)
                                    .frame(width: UIScreen.main.bounds.width - 32, alignment: .leading)
                            }
                            .padding(.leading, 6)
                        }
                    }
                    .onAppear {
                        if viewModel.user == nil {
                            Task {
                                try? await viewModel.loadCurrentUser()
                            }
                        }
                    }
                }
                .padding(.top, 20)
                .refreshable {
                    Task {
                        try? await viewModel.loadCurrentUser()
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
                        .padding(.top, 20)
                } customize: {
                    $0
                        .type(.floater())
                        .position(.top)
                        .animation(.bouncy)
                        .dragToDismiss(true)
                        .autohideIn(5)
                }
                .confirmationDialog("", isPresented: $viewModel.isDeleteAccDialogPresented) {
                    Button(LocalizedStringKey("deleteLabel"), role: .destructive) {
                        Task {
                            do {
                                try await viewModel.delete()
                                isSignInViewPresented = true
                                return
                            } catch {
                                withAnimation {
                                    viewModel.errorText = error.localizedDescription
                                }
                            }
                            
                            viewModel.isErrorPopupPresented = true
                        }
                    }
                    
                    Button(LocalizedStringKey("cancelButton"), role: .cancel) {}
                } message: {
                    Text(LocalizedStringKey("youSureToDeleteAcc"))
                }
                .confirmationDialog("", isPresented: $viewModel.isSignOutDialogPresented) {
                    Button(LocalizedStringKey("signOutLabel"), role:.destructive) {
                        Task {
                            do {
                                try viewModel.signOut()
                                isSignInViewPresented.toggle()
                                return
                            } catch {
                                withAnimation {
                                    viewModel.errorText = error.localizedDescription
                                }
                            }
                            
                            viewModel.isErrorPopupPresented = true
                        }
                    }
                    
                    Button(LocalizedStringKey("cancelButton"), role: .cancel) {}
                } message: {
                    Text(LocalizedStringKey("youSureToSingOut"))
                }
                .popup(isPresented: $viewModel.isSuccessPopupPresented) {
                    Text(viewModel.successText)
                        .frame(width: UIScreen.main.bounds.width - 72)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .foregroundStyle(Color.white)
                        .background(Color.green)
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
            }
        }
    }
}

#Preview {
    ProfileView(isSignInViewPresented: .constant(false))
}

private extension ProfileView {
    var daysWithApp: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(Color(uiColor: .secondarySystemBackground))
                .frame(width: (UIScreen.main.bounds.width - 50) / 2, height: 120)
                .shadow(radius: 2)
            
            VStack(spacing: 10) {
                Text(LocalizedStringKey("youWithUsLabel"))
                    .font(.title3)
                    .foregroundStyle(Color.gray)
                
                Text("\(viewModel.getDays(regDate: viewModel.user?.dateCreated))")
                    .font(.title)
                    .bold()
                
                Text("\(viewModel.getStringOf(days: viewModel.getDays(regDate: viewModel.user?.dateCreated)))")
                    .font(.title3)
                    .foregroundStyle(Color.gray)
            }
        }
    }
    
    var articlesRead: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(Color(uiColor: .secondarySystemBackground))
                .frame(width: (UIScreen.main.bounds.width - 50) / 2, height: 120)
                .shadow(radius: 2)
            
            VStack(spacing: 10) {
                Text(LocalizedStringKey("readArticlesLabel"))
                    .font(.title3)
                    .foregroundStyle(Color.gray)
                
                Text("\(viewModel.user?.articlesRead ?? 0)")
                    .font(.title)
                    .bold()
                
                Text("\(viewModel.getStringOf(articlesRead: viewModel.user?.articlesRead ?? 0))")
                    .font(.title3)
                    .foregroundStyle(Color.gray)
            }
        }
    }
}
