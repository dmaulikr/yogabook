//
//  Utils.swift
//  yogabook
//
//  Created by Juan-Manuel Fluxá on 8/10/14.
//  Copyright (c) 2014 fluxa.io. All rights reserved.
//

import Foundation
import AudioToolbox
import AVFoundation

class Utils {
    
    class func getMinuteSecondsForSeconds(totalSecs: Int) -> (Int, Int) {
        let minutes = Int(totalSecs/60)
        let seconds = Int(totalSecs % 60)
        return (minutes, seconds)
    }
    
}

class AudioPlayer: NSObject, AVAudioPlayerDelegate {
    
    enum Sound {
        case ChangePose, TickA, TickB, FinishedSequence
        func components() -> (String, String) {
            switch self {
            case .ChangePose:
                return ("pose_change_bell","aif")
            case .TickA:
                return ("tickA", "aif")
            case .TickB:
                return ("tickB", "aif")
            case .FinishedSequence:
                return ("finished_sequence", "aif")
            }
            
        }
        static let allValues = [ChangePose, TickA, TickB, FinishedSequence]
    }
    
    class var sharedInstance : AudioPlayer {
    struct Static {
        static let instance : AudioPlayer = AudioPlayer()
        }
        return Static.instance
    }
    
    override init() {
        let avsession = AVAudioSession.sharedInstance()
        var error: NSError?
        avsession.setCategory(AVAudioSessionCategoryPlayback, error: &error)
        super.init()
        self.preloadSounds()
        println("AudioPlayer init")
    }
    
    var players: [AVAudioPlayer] = [AVAudioPlayer]()
    var soundsDict: Dictionary<String, NSData> = Dictionary<String, NSData>()
    
    func preloadSounds() {
        for sound in Sound.allValues {
            let (name, ext) = sound.components()
            let url = NSBundle.mainBundle().URLForResource(name, withExtension: ext)!
            var error: NSError?
            let data = NSData.dataWithContentsOfURL(url, options: NSDataReadingOptions.DataReadingMappedAlways, error: &error)
            if error == nil {
                self.soundsDict[name] = data
            }
        }
    }
    
    func playSound(sound: Sound) {
        
        let (name, ext) = sound.components()
        //        let url = NSBundle.mainBundle().URLForResource(name, withExtension: ext)
        let data = self.soundsDict[name]
        var error: NSError?
        //        let player = AVAudioPlayer(contentsOfURL: url, error: &error)
        let player = AVAudioPlayer(data: data, error: &error)
        if error == nil {
            self.players.append(player)
            player.delegate = self
            player.prepareToPlay()
            player.play()
        }
    }
    
    func removePlayer(player: AVAudioPlayer) {
        var indexToRemove = -1
        var index = 0
        for p in self.players {
            if player == p {
                indexToRemove = index
            }
            index++
        }
        if indexToRemove > -1 {
            self.players.removeAtIndex(indexToRemove)
        }
        println("\(self.players.count) players in array")
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        removePlayer(player)
    }
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer!, error: NSError!) {
        println("audioPlayerDecodeErrorDidOccur")
        removePlayer(player)
    }
    
    func audioPlayerBeginInterruption(player: AVAudioPlayer!) {
        println("audioPlayerBeginInterruption")
        removePlayer(player)
    }
    
}

typealias dispatch_cancelable_closure = (cancel : Bool) -> ()

func delay(time:NSTimeInterval, closure:()->()) ->  dispatch_cancelable_closure? {
    
    func dispatch_later(clsr:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(time * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), clsr)
    }
    
    var closure:dispatch_block_t? = closure
    var cancelableClosure:dispatch_cancelable_closure?
    
    let delayedClosure:dispatch_cancelable_closure = { cancel in
        if let clsr = closure {
            if (cancel == false) {
                dispatch_async(dispatch_get_main_queue(), clsr);
            }
        }
        closure = nil
        cancelableClosure = nil
    }
    
    cancelableClosure = delayedClosure
    
    dispatch_later {
        if let delayedClosure = cancelableClosure {
            delayedClosure(cancel: false)
        }
    }
    
    return cancelableClosure;
}

func cancel_delay(closure:dispatch_cancelable_closure?) {
    
    if closure != nil {
        closure!(cancel: true)
    }
}

func 🐢(time: Double, clsr:()->()) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(time*Double(NSEC_PER_SEC))), dispatch_get_main_queue(), clsr)
}
