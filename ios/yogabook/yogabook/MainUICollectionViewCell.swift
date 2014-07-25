//
//  MainUICollectionViewCell.swift
//  yogabook
//
//  Created by Juan-Manuel Fluxá on 7/19/14.
//  Copyright (c) 2014 fluxa.io. All rights reserved.
//

import UIKit

class MainUICollectionViewCell : UICollectionViewCell {
    
    @IBOutlet var titleLabel: UILabel
    @IBOutlet var editBtn: UIButton
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
    var editAction :((YogaSequence) -> Void)?
    
    @IBAction func onEdit(AnyObject) {
        if let action = self.editAction {
            action(self.data)
        }
    }
    
    func render() {
        if _data {
            self.titleLabel.text = _data?.title
            self.editBtn.hidden = false
        }
    }
    
    func renderLast() {
        self.titleLabel.text = "ADD NEW"
        self.editBtn.hidden = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.titleLabel.text = ""
        self.editBtn.hidden = true
    }
    
}
