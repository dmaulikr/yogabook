//
//  PoseSequenceViewCell.swift
//  yogabook
//
//  Created by Juan-Manuel Fluxá on 8/3/14.
//  Copyright (c) 2014 fluxa.io. All rights reserved.
//

import UIKit


class PoseSequenceViewCell : UICollectionViewCell {
    
    @IBOutlet var sanskritLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var thumbnail: UIImageView!
    @IBOutlet var timeLabel: UILabel!
    
    var _data: PoseInSequence?
    var data: PoseInSequence {
    set(newValue) {
        _data = newValue
        render()
    }
    get {
        return _data!
    }
    
    }
    
    var onTimeChanged :(() -> ())?
    var onItemRemove :(() -> ())?
    
    func render() {
        if _data != nil {
            let pose: Pose = Data.sharedInstance.posesDict[self.data.poseKey]!
            self.sanskritLabel.text = pose.sanskrit
            self.titleLabel.text = pose.prettyName()
            self.categoryLabel.text = pose.category
            self.thumbnail.image = UIImage(named: pose.key+"_th")
            updateTimeLabel()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        _data = nil
        self.onItemRemove = nil
        self.onTimeChanged = nil
        self.sanskritLabel.text = ""
        self.titleLabel.text = ""
        self.categoryLabel.text = ""
        self.thumbnail.image = nil
    }
    
    func updateTimeLabel() {
        let minutes = Int(self.data.seconds/60)
        let seconds = Int(self.data.seconds % 60)
        self.timeLabel.text = String(format: "%.2d m %.2d s", minutes, seconds)
        if self.onTimeChanged != nil {
            self.onTimeChanged!()
        }
    }
    
    @IBAction func minutesUp() {
        self.data.seconds += 60
        updateTimeLabel()
    }
    
    @IBAction func onRemoveItem() {
        if self.onItemRemove != nil {
            self.onItemRemove!()
        }
    }
    
    @IBAction func minutesDown() {
        if self.data.seconds >= 60 {
            self.data.seconds -= 60
        }
        if self.data.seconds < 0 {
            self.data.seconds = 0
        }
        updateTimeLabel()
    }
    
    @IBAction func secondsUp() {
        self.data.seconds += 1
        updateTimeLabel()
    }
    
    @IBAction func secondsDown() {
        self.data.seconds -= 1
        if self.data.seconds < 0 {
            self.data.seconds = 0
        }
        updateTimeLabel()
    }
}

