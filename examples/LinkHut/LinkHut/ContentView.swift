// Copyright: 2021, Ableton AG, Berlin. All rights reserved.

import SwiftUI
import AVFoundation
import AudioToolbox.AudioServices
import GoogleMobileAds
import UIKit

private let fontSize = 30.0
private let imageSize = 35.0
private let activeColor = Color(red: 1, green: 0.1, blue: 1)
private var activeDownbeatColor = Color(red: 1, green: 1, blue: 1)
private let countInColor = Color(red: 0.7, green: 0.7, blue: 0.7)
private let inactiveColor = Color(red: 0, green: 0, blue: 0)
private var vibrateBool = false
private var lightBool = false
let generator = UINotificationFeedbackGenerator()
private var switchBool = false
private var switchBoolLight = false
private var colorSwitchBool = false
private var screenOff = false

private struct BannerVC: UIViewControllerRepresentable  {

    func makeUIViewController(context: Context) -> UIViewController {
        let view = GADBannerView(adSize: GADAdSizeBanner)

        let viewController = UIViewController()
        view.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        view.rootViewController = viewController
        viewController.view.addSubview(view)
        viewController.view.frame = CGRect(origin: .zero, size: GADAdSizeBanner.size)
        view.load(GADRequest())

        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

struct Banner:View{
    var body: some View{
        HStack{
            Spacer()
            BannerVC().frame(width: 320, height: 50, alignment: .center)
            Spacer()
        }
    }
}

struct Banner_Previews: PreviewProvider {
    static var previews: some View {
        Banner()
    }
}







func toggleTorch(on: Bool) {
    guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }

    if device.hasTorch {
        do {
            try device.lockForConfiguration()

            if on == true {
                device.torchMode = .on
            } else {
                device.torchMode = .off
            }

            device.unlockForConfiguration()
        } catch {
            print("Torch could not be used")
        }
    } else {
        print("Torch is not available")
    }
}


func isEven (number: Double) -> Bool
{
    var number2 = 1
    number2 = Int(number)
    if number2 % 2 == 0 {
      return true
    } else {
      return false
    }
}

func isOdd (number: Double) -> Bool
{
    var number2 = 1
    number2 = Int(number)
    if number2 % 2 == 1 {
      return true
    } else {
      return false
    }
}

func vibrate()
{
    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
}

func switched (bool: Bool)
{
    if (switchBool != bool)
    {
        switchBool = bool
        vibrate()
    }
    
}

    
func switchedLight (bool: Bool)
{
    if (switchBoolLight != bool)
    {
        switchBoolLight = bool
        for _ in 1...20 {toggleTorch(on:true)}
        toggleTorch(on:false)
    }
}


func colorSwitch (bool: Bool) -> Color
{
    if (colorSwitchBool != bool)
    {
        colorSwitchBool = bool
        return activeDownbeatColor
    }
    return inactiveColor
}

// Wrapper to show the UIKit ABLLinkSettingsViewController in SwiftUI
struct LinkSettingsViewController: UIViewControllerRepresentable {
  var link: ABLLinkRef

  func makeUIViewController(context: Context) -> ABLLinkSettingsViewController {
    return ABLLinkSettingsViewController.instance(link)
  }

  func updateUIViewController(_ uiViewController: ABLLinkSettingsViewController, context: Context) {
  }
}

struct LinkSettingsButton: View {
  @EnvironmentObject private var engine: AudioEngineController
  @State private var showSettings = false

  var body: some View {
    Button(action: { showSettings = true }, label: { Image("Settings") }).foregroundColor(Color.white)
      .buttonStyle(PlainButtonStyle())
      .sheet(
        isPresented: $showSettings,
        content: {
          NavigationView {
            if let link = engine.link {
              LinkSettingsViewController(link: link)
                .navigationBarTitle("Link Settings", displayMode: .inline)
                .navigationBarItems(
                  trailing: Button(action: { showSettings = false }) {
                    Text("Done")
                      
                  }
                )
            }
          }
        }
      )
  }
}


struct ImageButton: View {
  var action: () -> Void
  var imageName: String
  @State private var timer: Timer?

  var body: some View {
    Button(
      action: {},
      label: {
        Image(imageName).resizable().aspectRatio(contentMode: .fit)
          .frame(width: imageSize, height: imageSize)
      }
    )
    .buttonStyle(PlainButtonStyle())
    .onLongPressGesture(
      minimumDuration: 0.1, perform: {},
      onPressingChanged: { pressed in
        if pressed {
          timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in action() }
        } else {
          timer?.invalidate()
          timer = nil
        }
      }
    )
  }
}


