import SwiftUI

// This is required because SwiftUI doesn't deal with wide Segmented Pickers well.
struct SelectEventType: View {
    @Binding var simulatedEvents: SimulatedEvents
    @Binding var eventType: String

    var body: some View {
        List {
            ForEach(simulatedEvents.types) { type in
                HStack {
                    Text(type.description).tag(type)
                    Spacer()
                    if self.eventType == type {
                        Image(uiImage: UIImage(systemName: "checkmark")!)
                    }
                }.onTapGesture {
                    self.eventType = type
                }
            }
        }
    }
}
