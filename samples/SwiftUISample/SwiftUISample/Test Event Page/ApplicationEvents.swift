import Foundation

enum ApplicationEvents: String, CaseIterable, Identifiable {
    var id: String { return self.rawValue }
    
    case sessionStarted
    case sessionEnded
    case uiPushEnabled
    case uiPushDisabled
    
    static let defaultValue = ActionEvents.urlClicked

    static var strings: [String] {
        return allCases.map { (item) -> String in
            item.rawValue
        }
    }
    
    var description: String {
        switch self {
        case .sessionStarted:
            return "Session Start"
        case .sessionEnded:
            return "Session End"
        case .uiPushEnabled:
            return "Push Enable"
        case .uiPushDisabled:
            return "Push Disable"
        }
    }
}
