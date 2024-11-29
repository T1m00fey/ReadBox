//
//  NewPasswordView.swift
//  Readify
//
//  Created by Тимофей Юдин on 31.10.2024.
//

import SwiftUI

struct NewPasswordView: View {
    @Binding var isSuccessPopupPresented: Bool
    @Binding var successText: String
    
    @StateObject var viewModel = NewPasswordViewModel()
    
    @FocusState var isFirstTFFocused: Bool
    @FocusState var isSecondTFFocused: Bool
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isFirstTFFocused = false
                        isSecondTFFocused = false
                    }
                
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(Color(uiColor: .secondarySystemBackground))
                            .frame(width: UIScreen.main.bounds.width - 60, height: 250)
                            .shadow(radius: 2)
                        
                        VStack {
                            Text(LocalizedStringKey("passwordChangeLabel"))
                                .fontDesign(.rounded)
                                .fontWeight(.light)
                                .font(.title)
                                .padding(.top, 30)
                            
                            VStack(spacing: 40) {
                                VStack {
                                    SecureField(LocalizedStringKey("newPasswordTFP"), text: $viewModel.newPassword)
                                        .frame(width: UIScreen.main.bounds.width - 92)
                                        .font(.title2)
                                        .focused($isFirstTFFocused)
                                        .textInputAutocapitalization(.never)
                                        .onChange(of: viewModel.newPassword) { _ in
                                            if viewModel.newPassword.count > 0 {
                                                viewModel.isChangeButtonEnabled()
                                            }
                                        }
                                    
                                    RoundedRectangle(cornerRadius: 0)
                                        .frame(width: UIScreen.main.bounds.width - 92, height: 2)
                                        .foregroundStyle(isFirstTFFocused ? Color(uiColor: .label) : Color(uiColor: .gray))
                                }
                                
                                VStack {
                                    SecureField(LocalizedStringKey("newPasswordAgainTFP"), text: $viewModel.repeatNewPassword)
                                        .frame(width: UIScreen.main.bounds.width - 92)
                                        .font(.title2)
                                        .focused($isSecondTFFocused)
                                        .textInputAutocapitalization(.never)
                                        .onChange(of: viewModel.repeatNewPassword) { _ in
                                            if viewModel.repeatNewPassword.count > 0 {
                                                viewModel.isChangeButtonEnabled()
                                            }
                                        }
                                    
                                    RoundedRectangle(cornerRadius: 0)
                                        .frame(width: UIScreen.main.bounds.width - 92, height: 2)
                                        .foregroundStyle(isSecondTFFocused ? Color(uiColor: .label) : Color(uiColor: .gray))
                                }
                            }
                            .padding(.top, 10)
                            
                            Spacer()
                        }
                        .frame(height: 250)
                    }
                    
                    Button {
                        if viewModel.newPassword == viewModel.repeatNewPassword  {
                            Task {
                                do {
                                    try await viewModel.updatePassword(to: viewModel.newPassword)
                                    
                                    withAnimation {
                                        successText = NSLocalizedString("passwordChangedAlert", comment: "")
                                    }
                                    isSuccessPopupPresented = true
                                    
                                    dismiss()
                                    return
                                } catch {
                                    print("Error: \(error.localizedDescription)")
                                    
                                    withAnimation {
                                        viewModel.errorText = error.localizedDescription
                                    }
                                }
                                
                                viewModel.isErrorPopupPresented = true
                            }
                        } else {
                            withAnimation {
                                viewModel.errorText = NSLocalizedString("passwordsMustMuchAlert", comment: "")
                            }
                            
                            viewModel.isErrorPopupPresented = true
                        }
                    } label: {
                        HStack {
                            Text(LocalizedStringKey("changeButton"))
                                .foregroundStyle(
                                    viewModel.isButtonEnable
                                    ? Color(uiColor: .label)
                                    : Color.gray
                                )
                            
                            if viewModel.isButtonEnable {
                                Text("🤫")
                            }
                        }
                        .frame(width: UIScreen.main.bounds.width - 60, height: 50)
                        .background(Color(uiColor: .secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .font(.title2)
                        .shadow(radius: viewModel.isButtonEnable ? 2 : 0)
                    }
                    .disabled(!viewModel.isButtonEnable)
                    .padding(.top, 10)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "arrow.left")
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
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    NewPasswordView(isSuccessPopupPresented: .constant(false), successText: .constant(""))
}
