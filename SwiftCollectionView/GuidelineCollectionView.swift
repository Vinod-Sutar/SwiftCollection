//
//  GuidelineCollectionView.swift
//  SwiftCollectionView
//
//  Created by BBI-M USER1033 on 01/09/17.
//  Copyright © 2017 BBI-M USER1033. All rights reserved.
//

import Cocoa

class GuidelineCollectionView: NSCollectionView {

    var guidelineItems = NSMutableArray()
    
    var draggingIndexPaths: Set<IndexPath> = []
    
    var draggingItem: NSCollectionViewItem?
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    override func viewDidMoveToWindow() {
        
        self.register(forDraggedTypes: [NSPasteboardTypeString])
    
        self.backgroundColors = [NSColor.white]
        
        self.delegate = self;
        
        self.dataSource = self;
    }
    
    public func reloadGuidelines(_ guidelines: NSArray, searchText: NSString) {
        
        
    }
}

extension GuidelineCollectionView: NSCollectionViewDataSource {
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return guidelineItems.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        
        return collectionView.makeItem(withIdentifier: "GuidelineItem", for: indexPath)
    }
    
}

extension GuidelineCollectionView: NSCollectionViewDelegate {
    
    func collectionView(_ collectionView: NSCollectionView, willDisplay item: NSCollectionViewItem, forRepresentedObjectAt indexPath: IndexPath) {
        
        //**item.textField?.stringValue = "\(strings[indexPath.item]) \(indexPath.item)"
    }
    
    func collectionView(_ collectionView: NSCollectionView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forItemsAt indexPaths: Set<IndexPath>) {
        
        draggingIndexPaths = indexPaths
        
        if let indexPath = draggingIndexPaths.first,
            let item = collectionView.item(at: indexPath) {
            draggingItem = item
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, draggingSession session: NSDraggingSession, endedAt screenPoint: NSPoint, dragOperation operation: NSDragOperation) {
        
        draggingIndexPaths = []
        draggingItem = nil
    }
    
    func collectionView(_ collectionView: NSCollectionView, pasteboardWriterForItemAt indexPath: IndexPath) -> NSPasteboardWriting? {
        
        let guideline = guidelineItems[indexPath.item] as! Guideline;
        
        let pb = NSPasteboardItem()
        pb.setString(guideline.guidelineId, forType: NSPasteboardTypeString)
        return pb
    }
    
    private func collectionView(_ collectionView: NSCollectionView, validateDrop draggingInfo: NSDraggingInfo, proposedIndexPath proposedDropIndexPath: AutoreleasingUnsafeMutablePointer<IndexPath>, dropOperation proposedDropOperation: UnsafeMutablePointer<NSCollectionViewDropOperation>) -> NSDragOperation {
        
        if case let proposedDropIndexPath = proposedDropIndexPath.pointee,
            case let draggingItem = draggingItem,
            case let currentIndexPath = collectionView.indexPath(for: draggingItem!), currentIndexPath != proposedDropIndexPath {
            
            collectionView.animator().moveItem(at: currentIndexPath!, to: proposedDropIndexPath)
        }
        
        return .move
    }
    
    func collectionView(_ collectionView: NSCollectionView, acceptDrop draggingInfo: NSDraggingInfo, indexPath: IndexPath, dropOperation: NSCollectionViewDropOperation) -> Bool {
        for fromIndexPath in draggingIndexPaths {
            //**let temp = strings.remove(at: fromIndexPath.item)
            //**strings.insert(temp, at: (indexPath.item <= fromIndexPath.item) ? indexPath.item : (indexPath.item - 1))
            
            //NSAnimationContext.currentContext().duration = 0.5
            collectionView.animator().moveItem(at: fromIndexPath, to: indexPath)
        }
        
        return true
    }
    
    func collectionView(_ collectionView: NSCollectionView, draggingImageForItemsAt indexPaths: Set<IndexPath>, with event: NSEvent, offset dragImageOffset: NSPointPointer) -> NSImage {
        return NSImage(named: NSImageNameFolder)!
    }
    
    func collectionView(_ collectionView: NSCollectionView, draggingImageForItemsAt indexes: IndexSet, with event: NSEvent, offset dragImageOffset: NSPointPointer) -> NSImage {
        return NSImage(named: NSImageNameFolder)!
    }
    
}
