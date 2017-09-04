//
//  Guideline.swift
//  SwiftCollectionView
//
//  Created by BBI-M USER1033 on 01/09/17.
//  Copyright © 2017 BBI-M USER1033. All rights reserved.
//

import Cocoa

class Guideline: NSObject {
    
    var guidelineId: String = ""
    var guidelineName: String = ""
    var guidelineVersion: String = ""
    var guidelineImagePath: String = ""
    
    init(_ guidelineDictionary: NSDictionary) {
        
        let trackId: Int = guidelineDictionary["trackId"] as! Int
        guidelineId = String(describing: trackId)
        guidelineName = guidelineDictionary["trackName"] as! String
        guidelineVersion = guidelineDictionary["version"] as! String
        guidelineImagePath = guidelineDictionary["artworkUrl512"] as! String
    }
    
    func getGuidelineImagePath() -> String {
        
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return "\(documentDirectory)/Images/\(guidelineId)_\(guidelineVersion).png"
    }
    
    func getGuidelineImage() -> NSImage? {
        
        return NSImage(contentsOfFile: getGuidelineImagePath())!
    }
    
    func isGuidelineImageExists() -> Bool {
        
        return FileManager.default.fileExists(atPath: getGuidelineImagePath())
    }
}
