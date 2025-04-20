import Foundation
import AVFoundation

/// SoundManager is a singleton class that handles all audio in the game
class SoundManager {
    // MARK: - Singleton
    static let shared = SoundManager()
    
    // MARK: - Properties
    
    // Audio players
    private var backgroundMusicPlayer: AVAudioPlayer?
    private var soundEffectPlayers: [String: AVAudioPlayer] = [:]
    
    // Cached audio data to improve performance
    private var cachedSoundData: [String: Data] = [:]
    
    // Settings
    var isMusicEnabled: Bool {
        get { return GameManager.shared.musicEnabled }
        set { GameManager.shared.musicEnabled = newValue }
    }
    
    var isSoundEnabled: Bool {
        get { return GameManager.shared.soundEnabled }
        set { GameManager.shared.soundEnabled = newValue }
    }
    
    // Volume levels
    var musicVolume: Float = 0.7
    var soundEffectsVolume: Float = 1.0
    
    // Track current music
    private var currentMusicTrack: String?
    
    // MARK: - Initialization
    
    private init() {
        // Private initializer to enforce singleton pattern
        setupAudioSession()
    }
    
    // MARK: - Setup
    
    /// Set up the audio session for the app
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Music Methods
    
    /// Play background music
    /// - Parameters:
    ///   - filename: Name of the music file
    ///   - fileExtension: Extension of the music file (default is "mp3")
    ///   - loops: Whether the music should loop (default is true)
    func playBackgroundMusic(filename: String, fileExtension: String = "mp3", loops: Bool = true) {
        guard isMusicEnabled else { return }
        
        // Don't restart the same track if it's already playing
        if currentMusicTrack == filename, backgroundMusicPlayer?.isPlaying == true {
            return
        }
        
        currentMusicTrack = filename
        
        // Stop any currently playing music
        backgroundMusicPlayer?.stop()
        
        // Create and play the new music track
        guard let url = Bundle.main.url(forResource: filename, withExtension: fileExtension) else {
            print("Could not find music file: \(filename).\(fileExtension)")
            return
        }
        
        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundMusicPlayer?.volume = musicVolume
            backgroundMusicPlayer?.numberOfLoops = loops ? -1 : 0 // -1 means infinite looping
            backgroundMusicPlayer?.prepareToPlay()
            backgroundMusicPlayer?.play()
        } catch {
            print("Failed to play background music: \(error.localizedDescription)")
        }
    }
    
    /// Stop the currently playing background music
    func stopBackgroundMusic() {
        backgroundMusicPlayer?.stop()
        currentMusicTrack = nil
    }
    
    /// Pause the currently playing background music
    func pauseBackgroundMusic() {
        backgroundMusicPlayer?.pause()
    }
    
    /// Resume the paused background music
    func resumeBackgroundMusic() {
        guard isMusicEnabled else { return }
        backgroundMusicPlayer?.play()
    }
    
    /// Set the volume of the background music
    /// - Parameter volume: Volume level (0.0 to 1.0)
    func setMusicVolume(_ volume: Float) {
        musicVolume = min(max(volume, 0.0), 1.0)
        backgroundMusicPlayer?.volume = musicVolume
    }
    
    // MARK: - Sound Effects Methods
    
    /// Play a sound effect
    /// - Parameters:
    ///   - filename: Name of the sound effect file
    ///   - fileExtension: Extension of the sound effect file (default is "wav")
    func playSoundEffect(filename: String, fileExtension: String = "wav") {
        guard isSoundEnabled else { return }
        
        // First check if we have cached this sound
        if let soundData = cachedSoundData[filename] {
            playFromCachedData(soundData, forSound: filename)
            return
        }
        
        // Load and cache the sound if not already cached
        guard let url = Bundle.main.url(forResource: filename, withExtension: fileExtension) else {
            print("Could not find sound effect: \(filename).\(fileExtension)")
            return
        }
        
        do {
            let soundData = try Data(contentsOf: url)
            cachedSoundData[filename] = soundData
            playFromCachedData(soundData, forSound: filename)
        } catch {
            print("Failed to load sound effect: \(error.localizedDescription)")
        }
    }
    
    /// Play sound from cached data
    /// - Parameters:
    ///   - data: Sound data
    ///   - soundName: Name of the sound (for tracking)
    private func playFromCachedData(_ data: Data, forSound soundName: String) {
        do {
            let player = try AVAudioPlayer(data: data)
            player.volume = soundEffectsVolume
            player.prepareToPlay()
            player.play()
            
            // Store a reference to prevent the player from being deallocated
            soundEffectPlayers[soundName] = player
            
            // Set up a callback to remove the player once it's done
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(soundEffectFinished(_:)),
                name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                object: player
            )
        } catch {
            print("Failed to play sound effect from cached data: \(error.localizedDescription)")
        }
    }
    
    /// Callback for when a sound effect finishes playing
    @objc private func soundEffectFinished(_ notification: Notification) {
        guard let player = notification.object as? AVAudioPlayer else { return }
        
        // Remove the player from our tracking dictionary
        for (key, value) in soundEffectPlayers {
            if value === player {
                soundEffectPlayers.removeValue(forKey: key)
                break
            }
        }
    }
    
    /// Set the volume for all sound effects
    /// - Parameter volume: Volume level (0.0 to 1.0)
    func setSoundEffectsVolume(_ volume: Float) {
        soundEffectsVolume = min(max(volume, 0.0), 1.0)
        
        // Update currently playing sound effects
        for player in soundEffectPlayers.values {
            player.volume = soundEffectsVolume
        }
    }
    
    /// Stop all currently playing sound effects
    func stopAllSoundEffects() {
        for player in soundEffectPlayers.values {
            player.stop()
        }
        soundEffectPlayers.removeAll()
    }
    
    // MARK: - Preloading
    
    /// Preload a sound effect to avoid loading lag when playing
    /// - Parameters:
    ///   - filename: Name of the sound effect file
    ///   - fileExtension: Extension of the sound effect file (default is "wav")
    func preloadSoundEffect(filename: String, fileExtension: String = "wav") {
        // Skip if already cached
        if cachedSoundData[filename] != nil {
            return
        }
        
        guard let url = Bundle.main.url(forResource: filename, withExtension: fileExtension) else {
            print("Could not find sound effect for preloading: \(filename).\(fileExtension)")
            return
        }
        
        do {
            let soundData = try Data(contentsOf: url)
            cachedSoundData[filename] = soundData
            print("Preloaded sound effect: \(filename)")
        } catch {
            print("Failed to preload sound effect: \(error.localizedDescription)")
        }
    }
    
    /// Preload multiple sound effects
    /// - Parameter filenames: Array of sound effect filenames (without extensions)
    func preloadSoundEffects(_ filenames: [String], fileExtension: String = "wav") {
        for filename in filenames {
            preloadSoundEffect(filename: filename, fileExtension: fileExtension)
        }
    }
    
    // MARK: - Cleanup
    
    /// Clear cache to free up memory
    func clearSoundCache() {
        cachedSoundData.removeAll()
    }
}
