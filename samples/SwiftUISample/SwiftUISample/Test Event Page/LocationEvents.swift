import Foundation

enum LocationEvents: String, CaseIterable, Identifiable {
    var id: String { return self.rawValue }
    
    case disabled
    case enabled
    case enter
    case exit
    
    // Perhaps load from user defaults?
    static let defaultValue = LocationEvents.disabled
    
    static var strings: [String] {
        return allCases.map { (item) -> String in
            item.rawValue
        }
    }

    var description: String {
        switch self {
        case .disabled:
            return "Disabled"
        case .enabled:
            return "Enabled"
        case .enter:
            return "Enter"
        case .exit:
            return "Exit"
        }
    }
}
