//
//  ChangeSelectionView.swift
//  HackMTY-Chat
//
//  Created by Santiago Quihui on 29/08/21.
//

import SwiftUI

struct ChangeSelectionView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var firebaseManager: FirebaseManager
    var userID: String
    var country: String
    var email: String
    @State private var schools = [School]()
    @State private var selectedSchool: School = School.example
    @State var major: String
    
    @State private var errorModel: ErrorModel? = nil
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Select your school")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .padding()
            
            Picker(selectedSchool.name, selection: $selectedSchool) {
                ForEach(schools, id: \.name) {
                    Text($0.name)
                        .multilineTextAlignment(.center)
                        .tag($0)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.6))
            .cornerRadius(10)
            .pickerStyle(MenuPickerStyle())
            .padding(.horizontal)
            
            MajorTextField(placeholder: "What's your major?", text: $major)
            
            Button("Save") {
                guard major.count >= 2 && major.count <= 4 else {
                    self.errorModel = ErrorModel(message: "Your major can only consist of 2 to 4 letters. E.g. 'ITC'")
                    return
                }
                firebaseManager.changeSchool(userID, to: selectedSchool) { errorModel in
                    if let errorModel = errorModel {
                        self.errorModel = errorModel
                    } else {
                        firebaseManager.changeMajor(userID, to: major) { errorModel in
                            if let errorModel = errorModel {
                                self.errorModel = errorModel
                            } else {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                }
            }
            .buttonStyle(BlueButton())
            .padding()
            .disabled(selectedSchool == School.example || major.isEmpty)
            
            Spacer()
        }
        .onAppear {
            getSchools(for: country) { schools in
                self.schools = schools
                if let suggested = suggestedSchool(for: email, from: schools) {
                    self.selectedSchool = schools[schools.firstIndex(of: suggested)!]
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
        .onChange(of: selectedSchool, perform: { value in
            print(selectedSchool.name)
            print(selectedSchool)
        })
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

//struct ChangeSelectionView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChangeSelectionView()
//    }
//}
