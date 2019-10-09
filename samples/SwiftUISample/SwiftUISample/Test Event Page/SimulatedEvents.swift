import Foundation

enum SimulatedEvents: String, CaseIterable, Identifiable {
    var id: String { return self.rawValue }
    
    case AppEvent
    case ActionEvent
    case InboxEvent
    case GeofenceEvent
    case iBeaconEvent
    
    static let defaultValue = SimulatedEvents.AppEvent
    
    var description: String {
        switch self {
        case .AppEvent:
            return "App"
        case .ActionEvent:
            return "Action"
        case .InboxEvent:
            return "Inbox"
        case .GeofenceEvent:
            return "Geo"
        case .iBeaconEvent:
            return "Beacon"
        }
    }
    
    var types: [String] {
        switch self {
        case .AppEvent:
            return ["application"]
        case .ActionEvent:
            return ["simpleNotification", "inboxMessage", "inAppMessage"]
        case .InboxEvent:
            return ["inbox"]
        case .GeofenceEvent:
            return ["geofence"]
        case .iBeaconEvent:
            return ["beacon"]
        }
    }
    
    var names: [String] {
        switch self {
        case .AppEvent:
            return ApplicationEvents.strings
        case .ActionEvent:
            return ActionEvents.strings
        case .InboxEvent:
            return ["messageOpened"]
        case .GeofenceEvent, .iBeaconEvent:
            return LocationEvents.strings
        }
    }
}
