import SwiftUI

// This is required because SwiftUI doesn't deal with wide Segmented Pickers well.
struct SelectEventName: View {
    @Binding var simulatedEvents: SimulatedEvents
    @Binding var eventName: String
    var body: some View {
        List {
            ForEach(simulatedEvents.names) { name in
                HStack {
                    Text(name.description).tag(name)
                    Spacer()
                    if self.eventName == name {
                        Image(uiImage: UIImage(systemName: "checkmark")!)
                    }
                }.onTapGesture {
                    self.eventName = name
                }
            }
        }
    }
}
