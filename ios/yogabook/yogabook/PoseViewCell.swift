//
//  PoseViewCell.swift
//  yogabook
//
//  Created by Juan-Manuel Fluxá on 8/2/14.
//  Copyright (c) 2014 fluxa.io. All rights reserved.
//

import UIKit


class PoseViewCell : UICollectionViewCell {
    
    @IBOutlet var sanskritLabel: UILabel?
    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var categoryLabel: UILabel?
    @IBOutlet var thumbnail: UIImageView?
    @IBOutlet var spinner: UIActivityIndicatorView?
    
    var _data: Pose?
    var data: Pose {
    set(newValue) {
        _data = newValue
        render()
    }
    get {
        return _data!
    }
    
    }
    
    func render() {
        if _data != nil {
            self.sanskritLabel!.text = self.data.sanskrit
            self.titleLabel!.text = self.data.prettyName()
            self.categoryLabel!.text = self.data.category
            
            self.spinner!.hidden = false
            self.spinner!.startAnimating()
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                [weak self] in
                let th = UIImage(named: self!.data.key+"_th")
                dispatch_async(dispatch_get_main_queue(), {
                    self!.thumbnail!.image = th
                    self!.spinner!.hidden = true
                })
            })
            
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        _data = nil
        self.sanskritLabel!.text = ""
        self.titleLabel!.text = ""
        self.categoryLabel!.text = ""
        self.thumbnail!.image = nil
        self.spinner!.hidden = true
    }
    
}
