import Foundation
import Combine
import AcousticCampaignMobile

final class TestEventState: ObservableObject {
    @Published var eventTypes = EventTypes.defaultValue
    @Published var simulatedEvents = SimulatedEvents.defaultValue
    @Published var type: String = ""
    @Published var name: String = ""
    @Published var attribution: String = ""
    @Published var mailingId: String = ""
    @Published var attribute = AttributeState()
    @Published var statusText: String = "No status yet"
    @Published var statusColor: UIColor = .gray
    
    var cancelables = [AnyCancellable]()
    init() {
        cancelables.append(
            NotificationCenter.default.publisher(for: MCENotificationName.eventSuccess.rawValue)
                .sink(receiveValue: { (note) in
                if let userInfo = note.userInfo, let rawEvents = userInfo["events"], let events = rawEvents as? [MCEEvent] {
                    var eventStrings = [String]()
                    for event in events {
                        if let name = event.name, let type = event.type {
                            eventStrings.append("name: \(name), type: \(type)")
                        }
                    }
                    DispatchQueue.main.async {
                        self.statusText = "Sent events: \( eventStrings.joined(separator: ",") )"
                        self.statusColor = .success
                    }
                }

            })
        )
        cancelables.append(
            NotificationCenter.default.publisher(for: MCENotificationName.eventFailure.rawValue).sink(receiveValue: { (note) in
                if let userInfo = note.userInfo, let rawError = userInfo["error"], let error = rawError as? Error, let rawEvents = userInfo["events"], let events = rawEvents as? [MCEEvent] {
                    var eventStrings = [String]()
                    for event in events {
                        if let name = event.name, let type = event.type {
                            eventStrings.append("name: \(name), type: \(type)")
                        }
                    }
                    DispatchQueue.main.async {
                        self.statusText = "Couldn't send events: \( eventStrings.joined(separator: ",") ), because: \( error.localizedDescription )"
                        self.statusColor = .failure
                    }
                }
            })
        )
        cancelables.append(
            Publishers.CombineLatest($eventTypes, $simulatedEvents).sink(receiveValue: { (eventTypes, simulatedEvents) in
                switch eventTypes {
                case .CustomEvent:
                    self.type="custom"
                case .SimulateEvent:
                    if !simulatedEvents.types.contains(self.type) {
                        self.type = simulatedEvents.types.first!
                    }
                    if !simulatedEvents.names.contains(self.name) {
                        self.name = simulatedEvents.names.first!
                    }
                }
            })
        )
    }
    
    var event: MCEEvent? {
        if name.count == 0 || type.count == 0 {
            return nil
        }
        return MCEEvent(name: name, type: type, timestamp: nil, attributes: attribute.json, attribution: attribution, mailingId: mailingId)
    }
}
