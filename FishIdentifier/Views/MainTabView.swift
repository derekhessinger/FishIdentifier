import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Image(systemName: "camera.viewfinder")
                    Text("Identify")
                }
            
            FishTrackingView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("My Catches")
                }
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}