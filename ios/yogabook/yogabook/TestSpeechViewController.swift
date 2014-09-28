//
//  TestSpeechViewController.swift
//  yogabook
//
//  Created by Juan-Manuel Fluxá on 8/24/14.
//  Copyright (c) 2014 fluxa.io. All rights reserved.
//

import UIKit
import AVFoundation

class TextSpeechViewController: UIViewController {
    
    @IBOutlet weak var languageSelector: UISegmentedControl!
    
    @IBOutlet weak var speedLabel: UILabel!
    
    @IBOutlet weak var pitchLabel: UILabel!
    
    @IBOutlet weak var sampleTF: UITextField!
    
    @IBOutlet weak var speedSlider: UISlider!
    
    @IBOutlet weak var pitchSlider: UISlider!
    
    let speech: AVSpeechSynthesizer
    let languages = ["en-US","en-GB","en-AU","en-ZA","en-IE"]
    
    required init(coder aDecoder: NSCoder) {
        self.speech = AVSpeechSynthesizer()
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.languageSelector.removeAllSegments()
        
        var i = 0
        for lan in languages {
            self.languageSelector.insertSegmentWithTitle(lan, atIndex: i, animated: false)
            i++
        }
        self.languageSelector.selectedSegmentIndex = 0
        
        
        updateUI()
    }
    
    @IBAction func speedSliderChanged(sender: AnyObject) {
        updateUI()
    }
    @IBAction func pitchSliderChanged(sender: AnyObject) {
        updateUI()
    }
    
    @IBAction func onSpeak(sender: AnyObject) {
        var utt = AVSpeechUtterance(string: self.sampleTF.text)
        utt.voice = AVSpeechSynthesisVoice(language: self.languages[self.languageSelector.selectedSegmentIndex])
        utt.rate = self.speedSlider.value
        utt.pitchMultiplier = self.pitchSlider.value
        self.speech.speakUtterance(utt)
//        speec.pauseSpeakingAtBoundary(AVSpeechBoundary.Word)
    }
    
    func updateUI() {
        self.speedLabel.text = String(format: "Speed: %.2f", self.speedSlider.value);
        self.pitchLabel.text = String(format: "Pitch: %.2f", self.pitchSlider.value);
    }
}