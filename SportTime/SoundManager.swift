import Foundation
import AVFoundation

class SoundManager: ObservableObject {
    static let shared = SoundManager()
    
    private var audioPlayer: AVAudioPlayer?
    
    private init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    func playTimerSound() {
        guard let soundURL = Bundle.main.url(forResource: "timer_beep", withExtension: "wav") else {
            // Fallback to system sound
            AudioServicesPlaySystemSound(1005) // System sound
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Failed to play sound: \(error)")
            // Fallback to system sound
            AudioServicesPlaySystemSound(1005)
        }
    }
    
    func playWorkoutCompleteSound() {
        guard let soundURL = Bundle.main.url(forResource: "workout_complete", withExtension: "wav") else {
            // Fallback to system sound
            AudioServicesPlaySystemSound(1006) // System sound
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Failed to play sound: \(error)")
            // Fallback to system sound
            AudioServicesPlaySystemSound(1006)
        }
    }
    
    func playIntervalSound() {
        AudioServicesPlaySystemSound(1007) // System sound for intervals
    }
} 