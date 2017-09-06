//
//  Guideline.swift
//  SwiftCollectionView
//
//  Created by BBI-M USER1033 on 01/09/17.
//  Copyright © 2017 BBI-M USER1033. All rights reserved.
//

import Cocoa

class Guideline: NSObject {
    
    var identifier: String = ""
    var name: String = ""
    var version: String = ""
    var imagePath: String = ""
    
    init(_ guidelineDictionary: NSDictionary) {
        
        let trackId: Int = guidelineDictionary["trackId"] as! Int
        identifier = String(describing: trackId)
        name = guidelineDictionary["trackName"] as! String
        version = guidelineDictionary["version"] as! String
        imagePath = guidelineDictionary["artworkUrl512"] as! String
    }
    
    func getGuidelineImagePath() -> String {
        
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return "\(documentDirectory)/Images/\(identifier)_\(version).png"
    }
    
    func getGuidelineImage() -> NSImage? {
        
        return NSImage(contentsOfFile: getGuidelineImagePath())!
    }
    
    func isGuidelineImageExists() -> Bool {
        
        return FileManager.default.fileExists(atPath: getGuidelineImagePath())
    }
}