struct TempoControl: View {
  @EnvironmentObject private var engine: AudioEngineController

  var body: some View {
    VStack {
      HStack {
        ImageButton(action: { engine.tempo = max(20, engine.tempo - 1) }, imageName: "Minus")
              .foregroundColor(Color.white)
        Text(String(format: "%.1f", engine.tempo))
              .foregroundColor(Color.white)
        ImageButton(action: { engine.tempo = min(engine.tempo + 1, 999) }, imageName: "Plus")
              .foregroundColor(Color.white)
      }
    }.padding().font(.system(size: fontSize))
  }
}



struct VibrateButton: View {
    @EnvironmentObject private var engine: AudioEngineController

  var body: some View {
    Button(
      action: { vibrateBool = !vibrateBool },
      label: { Image(vibrateBool ? "Vibrate_On" : "Vibrate_Off")
      }
        
    )
  }
    
}

struct ScreenBlinkButton: View {
    @EnvironmentObject private var engine: AudioEngineController

  var body: some View {
    Button(
      action: { screenOff = !screenOff },
      label: { Image(screenOff ? "Screen_Off" : "Screen_On")
      }
    )
  }
    
}

struct FlashlightButton: View {
    @EnvironmentObject private var engine: AudioEngineController

  var body: some View {
    Button(
      action: { lightBool = !lightBool },
      label: { Image(lightBool ? "Flashlight_On" : "Flashlight_Off")
      }
    )
  }
    
}


struct Metronome: View {
    @EnvironmentObject private var engine: AudioEngineController
    
    var body: some View {
        VStack(alignment: .center) {
            HStack(spacing: 0) {
                    Rectangle().fill(rectColor(number: 0))
            }
        }
    }
    func rectColor(number: Int) -> Color
    {
        if !engine.isPlaying
        {
            return inactiveColor
        }
        else
        {
            if engine.isPlaying
            {
                if (vibrateBool)
                {
                    if engine.tempo > 109.0
                    {
                        if isEven(number: engine.beatTime)
                        {
                            vibrate()
                        }
                    }
                    else
                    {
                        switched(bool: isEven(number: engine.beatTime))
                    }
                }
                if (lightBool)
                {
                    switchedLight(bool: isEven(number: engine.beatTime))
                }
            }
            if screenOff {return inactiveColor}
            return colorSwitch(bool: isEven(number: engine.beatTime))
            
        }
    }
}



struct TransportButton: View {
  @EnvironmentObject private var engine: AudioEngineController

  var body: some View {
    Button(
      action: { engine.isPlaying = !engine.isPlaying },
      label: { Image(engine.isPlaying ? "Transport_Pause" : "Transport_Play") }
    )
   // .buttonStyle(PlainButtonStyle())
    .foregroundColor(Color.white)
    .padding()
  }
}












struct WideControls: View {
  var body: some View {
      VStack {
          ScreenBlinkButton()
          HStack {
              TransportButton()
              Spacer()
              TempoControl()
              Spacer ()
              VibrateButton()
              FlashlightButton()
          }
      }
  }
}

struct HighControls: View {
  var body: some View {
    HStack {
      TempoControl()
    }
    Spacer()
      VStack {
          ScreenBlinkButton()
          HStack {
              FlashlightButton()
              TransportButton()
              VibrateButton()
          }
      }
      
  }
}

struct Controls: View {
  @State private var orientation = UIDevice.current.orientation

  #if targetEnvironment(macCatalyst)
    var body: some View {
      WideControls()
    }
  #else
    let orientationChanged = NotificationCenter.default.publisher(
      for: UIDevice.orientationDidChangeNotification
    )
    .makeConnectable()
    .autoconnect()

    var body: some View {
      Group {
        if orientation.isLandscape {
          WideControls()
        } else {
          HighControls()
        }
      }
      .onReceive(orientationChanged) { _ in
        self.orientation = UIDevice.current.orientation
      }
    }
  #endif
}

struct ContentView: View {
    var body: some View {
       ZStack {
            Metronome()
                .ignoresSafeArea()
            VStack {
                HStack {
                    Spacer()
                    LinkSettingsButton().padding()
                }
                Controls()
                Banner()
            }
        }

    }
}
 

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
      .environmentObject(AudioEngineController())
  }
}

