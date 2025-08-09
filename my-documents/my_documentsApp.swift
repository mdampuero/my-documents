//
//  my_documentsApp.swift
//  my-documents
//
//  Created by Mauricio Ampuero on 8/8/25.
//

import SwiftUI

@main
struct my_documentsApp: App {
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false

    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                MainTabView()
            } else {
                LoginView()
            }
        }
    }
}
