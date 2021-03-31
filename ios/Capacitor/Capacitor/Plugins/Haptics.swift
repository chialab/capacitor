import Foundation
import AudioToolbox
import CoreHaptics;

@objc(CAPHapticsPlugin)
public class CAPHapticsPlugin: CAPPlugin {
  var supportsHaptics: Bool = false
  var engine: CHHapticEngine!
  let hapticCapability = CHHapticEngine.capabilitiesForHardware()
  supportsHaptics = hapticCapability.supportsHaptics

  if supportsHaptics {
    engine = CHHapticEngine()
    engine.start(completionHandler:nil)
  }

  var selectionFeedbackGenerator: UISelectionFeedbackGenerator?

  @objc public func impact(_ call: CAPPluginCall) {
    DispatchQueue.main.async {
      if let style = call.options["style"] as? String {
        var impactStyle = UIImpactFeedbackGenerator.FeedbackStyle.heavy
        if style == "MEDIUM" {
          impactStyle = UIImpactFeedbackGenerator.FeedbackStyle.medium
        } else if style == "LIGHT" {
          impactStyle = UIImpactFeedbackGenerator.FeedbackStyle.light
        }

        let generator = UIImpactFeedbackGenerator(style: impactStyle)
        generator.impactOccurred()
      } else {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
      }
    }
  }

  @objc public func notification(_ call: CAPPluginCall) {
      DispatchQueue.main.async {
        let generator = UINotificationFeedbackGenerator()
        if let type = call.options["type"] as? String {
          var notificationType = UINotificationFeedbackGenerator.FeedbackType.success
          if type == "WARNING" {
                notificationType = UINotificationFeedbackGenerator.FeedbackType.warning
          } else if type == "ERROR" {
            notificationType = UINotificationFeedbackGenerator.FeedbackType.error
          }
          generator.notificationOccurred(notificationType)
        } else {
          generator.notificationOccurred(.success)
        }
    }
  }

  @objc public func selectionStart(_ call: CAPPluginCall) {
    DispatchQueue.main.async {
      self.selectionFeedbackGenerator = UISelectionFeedbackGenerator()
      self.selectionFeedbackGenerator?.prepare()
    }
  }

  @objc public func selectionChanged(_ call: CAPPluginCall) {
    DispatchQueue.main.async {
      if let generator = self.selectionFeedbackGenerator {
        generator.selectionChanged()
        generator.prepare()
      }
    }
  }

  @objc public func selectionEnd(_ call: CAPPluginCall) {
    DispatchQueue.main.async {
      self.selectionFeedbackGenerator = nil
    }
  }

  @objc public func vibrate(_ call: CAPPluginCall) {
    if !supportsHaptics {
      DispatchQueue.main.async {
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
      }
    } else {
        let duration = call.options["duration"] as? String
        let hapticDict = [
        CHHapticPattern.Key.pattern: [
            [CHHapticPattern.Key.event:
              [CHHapticPattern.Key.eventType: CHHapticEvent.EventType.hapticTransient,
                  CHHapticPattern.Key.time: 0.001,
                  CHHapticPattern.Key.eventDuration: duration]
            ]
          ]
        ]
        try player.start(atTime: 0)
    }
  }
}
