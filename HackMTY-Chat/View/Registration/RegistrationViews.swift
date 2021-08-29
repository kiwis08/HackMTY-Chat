//
//  RegistrationViews.swift
//  HackMTY-Chat
//
//  Created by Santiago Quihui on 28/08/21.
//

import SwiftUI

struct RegistrationViews: View {
    @State var email = ""
    @State private var username = ""
    @State private var password1 = ""
    @State private var password2 = ""
    
    @State private var errorModel: ErrorModel? = nil
    
    var countries = ["Mexico", "United States", "Canada"]
    @State private var country = "Select a country"
    
    @State private var selectedTab = Tabs.first
    
    enum Tabs: String {
        case first
        case second
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            RegistrationView(email: $email, username: $username, password1: $password1, password2: $password2, errorModel: $errorModel, countries: countries, country: $country, selectedTab: $selectedTab)
                .tag(Tabs.first)
            SchoolSelectionView(username: $username, email: $email, password: $password1, country: $country, countries: countries, selectedTab: $selectedTab)
                .tag(Tabs.second)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    }
}

struct RegistrationViews_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationViews()
    }
}

//just a dummy
class MySwipeGesture: UISwipeGestureRecognizer {

    @objc func noop() {}

    init(target: Any?) {
        super.init(target: target, action: #selector(noop))
    }
}

//this delegate effectively disables the gesure
class MySwipeGestureDelegate: NSObject, UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        false
    }
}

//and the overlay inspired by the answer from the link above
struct TouchesHandler: UIViewRepresentable {

    func makeUIView(context: UIViewRepresentableContext<TouchesHandler>) -> UIView {
        let view = UIView(frame: .zero)
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(context.coordinator.makeGesture())
        return view;
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<TouchesHandler>) {
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    class Coordinator {
        var delegate: UIGestureRecognizerDelegate = MySwipeGestureDelegate()
        func makeGesture() -> MySwipeGesture {
            delegate = MySwipeGestureDelegate()
            let gr = MySwipeGesture(target: self)
            gr.delegate = delegate
            return gr
        }
    }
    typealias UIViewType = UIView
}
