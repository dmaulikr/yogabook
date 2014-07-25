//
//  Data.swift
//  yogabook
//
//  Created by Juan-Manuel Fluxá on 7/19/14.
//  Copyright (c) 2014 fluxa.io. All rights reserved.
//

import Foundation

class Data {
    class var sharedInstance : Data {
    struct Static {
        static let instance : Data = Data()
        }
        return Static.instance
    }
    
    func unarchiveObjectForKey(key: String) -> AnyObject! {
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
    
    func archiveObject(anObject: AnyObject, key: String) {
        let documentsPath: String = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask,true)[0] as String
        let file = documentsPath.stringByAppendingPathComponent(key)
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
        archiver.encodeObject(anObject, forKey: key)
        archiver.finishEncoding()
        data.writeToFile(file, atomically: true)
        
    }
}

