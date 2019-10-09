import Foundation

enum AttributeTypes: String, CaseIterable, Identifiable {
    var id: String { return self.rawValue }
    
    case date
    case string
    case bool
    case number
    
    // Perhaps load from user defaults?
    static let defaultValue = AttributeTypes.string
    
    var description: String {
        switch self {
        case .date:
            return "Date"
        case .string:
            return "Text"
        case .bool:
            return "Bool"
        case .number:
            return "Num"
        }
    }
}
