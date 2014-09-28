
//
//  PlaySequenceViewController.swift
//  yogabook
//
//  Created by Juan-Manuel Fluxá on 8/9/14.
//  Copyright (c) 2014 fluxa.io. All rights reserved.
//

import UIKit

class PlaySequenceViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var sanskritLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var playImageView: UIImageView!
    @IBOutlet var clockImageView: UIImageView!
    
    var yogaSequence: YogaSequence?
    var poseIndex = 0
    var currentPoseInSequence: PoseInSequence?
    var currentPose: Pose?
    var isIntermission = true
    var isPaused = true
    var timer: NSTimer?
    var currentSecondsLeft = 0
    var intermissionSecondsLeft = 0
    var didSpeakName = false
    var pause_closure: dispatch_cancelable_closure?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: "onTapGesture:")
        tapGesture.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapGesture)
        self.poseIndex = 0
        self.currentSecondsLeft = 0
        self.intermissionSecondsLeft = 10
        self.clockImageView.hidden = true
        renderCurrent()
    }
    
    override func viewDidAppear(animated: Bool) {
        UIApplication.sharedApplication().idleTimerDisabled = true
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        UIApplication.sharedApplication().idleTimerDisabled = false
        super.viewDidDisappear(animated)
    }
    
    
    func renderCurrent() {
        self.currentPoseInSequence = self.yogaSequence!.poses[self.poseIndex]
        self.currentPose = Data.sharedInstance.posesDict[self.currentPoseInSequence!.poseKey]!
        self.titleLabel.text = self.currentPose!.prettyName()
        self.sanskritLabel.text = self.currentPose!.sanskrit
        self.imageView.image = UIImage(named: self.currentPose!.key)
        
        let poseSecs = self.currentPoseInSequence!.seconds
        self.currentSecondsLeft = poseSecs
        updateUI()
    }
    
    func togglePause() {
        
        if self.isPaused {
            // play
            if self.timer == nil {
                
                cancel_delay(self.pause_closure)
                self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "onTimerTick", userInfo: nil, repeats: true)
                
                UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                    [weak self] in
                    self!.playImageView.transform = CGAffineTransformMakeScale(1.5, 1.5)
                    self!.playImageView.alpha = 0
                }, completion: {
                    [weak self] (finished: Bool) -> () in
                    self!.playImageView.hidden = true
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
            self.playImageView.hidden = false
            self.clockImageView.hidden = true
            UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                [weak self] in
                self!.playImageView.transform = CGAffineTransformMakeScale(1.0, 1.0)
                self!.playImageView.alpha = 0.6
            }, completion: nil)
        }
        
        self.isPaused = !self.isPaused
        
    }
    
    func onTapGesture(gesture: UITapGestureRecognizer) {
        togglePause()
    }
    
    func onTimerTick() {
        
        if isIntermission {
            clockImageView.hidden = false
            if intermissionSecondsLeft > 0 {
                if intermissionSecondsLeft <= 3 {
                    AudioPlayer.sharedInstance.speakText(String(intermissionSecondsLeft))
                }
                intermissionSecondsLeft--
            } else {
                // Change to play
                isIntermission = false
                clockImageView.hidden = true
                AudioPlayer.sharedInstance.speakText("Go!")
            }
        } else {
            if currentSecondsLeft > 0 {
                if currentSecondsLeft <= 3 {
                    AudioPlayer.sharedInstance.speakText(String(currentSecondsLeft))
                }
                if currentSecondsLeft % 10 == 0 && currentSecondsLeft != 0{
                    AudioPlayer.sharedInstance.speakText(String(currentSecondsLeft) + " seconds remaining")
                }
                updateUI()
                currentSecondsLeft--
            } else {
                
                AudioPlayer.sharedInstance.speakText("Rest")
                self.poseIndex++
                if self.poseIndex < self.yogaSequence!.poses.count {
                    // Pose change
                    renderCurrent()
//                    AudioPlayer.sharedInstance.playSound(AudioPlayer.Sound.ChangePose)
                    didSpeakName = false
                    
                    // Change to intermission
                    self.intermissionSecondsLeft = self.yogaSequence!.intermissonSeconds
                    self.isIntermission = true
                } else {
                    // Sequence finished!
                    self.togglePause()
                    self.poseIndex = 0
                    renderCurrent()
                    AudioPlayer.sharedInstance.speakText("Finished!")
                    AudioPlayer.sharedInstance.speakText("Great work!")
                    AudioPlayer.sharedInstance.speakText("You droppy animal")
                }
            }
        }
        
        if !didSpeakName {
            didSpeakName = true
            AudioPlayer.sharedInstance.speakText("Get ready for:")
            AudioPlayer.sharedInstance.speakText(self.currentPose!.prettyName())
        }
        
        self.pause_closure = nil
    }
    
    func updateUI() {
        let (mins, secs) = Utils.getMinuteSecondsForSeconds(self.currentSecondsLeft)
        self.timeLabel.text = String(format: "%.2d:%.2d", mins, secs)
    }
    
    @IBAction func quit() {
        if self.timer != nil {
            self.timer!.invalidate()
            self.timer = nil
        }
        self.navigationController!.popViewControllerAnimated(true);
    }
    
}
