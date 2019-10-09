import SwiftUI
import Combine
import AcousticCampaignMobile

struct RegistrationView: View {
    @ObservedObject var store = RegistrationStore()

    var body: some View {
        Form {
            Section(header: Text("Credentials".uppercased()).padding(.top), footer: Text("User ID and Channel ID are known only after registration. The registration process could take several minutes. If you have have issues with registering a device, make sure you have the correct certificate and appKey.")) {
                RowView(left: "User", right: store.userId ?? "")
                RowView(left: "Channel", right: store.channelId ?? "")
                RowView(left: "AppKey", right: MCERegistrationDetails.shared.appKey)
                RowView(left: "Registration", right: MCERegistrationDetails.shared.mceRegistered ? "Registered" : "Click to start")
                    .gesture(TapGesture().onEnded({ (_) in
                        if !MCERegistrationDetails.shared.mceRegistered {
                            MCESdk.shared.manualInitialization()
                        }
                    }))
            }
        }.navigationBarTitle(Text("Registration Details"), displayMode: .inline)
    }
}

#if DEBUG
struct RegistrationView_Previews : PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                RegistrationView()
            }.previewDevice("iPhone SE")
            NavigationView {
                RegistrationView()
            }.colorScheme(.light).previewDevice("iPhone X")
            NavigationView {
                RegistrationView()
            }.colorScheme(.dark).previewDevice("iPhone X")
        }

    }
}
#endif
