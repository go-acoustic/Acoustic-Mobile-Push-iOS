import Foundation

final class AttributeState: ObservableObject {
    @Published var name: String = ""
    @Published var type = AttributeTypes.defaultValue
    @Published var stringValue: String = ""
    @Published var boolValue: Bool = false
    @Published var numericValue: Double = 0.0
    @Published var dateValue: Date = Date()
    
    var json: [String:Any] {
        var attributes = [String:Any]()
        switch type {
        case .date:
            attributes[name] = dateValue
        case .string:
            attributes[name] = stringValue
        case .bool:
            attributes[name] = boolValue
        case .number:
            attributes[name] = numericValue
        }
        return attributes
    }
}
