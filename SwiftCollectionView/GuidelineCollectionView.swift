//
//  GuidelineCollectionView.swift
//  SwiftCollectionView
//
//  Created by BBI-M USER1033 on 01/09/17.
//  Copyright © 2017 BBI-M USER1033. All rights reserved.
//

import Cocoa

class GuidelineCollectionView: NSCollectionView {

    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    
    override func deselectItems(at indexPaths: Set<IndexPath>) {
        super.deselectItems(at: indexPaths)
    }
}
