// Copyright: 2021, Ableton AG, Berlin. All rights reserved.

import SwiftUI
import AVFoundation
import AudioToolbox.AudioServices

private let fontSize = 30.0
private let imageSize = 35.0
private let activeColor = Color(red: 1, green: 0.1, blue: 1)
private var activeDownbeatColor = Color(red: 1, green: 1, blue: 1)
private let countInColor = Color(red: 0.7, green: 0.7, blue: 0.7)
private let inactiveColor = Color(red: 0, green: 0, blue: 0)
private var vibrateBool = false
let generator = UINotificationFeedbackGenerator()
private var switchBool = false


func isEven (number: Double) -> Bool
{
    var number2 = 1
    number2 = Int(number + 0.3)
    if number2 % 2 == 0 {
      return true
    } else {
      return false
    }
}

func switched (bool: Bool)
{
    if (switchBool != bool)
    {
        switchBool = bool
        let impactLight = UIImpactFeedbackGenerator(style: .rigid)
    impactLight.impactOccurred()
    }
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
     // Text("Tempo")
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

/*
struct QuantumControl: View {
  @EnvironmentObject private var engine: AudioEngineController

  var body: some View {
    VStack {
      Text("Quantum")
      HStack {
        ImageButton(action: { engine.quantum = max(1, engine.quantum - 1) }, imageName: "Minus")
        Text(String(format: "%.0f", engine.quantum))
        ImageButton(action: { engine.quantum = engine.quantum + 1 }, imageName: "Plus")
      }
    }.padding().font(.system(size: fontSize))
  }
}*/



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


struct Metronome: View {
    @EnvironmentObject private var engine: AudioEngineController
    
    var body: some View {
        VStack(alignment: .center) {
            HStack(spacing: 0) {
                ForEach(0..<Int(engine.quantum), id: \.self) { number in
                    Rectangle().fill(rectColor(number: 0))
                }
                // .padding(0)
            }
            // .padding(0)
            /*HStack {
             Text(String(format: "Beat Time: %.2f", engine.beatTime)).font(.system(size: fontSize))
             .padding()
             Spacer()
             }*/
        }
    }
    
    func rectColor(number: Int) -> Color {
        //let current =
        //Int(engine.quantum + engine.beatTime) % Int(engine.quantum) == number
        if !engine.isPlaying /*|| !current*/ || (engine.beatTime - Double(Int(engine.beatTime)) > 0.1){
           // oneVibe = true
            return inactiveColor
        }
        //if engine.beatTime >= 0
        if engine.isPlaying
        {
            if number == 0
            //(engine.beatTime - Double(Int(engine.beatTime)) == 0.0))
            {
                if (vibrateBool)     {
                    switched(bool: isEven(number: engine.beatTime))
                }
                return activeDownbeatColor
            }
            return inactiveColor
        }
    return countInColor
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
    HStack {
     // QuantumControl()
     // Spacer()
      TransportButton()
      Spacer()
      TempoControl()
        VibrateButton()
    }
  }
}

struct HighControls: View {
  var body: some View {
    HStack {
     // QuantumControl()
     // Spacer()
      TempoControl()
    }
    Spacer()
      HStack {
          TransportButton()
          VibrateButton()
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
                // Spacer()
                //Metronome()
                Controls()
            }
            //Metronome()
            //.ignoresSafeArea()
        }
    }
}
 

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
      .environmentObject(AudioEngineController())
  }
}

