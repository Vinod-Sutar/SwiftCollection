//
//  GuidelineItem.swift
//  SwiftCollectionView
//
//  Created by BBI-M USER1033 on 01/09/17.
//  Copyright © 2017 BBI-M USER1033. All rights reserved.
//

import Cocoa

class GuidelineItem: NSCollectionViewItem {
    
    @IBOutlet var guidelineTitleLabel: NSTextField!
    
    @IBOutlet var guidelineImage: NSImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guidelineImage.wantsLayer = true;
        guidelineImage.layer?.cornerRadius = 20;
        guidelineImage.layer?.borderColor = NSColor(white: 0.80, alpha:1.0).cgColor;
        guidelineImage.layer?.borderWidth = 0.5;
        guidelineImage.layer?.shadowColor = NSColor.gray.cgColor
        guidelineImage.layer?.shadowRadius = 12
        guidelineImage.layer?.shadowOffset = CGSize(width: 12, height: 12)
        
        
        // Do view setup here.
    }
}
