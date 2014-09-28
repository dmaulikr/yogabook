//
//  Models.swift
//  yogabook
//
//  Created by Juan-Manuel Fluxá on 7/19/14.
//  Copyright (c) 2014 fluxa.io. All rights reserved.
//

import Foundation
import UIKit

class YogaSequence: NSObject, NSCoding {
    
    var key: String
    var title: String
    var poses: [PoseInSequence]
    var sortingIndex: Int
    let intermissonSeconds = 10
    
    override init()  {
        self.key = NSUUID().UUIDString
        self.title = ""
        self.poses = [PoseInSequence]()
        self.sortingIndex = -1
    }
    
    required init(coder aDecoder: NSCoder) {
        self.key = aDecoder.decodeObjectForKey("key") as String
        self.title = aDecoder.decodeObjectForKey("title") as String
        self.poses = aDecoder.decodeObjectForKey("poses") as [PoseInSequence]
        self.sortingIndex = aDecoder.decodeIntegerForKey("sortingIndex")
        
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.key, forKey: "key")
        aCoder.encodeObject(self.title, forKey: "title")
        aCoder.encodeObject(self.poses, forKey: "poses")
        aCoder.encodeInteger(self.sortingIndex, forKey: "sortingIndex")
    }
    
    func getMinutesSeconds() -> (Int, Int) {
        
        var totalTime = 0
        for poseInSequence in self.poses {
            totalTime += poseInSequence.seconds
        }
        
        // Adding intermission time
        if self.poses.count > 0 {
            totalTime += self.intermissonSeconds*(self.poses.count-1)
        }
        
        let minutes = Int(totalTime/60)
        let seconds = Int(totalTime % 60)
        return (minutes, seconds)
    }
}

class Pose: NSObject, NSCoding {
    
    var key: String
    var sanskrit: String
    var category: String
    
    init(raw: NSDictionary) {
        self.key = raw["key"] as String
        self.category = raw["category"] as String
        if let sanskrit = raw["sanskrit"] as? String {
            self.sanskrit = sanskrit
        } else {
            self.sanskrit = ""
        }
        
        // Debugging
        // Check if image exists
//        let img_th = UIImage(named:self.key+"_th")
//        if img_th.size.width == 0 || img_th.size.height == 0 {
//            println("missing image for pose key \(self.key)")
//        }
        
    }
    
    required init(coder aDecoder: NSCoder) {
        self.key = aDecoder.decodeObjectForKey("key") as String
        self.sanskrit = aDecoder.decodeObjectForKey("sanskrit") as String
        self.category = aDecoder.decodeObjectForKey("category") as String
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.key, forKey: "key")
        aCoder.encodeObject(self.sanskrit, forKey: "sanskrit")
        aCoder.encodeObject(self.category, forKey: "category")
    }
    
    // Helpers
    func prettyName() -> NSString {
        var pretty = self.key.stringByReplacingOccurrencesOfString("-", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil)
        return pretty
    }
}

class PoseInSequence: NSObject, NSCoding {
    
    var poseKey: String
    var seconds: Int
    
    init(poseKey: String) {
        self.poseKey = poseKey
        self.seconds = 15 // Default
    }
    
    required init(coder aDecoder: NSCoder) {
        self.poseKey = aDecoder.decodeObjectForKey("poseKey") as String
        self.seconds = aDecoder.decodeIntegerForKey("seconds")
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.poseKey, forKey: "poseKey")
        aCoder.encodeInteger(self.seconds, forKey: "seconds")
    }
    
    
}
