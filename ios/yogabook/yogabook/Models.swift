//
//  Models.swift
//  yogabook
//
//  Created by Juan-Manuel Fluxá on 7/19/14.
//  Copyright (c) 2014 fluxa.io. All rights reserved.
//

import Foundation

class YogaSequence: NSObject, NSCoding {
    
    var title: String

    init()  {
        title = ""
    }
    
    init(coder decoder: NSCoder!) {
        self.title = decoder.decodeObjectForKey("title") as String
    }
    
    func encodeWithCoder(encoder: NSCoder!) {
        encoder.encodeObject(self.title, forKey: "title")
    }
    
    
}

class Pose: NSObject, NSCoding {
    var name: String
    var fileName: String
    
    
    init(coder decoder: NSCoder!) {
        self.name = decoder.decodeObjectForKey("name") as String
        self.fileName = decoder.decodeObjectForKey("fileName") as String
    }
    
    func encodeWithCoder(encoder: NSCoder!) {
        encoder.encodeObject(self.name, forKey: "name")
        encoder.encodeObject(self.fileName, forKey: "fileName")
    }
}