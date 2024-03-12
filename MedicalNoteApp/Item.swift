import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    var diaryText: String = ""
    
    init(timestamp: Date, diaryText: String) {
        self.timestamp = timestamp
        self.diaryText = diaryText
    }
}
