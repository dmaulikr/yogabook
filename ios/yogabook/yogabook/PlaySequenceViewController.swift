
//
//  PlaySequenceViewController.swift
//  yogabook
//
//  Created by Juan-Manuel Fluxá on 8/9/14.
//  Copyright (c) 2014 fluxa.io. All rights reserved.
//

import UIKit

class PlaySequenceViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView?
    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var sanskritLabel: UILabel?
    @IBOutlet var timeLabel: UILabel?
    @IBOutlet var playImageView: UIImageView?
    @IBOutlet var clockImageView: UIImageView?
    
    var yogaSequence: YogaSequence?
    var poseIndex: Int = 0
    var currentPoseInSequence: PoseInSequence?
    var currentPose: Pose?
    var isIntermission: Bool = false
    var isPaused: Bool = true
    var timer: NSTimer?
    var currentSecondsLeft: Int = 0
    var intermissionSecondsLeft: Int = 0
    let intermissionTotalSeconds = 10
    var pause_closure: dispatch_cancelable_closure?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: "onTapGesture:")
        tapGesture.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapGesture)
        self.poseIndex = 0
        self.currentSecondsLeft = 0
        self.intermissionSecondsLeft = 0
        self.clockImageView!.hidden = true
        renderCurrent()
    }
    
    
    func renderCurrent() {
        self.currentPoseInSequence = self.yogaSequence!.poses[self.poseIndex]
        self.currentPose = Data.sharedInstance.posesDict[self.currentPoseInSequence!.poseKey]!
        self.titleLabel!.text = self.currentPose!.prettyName()
        self.sanskritLabel!.text = self.currentPose!.sanskrit
        self.imageView!.image = UIImage(named: self.currentPose!.key)
        
        let poseSecs = self.currentPoseInSequence!.seconds
        self.currentSecondsLeft = poseSecs
        updateUI()
    }
    
    func togglePause() {
        
        if self.isPaused {
            // play
            if self.timer == nil {
                
                cancel_delay(self.pause_closure)
                self.pause_closure = delay(3, {
                    [weak self] in
                    AudioPlayer.sharedInstance.playSound(AudioPlayer.Sound.TickB)
                    self!.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "onTimerTick", userInfo: nil, repeats: true)
                });
                
                UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                    [weak self] in
                    self!.playImageView!.transform = CGAffineTransformMakeScale(1.5, 1.5)
                    self!.playImageView!.alpha = 0
                }, completion: {
                    [weak self] (finished: Bool) -> () in
                    self!.playImageView!.hidden = true
                })
            }
        } else {
            // pause
            cancel_delay(self.pause_closure)
            self.pause_closure = nil
            if self.timer != nil {
                self.timer!.invalidate()
                self.timer = nil
            }
            self.playImageView!.hidden = false
            self.clockImageView!.hidden = true
            UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                [weak self] in
                self!.playImageView!.transform = CGAffineTransformMakeScale(1.0, 1.0)
                self!.playImageView!.alpha = 0.6
            }, completion: nil)
        }
        
        self.isPaused = !self.isPaused
        
    }
    
    func onTapGesture(gesture: UITapGestureRecognizer) {
        togglePause()
    }
    
    func onTimerTick() {
        
        if self.isIntermission {
            self.clockImageView!.hidden = false
            if self.intermissionSecondsLeft > 0 {
                AudioPlayer.sharedInstance.playSound(AudioPlayer.Sound.TickA)
                self.intermissionSecondsLeft--
            } else {
                // Change to play
                self.isIntermission = false
                self.clockImageView!.hidden = true
//                self.currentSecondsLeft = self.currentPoseInSequence!.seconds
                AudioPlayer.sharedInstance.playSound(AudioPlayer.Sound.TickB)
            }
        } else {
            if self.currentSecondsLeft > 0 {
                self.currentSecondsLeft--
                if self.currentSecondsLeft % 5 == 0 {
                    AudioPlayer.sharedInstance.playSound(AudioPlayer.Sound.TickB)
                }
                updateUI()
            } else {
                
                self.poseIndex++
                if self.poseIndex < self.yogaSequence!.poses.count {
                    // Pose change
                    renderCurrent()
                    AudioPlayer.sharedInstance.playSound(AudioPlayer.Sound.ChangePose)
                    
                    // Change to intermission
                    self.intermissionSecondsLeft = self.intermissionTotalSeconds
                    self.isIntermission = true
                } else {
                    // Sequence finished!
                    self.togglePause()
                    self.poseIndex = 0
                    renderCurrent()
                    AudioPlayer.sharedInstance.playSound(AudioPlayer.Sound.FinishedSequence)
                }
            }
        }
        
        self.pause_closure = nil
    }
    
    func updateUI() {
        let (mins, secs) = Utils.getMinuteSecondsForSeconds(self.currentSecondsLeft)
        self.timeLabel!.text = String(format: "%.2d:%.2d", mins, secs)
    }
    
    @IBAction func quit() {
        if self.timer != nil {
            self.timer!.invalidate()
            self.timer = nil
        }
        self.navigationController.popViewControllerAnimated(true)
    }
    
}
