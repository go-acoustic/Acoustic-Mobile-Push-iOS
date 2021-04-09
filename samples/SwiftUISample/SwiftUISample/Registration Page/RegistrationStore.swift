import SwiftUI
import Combine
import AcousticMobilePush

final class RegistrationStore: ObservableObject {
    @Published var userId = MCERegistrationDetails.shared.userId
    @Published var channelId = MCERegistrationDetails.shared.channelId
    private var cancellable: Cancellable? = nil
    init() {
        cancellable = NotificationCenter.default.publisher(for: MCENotificationName.MCERegistered.rawValue)
            .merge(with: NotificationCenter.default.publisher(for: MCENotificationName.MCERegistrationChanged.rawValue))
            .receive(on: RunLoop.main)
            .sink { (note) in
                self.userId = MCERegistrationDetails.shared.userId
                self.channelId = MCERegistrationDetails.shared.channelId
        }
    }
    deinit {
        cancellable?.cancel()
        cancellable = nil
    }
}
