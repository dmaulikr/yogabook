//
//  Data.swift
//  yogabook
//
//  Created by Juan-Manuel Fluxá on 7/19/14.
//  Copyright (c) 2014 fluxa.io. All rights reserved.
//

import Foundation

let MySequencesKey = "MySequencesKey"

class Data {
    
    class var sharedInstance : Data {
        struct Static {
            static let instance : Data = Data()
        }
        return Static.instance
    }
    
    var poses: [Pose]
    var posesDict: Dictionary<String, Pose>
    var mySequencesDict: Dictionary<String, YogaSequence>
    
    init() {
        
        // Defining empty containers
        var _poses = [Pose]()
        var _posesDict = Dictionary<String, Pose>()
        var _mySequencesDict: AnyObject? = Data.unarchiveObjectForKey(MySequencesKey)
        
        // Parsing / Unserializing
        
        // poses
        var error: NSError?
        let posesURL = NSBundle.mainBundle().URLForResource("poses", withExtension: "json")
        let posesData: NSData = NSData.dataWithContentsOfURL(posesURL, options: nil, error: &error)
        
        if error == nil {
            let posesJSON: [NSDictionary] = NSJSONSerialization.JSONObjectWithData(posesData, options: nil, error: &error) as [NSDictionary]
            if error == nil {
                for poseRaw in posesJSON {
                    let pose = Pose(raw: poseRaw)
                    _poses.append(pose)
                    _posesDict[pose.key] = pose
                }
            }
        }
        
        // mySequences
        if _mySequencesDict == nil {
            _mySequencesDict = Dictionary<String, YogaSequence>()
        }
        
        // Assigning values
        self.poses = _poses
        self.posesDict = _posesDict
        self.mySequencesDict = _mySequencesDict as Dictionary<String, YogaSequence>
        
        // Debugging
//        let y = YogaSequence()
//        y.title = "HELLOW WORLD"
//        self.mySequences.append(y)
//        self.mySequences.append(y)
    
    }
    
    func saveAll() {
        Data.archiveObject(self.mySequencesDict, key: MySequencesKey)
    }
    
    // Static (or Type) Methods
    class func unarchiveObjectForKey(key: String) -> AnyObject! {
        let documentsPath: String = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask,true)[0] as String
        let file = documentsPath.stringByAppendingPathComponent(key)
        var anObject: AnyObject?
        if NSFileManager.defaultManager().fileExistsAtPath(file) {
            let data = NSData(contentsOfFile: file)
            let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
            anObject = unarchiver.decodeObjectForKey(key)
            unarchiver.finishDecoding()
        }
        return anObject
    }
    
    class func archiveObject(anObject: AnyObject, key: String) {
        let documentsPath: String = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask,true)[0] as String
        let file = documentsPath.stringByAppendingPathComponent(key)
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
        archiver.encodeObject(anObject, forKey: key)
        archiver.finishEncoding()
        data.writeToFile(file, atomically: true)
        
    }
}

