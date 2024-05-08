//
//  ContentView.swift
//  MedicineNoteApp
//
//  Created by 八久響 on 2024/03/11.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedDate = Date()
    @Query private var items: [Item]
    @State private var showingDiaryEntrySheet = false
    @State private var diaryText = ""
    @State private var editingItem: Item?
    
    var body: some View {
        Text("おくすりノート")
            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
        NavigationSplitView {
            VStack {
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .onChange(of: selectedDate) { _ in
                        // Handle change in date selection
                    }
                List {
                    ForEach(filteredItems(for: selectedDate)) { item in
                        VStack(alignment: .leading) {
                            Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                            Text(item.diaryText)
                                .lineLimit(2)
                        }
                        .onTapGesture {
                            diaryText = item.diaryText
                            editingItem = item
                            showingDiaryEntrySheet = true
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
            }
            .environment(\.locale, Locale(identifier: "ja_JP"))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        diaryText = "朝分の薬を飲みました"
                        let newItem = Item(timestamp: createTimestamp(selectedDate: selectedDate), diaryText: diaryText)
                        modelContext.insert(newItem)
                    }) {
                        Text("朝")
                            .foregroundColor(.white)
                            .frame(width: 35, height: 90)
                            .background(Color.orange.clipShape(Circle()))
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        diaryText = "お昼分の薬を飲みました"
                        let newItem = Item(timestamp: createTimestamp(selectedDate: selectedDate), diaryText: diaryText)
                        modelContext.insert(newItem)
                    }) {
                        Text("昼")
                            .foregroundColor(.white)
                            .frame(width: 35, height: 90)
                            .background(Color.cyan.clipShape(Circle()))
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        diaryText = "夜分の薬を飲みました"
                        let newItem = Item(timestamp: createTimestamp(selectedDate: selectedDate), diaryText: diaryText)
                        modelContext.insert(newItem)
                    }) {
                        Text("夜")
                            .foregroundColor(.white)
                            .frame(width: 35, height: 90)
                            .background(Color.indigo.clipShape(Circle()))
                    }
                }
                ToolbarItem {
                    Button(action: {
                        diaryText = ""
                        editingItem = nil
                        showingDiaryEntrySheet = true
                    }) {
                        Label("Add Item", systemImage: "square.and.pencil")
                    }
                }
            }
            .sheet(isPresented: $showingDiaryEntrySheet) {
                DiaryEntryView(diaryText: $diaryText, item: $editingItem) {
                    if let editingItem = editingItem {
                        updateItem(editingItem)
                    } else {
                        addItem()
                    }
                    showingDiaryEntrySheet = false
                }
            }
        } detail: {
            Text("Select an item")
        }
    }
    
    // アイテムを追加します。
    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: selectedDate, diaryText: diaryText)
            modelContext.insert(newItem)
        }
    }
    
    // アイテムを更新します。
    private func updateItem(_ item: Item) {
        withAnimation {
            item.diaryText = diaryText
            try! modelContext.save()
        }
    }
    
    // アイテムを削除します。
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
    
    // アイテムをフィルタリングします。
    private func filteredItems(for date: Date) -> [Item] {
        return items.filter { Calendar.current.isDate($0.timestamp, inSameDayAs: date) }
    }
    
    // タイムスタンプを作成します。
    func createTimestamp(selectedDate: Date) -> Date {
        let calendar = Calendar.current
        let selectedComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: Date())
        let combinedComponents = DateComponents(
            year: selectedComponents.year,
            month: selectedComponents.month,
            day: selectedComponents.day,
            hour: timeComponents.hour,
            minute: timeComponents.minute,
            second: timeComponents.second
        )
        
        // `date(from:)` が nil を返す可能性があるが、通常は有効な日付が生成されることを前提とする
        return calendar.date(from: combinedComponents) ?? Date()  // 無効な場合は現在時刻を返す
    }

}

struct DiaryEntryView: View {
    @Binding var diaryText: String
    @Binding var item: Item? // Optional Item for editing
    var onSave: () -> Void
    var body: some View {
        NavigationView {
            VStack {
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $diaryText)
                        .padding()
                        .border(Color.blue, width: 1)
                        .cornerRadius(3)
                    if diaryText.isEmpty {
                        Text("ここに入力")
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
            }
            .padding()
            .navigationTitle(item == nil ? "日記を記録" : "日記を編集")
            .navigationBarItems(trailing: Button("保存") {
                onSave()
            })
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self)
}
