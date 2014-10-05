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
    
    // Ordered
    var mySequences: [YogaSequence] = [YogaSequence]()
    
    init() {
        
        // Defining empty containers
        var _poses = [Pose]()
        var _posesDict = Dictionary<String, Pose>()
        
        // Parsing / Unserializing
        
        // poses
        if let posesURL = NSBundle.mainBundle().URLForResource("poses", withExtension: "json") {
            var error: NSError?
            let posesData = NSData(contentsOfURL: posesURL, options: nil, error: &error)
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
        }
        
        // mySequences
        var _mySequencesDict: Dictionary<String, YogaSequence>
        var _unarchivedMySeqs: AnyObject? = Data.unarchiveObjectForKey(MySequencesKey)
        if _unarchivedMySeqs == nil {
            _mySequencesDict = Dictionary<String, YogaSequence>()
        } else {
            _mySequencesDict = _unarchivedMySeqs as Dictionary<String, YogaSequence>
        }
        
        // sequences
        if let sequenceURL = NSBundle.mainBundle().URLForResource("sequences", withExtension: "json") {
            var error: NSError?
            let sequencesData = NSData(contentsOfURL: sequenceURL, options: nil, error: &error)
            if error == nil {
                let sequencesJSON: [NSDictionary] = NSJSONSerialization.JSONObjectWithData(sequencesData, options: nil, error: &error) as [NSDictionary]
                if error == nil {
                    for rawSeq in sequencesJSON {
                        let seqKey = rawSeq["key"] as String
                        let seqTitle = rawSeq["title"] as String
                        //                    println("parsing sequence: \(seqTitle) key: \(seqKey)")
                        if let seq = _mySequencesDict[seqKey] {
                            println("skipping \(seqTitle) -> already found in dict")
                        } else {
                            let sequence = YogaSequence()
                            sequence.key = seqKey
                            sequence.title = seqTitle;
                            
                            var poses: [PoseInSequence] = [PoseInSequence]()
                            let rawPoses: [NSDictionary] = rawSeq["poses"] as [NSDictionary]
                            var healthy = true
                            for rawPose in rawPoses {
                                let poseKey = rawPose["poseKey"] as String
                                let poseSecs = rawPose["seconds"] as Int
                                if let pose = _posesDict[poseKey] {
                                    if poseSecs > 0 {
                                        let poseInSeq = PoseInSequence(poseKey: poseKey)
                                        poseInSeq.seconds = poseSecs
                                        poses.append(poseInSeq)
                                        //                                    println("pose is healthy: \(poseKey) secs: \(poseSecs)")
                                    } else {
                                        healthy = false
                                        //                                    println("bad pose seconds for \(poseKey) in sequence: \(seqTitle)")
                                    }
                                    
                                } else {
                                    healthy = false
                                    println("pose not found: \(poseKey) in sequence: \(seqTitle). skipping")
                                }
                            }
                            
                            if healthy {
                                sequence.poses = poses
                                _mySequencesDict[seqKey] = sequence
                            }
                            
                        }
                    }
                }

            }
        }
        
        
        // Assigning values
        self.poses = _poses
        self.posesDict = _posesDict
        self.mySequencesDict = _mySequencesDict as Dictionary<String, YogaSequence>
        updateAll()
        saveAll()
        
        // Debugging
//        let y = YogaSequence()
//        y.title = "HELLOW WORLD"
//        insertSequence(y)
    
    }
    
    func updateAll() {
        let sequencesUnordered = Array(self.mySequencesDict.values) as [YogaSequence]
        mySequences = sequencesUnordered.sorted({$0.sortingIndex < $1.sortingIndex})
    }
    
    func insertSequence(yogaSequence: YogaSequence) {
        mySequencesDict[yogaSequence.key] = yogaSequence
        updateAll()
        saveAll()
    }
    
    func removeSequenceWithKey(sequenceKey: String) {
        println(mySequencesDict.count)
        mySequencesDict.removeValueForKey(sequenceKey)
        updateAll()
        saveAll()
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
            var error: NSError?
            let data = NSData(contentsOfFile: file, options: nil, error: &error)
            if error == nil {
                let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
                anObject = unarchiver.decodeObjectForKey(key)
                unarchiver.finishDecoding()
            }
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

