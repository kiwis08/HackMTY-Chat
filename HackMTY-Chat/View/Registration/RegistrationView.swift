//
//  RegistrationView.swift
//  HackMTY-Chat
//
//  Created by Santiago Quihui on 28/08/21.
//

import SwiftUI
import Firebase

struct RegistrationView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var email: String
    @Binding var username: String
    @Binding var password1: String
    @Binding var password2: String
    
    @Binding var errorModel: ErrorModel?
    
    var countries: [String]
    @Binding var country: String

    @Binding var selectedTab: RegistrationViews.Tabs
    
    
    var body: some View {
        VStack {
            
            Text("Welcome")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
            
            Picker(country, selection: $country.animation()) {
                ForEach(countries, id: \.self) { country in
                    Text(country)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.6))
            .cornerRadius(10)
            .pickerStyle(MenuPickerStyle())
            .padding(.horizontal)
            
            if countries.contains(country) {
                
                LoginNameTextField(placeholder: "Username", text: $username)
                
                LoginEmailTextField(placeholder: "Email address", text: $email)
                
                LoginPasswordTextField(placeholder: "Enter your password", text: $password1)
                
                LoginPasswordTextField(placeholder: "Re-enter your password", text: $password2)
            }
            Spacer()
            
            Button("Continue") {
                guard verifyEmail(email) else {
                    self.errorModel = ErrorModel(title: "Check your email address", message: "Please check you entered a valid email address")
                    return
                }
                guard password1 == password2 else {
                    self.errorModel = ErrorModel(title: "Error", message: "Password does not match")
                    return
                }
                selectedTab = .second
            }.buttonStyle(BlueButton())
            .padding()
            
            Spacer()
        }
        .alert(item: $errorModel) {
            Alert(title: Text($0.title), message: Text($0.message), dismissButton: .default(Text("OK"), action: {
//                if validEmail {
//                    presentationMode.wrappedValue.dismiss()
//                }
            }))
        }
    }
    
    func verifyEmail(_ email: String) -> Bool {
        return email.contains("@") && email.contains(".")
    }
    
    
    
    func getSchools(for country: String, completion: @escaping ([School]) -> Void) {
        let url = URL(string: "http://universities.hipolabs.com/search?country=\(country)")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            do {
//                let json = try JSONSerialization.jsonObject(with: data, options: [])
                let decoder = JSONDecoder()
                let countries = try decoder.decode([School].self, from: data)
                completion(countries)
            } catch {
                print("JSON Error: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    func suggestedSchool(for email: String, from schools: [School]) -> School? {
        let atIndex = email.lastIndex(of: "@")!
        var domain = email.suffix(from: atIndex)
        domain.removeFirst()
        var suggested: School? = nil
        for _ in schools {
            suggested = schools.first(where: { $0.domains.contains(String(domain))}) ?? nil
        }
        return suggested
    }
}

//struct RegistrationView_Previews: PreviewProvider {
//    static var previews: some View {
//        RegistrationView()
//    }
//}

