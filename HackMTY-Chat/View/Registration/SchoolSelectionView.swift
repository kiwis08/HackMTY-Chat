//
//  SchoolSelectionView.swift
//  HackMTY-Chat
//
//  Created by Santiago Quihui on 28/08/21.
//

import SwiftUI
import Firebase

struct SchoolSelectionView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var username: String
    @Binding var email: String
    @Binding var password: String
    
    @Binding var country: String
    var countries: [String]
    @State private var schools = [School]()
    @State private var selectedSchool: School = School.example
    @State private var major: String = ""
    
    @State private var errorModel: ErrorModel? = nil
    
    @Binding var selectedTab: RegistrationViews.Tabs
    
    
    var body: some View {
        VStack {
            Text("Select your school")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .padding()
            Picker(selectedSchool.name, selection: $selectedSchool) {
                ForEach(schools, id: \.self) { school in
                    Text(school.name)
                        .lineLimit(nil)
                        .tag(school)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.6))
            .cornerRadius(10)
            .pickerStyle(MenuPickerStyle())
            .padding(.horizontal)
            
            MajorTextField(placeholder: "What's your major?", text: $major)
            
            Button("Continue") {
                guard major.count >= 2 && major.count <= 4 else {
                    self.errorModel = ErrorModel(message: "Your major can only consist of 2 to 4 letters. E.g. 'ITC'")
                    return
                }
                signUp { errorModel in
                    self.errorModel = errorModel
                    if errorModel == nil {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .buttonStyle(BlueButton())
            .padding()
            .disabled(selectedSchool == School.example || major.isEmpty)
            
        }
        .onAppear {
            getSchools(for: country) { schools in
                self.schools = schools
                if let suggested = suggestedSchool(for: email, from: schools) {
                    self.selectedSchool = suggested
                }
            }
        }
        .alert(item: $errorModel) {
            Alert(title: Text($0.title), message: Text($0.message), dismissButton: .default(Text("OK"), action: {
//                if validEmail {
//                    presentationMode.wrappedValue.dismiss()
//                }
            }))
        }
    }
    
    func signUp(completion: @escaping (ErrorModel?) -> Void) {
        Auth.auth().createUser(withEmail: self.email, password: self.password) { (result, error) in
            guard let result = result else {
                print("Error creating user: \(error!)")
                completion(ErrorModel(title: "Error", message: error!.localizedDescription))
                return
            }
            let db = Firestore.firestore()
            let newUser = User(id: result.user.uid, name: self.username, email: self.email.lowercased(), country: country, school: selectedSchool, major: major)
            do {
                print("Creating document with id: \(newUser.id)")
                try db.collection("users").document(newUser.id).setData(from: newUser)
                completion(nil)
            } catch {
                print("Error adding document from user: \(error)")
                completion(ErrorModel(title: "Error", message: error.localizedDescription))
            }
        }
    }
    
    func getSchools(for country: String, completion: @escaping ([School]) -> Void) {
        let url = URL(string: "http://universities.hipolabs.com/search?country=\(country.lowercased())")!
        print(url)
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            do {
                let decoder = JSONDecoder()
                let countries = try decoder.decode([School].self, from: data)
                completion(countries)
            } catch {
                print("JSON Error: \(error.localizedDescription)")
            }
        }.resume()
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

//struct SchoolSelectionView_Previews: PreviewProvider {
//    static var previews: some View {
//        SchoolSelectionView()
//    }
//}
