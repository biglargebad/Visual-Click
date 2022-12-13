// Copyright: 2021, Ableton AG, Berlin. All rights reserved.

import SwiftUI
import GoogleMobileAds
import AppTrackingTransparency

@main
struct LinkHutApp: App {

  @StateObject var audioEngineController = AudioEngineController()
  @Environment(\.scenePhase) private var scenePhase

    init() {
            if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
                //User has not indicated their choice for app tracking
                //You may want to show a pop-up explaining why you are collecting their data
                //Toggle any variables to do this here
            } else {
                ATTrackingManager.requestTrackingAuthorization { status in
                    //Whether or not user has opted in initialize GADMobileAds here it will handle the rest
                                                                
                    GADMobileAds.sharedInstance().start(completionHandler: nil)
                }
            }
        }
    
  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(audioEngineController)
    }
    .onChange(of: scenePhase) { phase in
      switch phase {
      case .active:
        // Unconditionally activate Link when becoming active.
        // If the app is active, Link should be active.
        ABLLinkSetActive(audioEngineController.link, true)
        audioEngineController.startAudioEngine()
      case .background:
        // Deactivate Link if the app is not playing and it cannot be started from Start Stop Sync,
        // so that it won't continue to browse for connections while in the background.
        if !audioEngineController.isPlaying
          && !ABLLinkIsStartStopSyncEnabled(audioEngineController.link)
        {
          ABLLinkSetActive(audioEngineController.link, false)
          audioEngineController.stopAudioEngine()
        }
      default: ()
      }

    }
  }

}
