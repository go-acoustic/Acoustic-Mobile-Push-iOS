import Foundation

enum ActionEvents: String, CaseIterable, Identifiable {
    var id: String { return self.rawValue }
    
    case urlClicked
    case appOpened
    case phoneNumberClicked
    case inboxMessageOpened

    static let defaultValue = ActionEvents.urlClicked
    
    static var strings: [String] {
        return allCases.map { (item) -> String in
            item.rawValue
        }
    }

    var description: String {
        switch self {
        case .urlClicked:
            return "URL"
        case .appOpened:
            return "OpenApp"
        case .phoneNumberClicked:
            return "Dial"
        case .inboxMessageOpened:
            return "Inbox"
        }
    }
}
