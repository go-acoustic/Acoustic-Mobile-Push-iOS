import SwiftUI
import AcousticMobilePush
import Combine

extension String: Identifiable {
    public var id: String { return self }
}

let TEXT_WIDTH = CGFloat(100)
let TEXT_HEIGHT = CGFloat(44)

struct TestEventView: View {
    @ObservedObject var state = TestEventState()

    func sendEvent() {
        guard let event = state.event else {
            state.statusText = "Not sending incomplete event, enter both event type and name"
            state.statusColor = .warning
            return
        }
        
        state.statusText = "Queued event named: \(event.name ?? "<unnamed>"), with type: \(event.type ?? "<untyped>")"
        state.statusColor = .warning
        MCEEventService.shared.add(event, immediate: true)
    }
    
    var eventTypePicker: some View {
        Picker(selection: $state.eventTypes, label: Text("Event Type")) {
            ForEach(EventTypes.allCases) {
                Text($0.description).tag($0)
           }
        }.pickerStyle(SegmentedPickerStyle())
    }
    
    var simulatedEventPicker: some View {
        Picker(selection: $state.simulatedEvents, label: Text("Simulated Events")) {
            ForEach(SimulatedEvents.allCases) {
                Text($0.description).tag($0)
            }
        }.pickerStyle(SegmentedPickerStyle()).disabled( state.eventTypes == .CustomEvent )
    }
    
    var mailingIdRow: some View {
        HStack {
            Text("Mailing Id").frame(minWidth: TEXT_WIDTH, maxWidth: TEXT_WIDTH, minHeight: TEXT_HEIGHT, maxHeight:TEXT_HEIGHT, alignment: .leading)
            TextField("Mailing Id", text: $state.mailingId, onEditingChanged: { (unknown) in }).keyboardType(UIKeyboardType.decimalPad).multilineTextAlignment(.trailing).textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
    
    var eventTypeRow: some View {
        HStack {
            Text("Type").frame(minWidth: TEXT_WIDTH, maxWidth: TEXT_WIDTH, minHeight: TEXT_HEIGHT, maxHeight: TEXT_HEIGHT, alignment: .leading)
            Spacer()
            if state.eventTypes == .CustomEvent {
                Text("custom")
            } else {
                NavigationLink(destination: SelectEventType( simulatedEvents: $state.simulatedEvents, eventType: $state.type )) {
                    Text(state.type)
                }
            }
        }
    }
    
    var eventNameRow: some View {
        HStack {
            Text("Name").frame(minWidth: TEXT_WIDTH, maxWidth: TEXT_WIDTH, minHeight: TEXT_HEIGHT, maxHeight:TEXT_HEIGHT, alignment: .leading)
            if state.eventTypes == .CustomEvent {
                TextField("Event Name", text: $state.name, onEditingChanged: { (unknown) in })
                    .multilineTextAlignment(.trailing)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            } else {
                Spacer()
                NavigationLink(destination: SelectEventName( simulatedEvents: $state.simulatedEvents, eventName: $state.name )) {
                    Text(state.name)
                }
            }
        }
    }
    
    var eventAttributionRow: some View {
        HStack {
            Text("Attribution").frame(minWidth: TEXT_WIDTH, maxWidth: TEXT_WIDTH, minHeight: TEXT_HEIGHT, maxHeight:TEXT_HEIGHT, alignment: .leading)
            TextField("Attribution", text: $state.attribution, onEditingChanged: { (unknown) in })
                .multilineTextAlignment(.trailing)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
    
    var eventAttributeNameRow: some View {
        HStack {
            Text("Name").frame(minWidth: TEXT_WIDTH, maxWidth: TEXT_WIDTH, minHeight: TEXT_HEIGHT, maxHeight:TEXT_HEIGHT, alignment: .leading)
            TextField("Attribute Name", text: $state.attribute.name, onEditingChanged: { (unknown) in })
                .multilineTextAlignment(.trailing)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                eventTypePicker
                simulatedEventPicker
                
                Group {
                    Text("Event Details").bold().padding(.top)
                    eventTypeRow
                    eventNameRow
                    eventAttributionRow
                    mailingIdRow
                }
                Group {
                    Text("Event Attributes").bold().padding(.top)
                    eventAttributeNameRow
                    AttributeValueView(attribute: $state.attribute)
                }
                Button("Send Event") {
                    self.sendEvent()
                }.padding(.top)

                Text("Status").bold().padding(.top)
                Text(state.statusText).foregroundColor(Color(state.statusColor))
            }
                .padding()
                .frame(minHeight: nil, maxHeight: .infinity, alignment: .top)
                .navigationBarTitle(Text("Send Events"), displayMode: .inline)
        }
    }
}

#if DEBUG
struct TestEventView_Previews : PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                TestEventView()
            }.previewDevice("iPhone SE")
            NavigationView {
                TestEventView()
            }.colorScheme(.light).previewDevice("iPhone XR")
            NavigationView {
                TestEventView()
            }.colorScheme(.dark).previewDevice("iPhone X")
        }

    }
}
#endif
