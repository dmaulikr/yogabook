//
//  YogaSequenceViewCell.swift
//  yogabook
//
//  Created by Juan-Manuel Fluxá on 7/19/14.
//  Copyright (c) 2014 fluxa.io. All rights reserved.
//

import UIKit

class YogaSequenceViewCell : UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var plusLabel: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var imageView: UIImageView!

    var _data: YogaSequence?
    var data: YogaSequence {
    set(newValue) {
        _data = newValue
        render()
    }
    get {
        return _data!
    }
    
    }
    
    var editAction :(YogaSequence -> ())?
    
    var removeAction :(YogaSequence -> ())?
    
    var otherBlock: (YogaSequence -> ())?
    
    @IBAction func onEdit(AnyObject) {
        if let action = self.editAction {
            action(self.data)
        }
    }
    
    @IBAction func onRemove(AnyObject) {
        if let action = self.removeAction {
            action(self.data)
        }
    }
    
    func render() {
        if _data != nil {
            self.plusLabel.hidden = true
            self.titleLabel.hidden = false
            self.titleLabel.text = _data!.title
            self.editBtn.hidden = false
            let (minutes, seconds) = self.data.getMinutesSeconds()
            self.totalTimeLabel.text = String(format: "%.2d m %.2d s", minutes, seconds)
            self.totalTimeLabel.hidden = false
            
            // Load first pose image
            if self.data.poses.count > 0 {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                    [weak self] in
                    let pose = self!.data.poses[0]
                    let th = UIImage(named: pose.poseKey+"_th")
                    dispatch_async(dispatch_get_main_queue(), {
                        self!.imageView.image = th
                    })
                })
            }
            
        }
    }
    
    func renderLast() {
        self.titleLabel.hidden = true
        self.editBtn.hidden = true
        self.totalTimeLabel.hidden = true
        self.plusLabel.hidden = false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        _data = nil
        self.removeAction = nil
        self.editAction = nil
        self.titleLabel.text = ""
        self.editBtn.hidden = true
        self.totalTimeLabel.hidden = true
        self.plusLabel.hidden = true
        self.imageView.image = nil
    }
    
}
