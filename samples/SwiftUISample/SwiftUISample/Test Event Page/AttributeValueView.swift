import Foundation
import Combine
import SwiftUI

struct AttributeValueView: View {
    @Binding var attribute: AttributeState

    var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        VStack() {
            Picker(selection: $attribute.type, label: Text("Attribute Type")) {
                ForEach(AttributeTypes.allCases) {
                    Text($0.description).tag($0)
               }
            }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.bottom)
            valueView()
        }
    }
        
    func valueView() -> AnyView {
        switch attribute.type {
        case .date:
            return AnyView( DatePicker("", selection: $attribute.dateValue, displayedComponents: [DatePickerComponents.date, DatePickerComponents.hourAndMinute]) )
        case .string:
            return AnyView( TextField("String Value", text: $attribute.stringValue, onEditingChanged: { (unknown) in
                // changed
            }) {
                // complete
            }
                .multilineTextAlignment(.trailing)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            )
        case .bool:
            return AnyView(
                Toggle("", isOn: $attribute.boolValue)
            )
        case .number:
            return AnyView( TextField("Numeric Value", text: $attribute.stringValue, onEditingChanged: { (unknown) in
                // changed
            }) {
                // complete
            }
                .multilineTextAlignment(.trailing)
                .keyboardType(UIKeyboardType.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            )
        }
    }
}
