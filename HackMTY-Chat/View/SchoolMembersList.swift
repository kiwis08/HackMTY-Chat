//
//  SchoolMembersList.swift
//  HackMTY-Chat
//
//  Created by Santiago Quihui on 29/08/21.
//

import SwiftUI

struct SchoolMembersList: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var firebaseManager: FirebaseManager
    @EnvironmentObject var userData: UserData
    var school: String
    @State private var students = [User]()
    @State private var errorModel: ErrorModel? = nil
    @State private var searchText = ""
    @State private var searchBy: SearchTypes = .name
    @State private var isSearching = false
    
    var searchResults: [User] {
        if searchText.isEmpty {
            return students
        } else {
            switch searchBy {
            case .name:
                return students.filter({ $0.name.contains(searchText)})
            case .major:
                return students.filter({ $0.major.contains(searchText)})
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Picker("Search by", selection: $searchBy) {
                        ForEach(SearchTypes.allCases, id: \.rawValue) {
                            Text($0.rawValue).tag($0)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding(.leading)
                    TextField("Search By \(searchBy.rawValue)", text: $searchText)
                        .padding(7)
                        .padding(.horizontal, 10)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal, 10)
                        .onTapGesture {
                            isSearching = true
                        }
                    if isSearching {
                        Button("Cancel") {
                            searchText = ""
                            withAnimation {
                                isSearching = false
                            }
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                        .padding(.trailing, 10)
                        .transition(.move(edge: .trailing))
                        .animation(.default)
                    }
                }
                List {
                    ForEach(searchResults) { student in
                        HStack {
                            Text(student.name)
                            Spacer()
                            Text(student.major)
                        }
                        .onTapGesture {
                            firebaseManager.joinChat(user: userData.userID, with: student.id) { errModel in
                                if let errorM = errModel {
                                    self.errorModel = errorM
                                } else {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .onAppear {
                    firebaseManager.searchBySchool(currentUser: userData.userID, school: school) { users, errModel in
                        if let errorModel = errModel {
                            self.errorModel = errorModel
                        } else {
                            self.students = users
                        }
                    }
                }
                .navigationBarTitle(Text(school))
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
    
    
    
    enum SearchTypes: String, CaseIterable {
        case name = "Name"
        case major = "Major"
    }
}

struct SchoolMembersList_Previews: PreviewProvider {
    static var previews: some View {
        SchoolMembersList(school: School.example.name)
    }
}
