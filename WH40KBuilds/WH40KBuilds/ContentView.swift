//
//  ContentView.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 27/6/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
    
    var body: some View {
        BuildListView()
            .onAppear {
                Task { 
                    do {
                        let items = try context.fetch(FetchDescriptor<Item>())
                        print("Item(s) existentes:", items)
                    } catch {
                        print("Error al leer Items:", error)
                    }
                }
            }
    }
}

#Preview {
    BuildListView()
}
