//
//  MedicalNoteAppApp.swift
//  MedicalNoteApp
//
//  Created by 八久響 on 2024/03/12.
//

import SwiftUI

@main
struct MedicalNoteAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: Item.self)
        }
    }
}
