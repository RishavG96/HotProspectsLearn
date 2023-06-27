//
//  ContentView.swift
//  HotProspectsLearn
//
//  Created by Rishav Gupta on 27/06/23.
//

import SamplePackage
import SwiftUI
import UserNotifications
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


@MainActor class DelayedUpdater: ObservableObject {
    var value = 0 {
        willSet {
            objectWillChange.send()
        }
    }
    
    init() {
        for i in 1...10 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i)) {
                self.value += 1
            }
        }
    }
}

struct ContentView: View {
    @StateObject var user = User()
    
    
    @State private var selectedTab = "One"
    
    @StateObject private var updater = DelayedUpdater()
    
    
    @State private var output = ""
    
    @State private var backgroundColor = Color.red
    
    let possibleNumbers = Array(1...60)
    
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
            VStack {
                Text("Value is \(updater.value)")
                    .onTapGesture {
                        selectedTab = "Two"
                    }
                    .tabItem {
                        Label("One", systemImage: "star")
                    }
                
                Text(output)
                    .task {
                        await fetchReadings()
                    }
                    .background(backgroundColor)
                
                Text(results)
                
                Text("Change Color")
                    .padding()
                    .contextMenu {
                        Button(role: .destructive) {
                            backgroundColor = .red
                        } label: {
                            Label("Red", systemImage: "checkmark.circle.fill")
                                .foregroundColor(.red)
                        }
                        
                        Button("Green") {
                            backgroundColor = .green
                        }
                        
                        Button("Blue") {
                            backgroundColor = .blue
                        }
                    }
                
                List {
                    Text("Taylor Swift")
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                print("Deleting")
                            } label: {
                                Label("Delete", systemImage: "minus.circle")
                            }
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                print("Pinning")
                            } label: {
                                Label("Pin", systemImage: "pin")
                            }
                            .tint(.orange)
                        }
                }
                
                Button("Request Permission") {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                        if success {
                            print("All set!")
                        } else if let error = error {
                            print(error.localizedDescription)
                        }
                    }
                }
                
                Button("Schedule Notification") {
                    let content = UNMutableNotificationContent()
                    content.title = "Feed the dogs"
                    content.subtitle = "They look hungry"
                    content.sound = .default
                    
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                    
                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                    
                    UNUserNotificationCenter.current().add(request)
                }
                
//                Image("example")
//                    .interpolation(.none)// does not make it blur as it will not blend it anymore
//                    .resizable()
//                    .scaledToFit()
//                    .frame(maxHeight: .infinity)
//                    .background(.black)
//                    .ignoresSafeArea()
            }
            Text("Tab 2")
                .tabItem {
                    Label("Two", systemImage: "circle")
                }
                .tag("Two") // identifies which tab is to be selected
        }
        
        
        // objectWillChange - every class that conforms to Observable object will gain this property
        // objectWillChange - is a publisher same as @Published. This is trigerred before we make a change. Should be applied immediately before we make a change.
    }
    
    var results: String {
        let selected = possibleNumbers.random(7).sorted()
        let strings = selected.map(String.init)
        return strings.joined(separator: ", ")
    }
    
    func fetchReadings() async {
        let fetchTask = Task { () -> String in
            let url = URL(string: "https://hws.dev/readings.json")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let readings = try JSONDecoder().decode([Double].self, from: data)
            return "Found \(readings.count) readings."
        }
        
        let result = await fetchTask.result
        
//        do {
//            output = try result.get()
//        } catch {
//            print("Download Error")
//        }
        
        switch result {
        case .success(let str):
            output = str
        case .failure(let error):
            output = "Download error \(error.localizedDescription)"
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
