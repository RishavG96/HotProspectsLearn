//
//  ContentView.swift
//  HotProspectsLearn
//
//  Created by Rishav Gupta on 27/06/23.
//

import SwiftUI
// @EnvironmentObject - place an object into the environment so that any child view can use it and have access to it and have updates to it as well

@MainActor class User: ObservableObject {
    @Published var name = "Taylor Swift"
}

struct EditView: View {
    @EnvironmentObject var user: User
    
    var body: some View {
        TextField("Name", text: $user.name)
    }
}

struct DisplayView: View {
    @EnvironmentObject var user: User
    
    var body: some View {
        Text(user.name)
    }
}


struct ContentView: View {
    @StateObject var user = User()
    
    
    @State private var selectedTab = "One"
    
    var body: some View {
//        VStack {
////            EditView().environmentObject(user)
////            DisplayView().environmentObject(user)
//            EditView()
//            DisplayView()
//        }
//        .environmentObject(user)
        
        // Environment uses Data types for the keys  and instance of that type as value
        // [User: instance of User]
        
        
        // TabView Contains the Navigation View which contains List
        TabView(selection: $selectedTab) {
            Text("Tab 1")
                .onTapGesture {
                    selectedTab = "Two"
                }
                .tabItem {
                    Label("One", systemImage: "star")
                }
            Text("Tab 2")
                .tabItem {
                    Label("Two", systemImage: "circle")
                }
                .tag("Two")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
