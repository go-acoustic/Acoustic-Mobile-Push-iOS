import Foundation

enum EventTypes: String, CaseIterable, Identifiable {
    var id: String { return self.rawValue }
    
    case CustomEvent
    case SimulateEvent
    
    // Perhaps load from user defaults?
    static let defaultValue = EventTypes.CustomEvent
    
    var description: String {
        switch self {
        case .CustomEvent:
            return "Send Custom Event"
        case .SimulateEvent:
            return "Simulate SDK Event"
        }
    }
}
