//
//  ViewController.swift
//  SwiftCollectionView
//
//  Created by BBI-M USER1033 on 01/09/17.
//  Copyright © 2017 BBI-M USER1033. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    var appArray:[Guideline] = []
    
    var appStoreSearchURLs: NSMutableArray = []
    
    var currentDownloadingGuideline: Guideline?
    
    var guidelineItems:[Guideline] = []
    
    var draggingIndexPaths: Set<IndexPath> = []
    
    var draggingItem: NSCollectionViewItem?
    
    @IBOutlet var guidelineCollectionView: GuidelineCollectionView!
    
    @IBOutlet var searchTextField: NSTextField!
    
    @IBOutlet var loadingLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guidelineCollectionView.register(forDraggedTypes: [NSPasteboardTypeString])
        guidelineCollectionView.setDraggingSourceOperationMask(.every, forLocal:true)
    
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    
    @IBAction func searchTextChanged(_ sender: Any) {
        
        reloadGuidelines(appArray, searchText: searchTextField.stringValue)
    }
    
    func setCollectionViewPlaceHolder(_ placeHolderString: String)  {
        
        OperationQueue.main.addOperation (){
            
            self.loadingLabel.isHidden = placeHolderString == ""
            self.loadingLabel.stringValue = placeHolderString
        }
    }
    
    
    public func reloadGuidelines(_ guidelines: [Guideline], searchText: String) {
        
        if searchText == ""
        {
            guidelineItems = guidelines;
        }
        else
        {
            guidelineItems = guidelineItems.filter { $0.guidelineName.localizedCaseInsensitiveContains(searchText)}
        }
        
        guidelineItems = guidelineItems.sorted(by: {$0.guidelineName < $1.guidelineName})
        
        setCollectionViewPlaceHolder("")
        
        guidelineCollectionView.reloadData()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        appStoreSearchURLs.add(URL(string: "https://itunes.apple.com/lookup?id=336125492&entity=software&limit=200")!)
        appStoreSearchURLs.add(URL(string: "https://itunes.apple.com/lookup?id=344107499&entity=software&limit=200")!)
        
        downloadGuidelineWithURL(appStoreSearchURLs[0] as! URL);
    }
    
    func downloadGuidelineWithURL(_ url: URL) {
        
        setCollectionViewPlaceHolder("Loading apps...")
        
        let config: URLSessionConfiguration = URLSessionConfiguration.default
    
        config.requestCachePolicy = .reloadIgnoringLocalCacheData;
        
        config.timeoutIntervalForRequest = 30;
        
        let session: URLSession = URLSession(configuration: config)
        
        let task = session.dataTask(with: url, completionHandler: {(data, response, error) -> Void in
            
            if error == nil
            {
                do
                {
                    let resultJson = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                    
                    let apps = resultJson["results"] as! NSArray
                    
                    for app in apps {
                        
                        let appDictionary =  app as! NSDictionary
                        
                        let wrapperType = appDictionary["wrapperType"] as! String
                        
                        if (wrapperType == "software")
                        {
                            self.appArray.append(Guideline(appDictionary))
                        }
                    }
                    
                    if (self.appStoreSearchURLs.count > 0)
                    {
                        self.appStoreSearchURLs.removeObject(at: 0);
                    }
                    
                    self.downloadImage();
                }
                catch
                {
                    print("Error -> \(error)")
                }
            }
            else
            {
                
            }
        
        })
        
        task.resume()
    }
    
    
    func downloadImage() {
        
        setCollectionViewPlaceHolder("Loading images...")
        
        let currentApp:Guideline? = getNextElement()
        
        if currentApp != nil
        {
            if currentApp!.isGuidelineImageExists() == true
            {
                downloadImage();
            }
            else
            {
                let urlString:String = currentApp!.guidelineImagePath
                
                let config: URLSessionConfiguration = URLSessionConfiguration.default
                
                config.requestCachePolicy = .reloadIgnoringLocalCacheData;
                
                config.timeoutIntervalForRequest = 30;
                
                let session: URLSession = URLSession(configuration: config)
                
                let task = session.dataTask(with: URL(string:urlString)!, completionHandler: {(data, response, error) -> Void in
                    
                    if error == nil
                    {
                        if data != nil
                        {
                            let image: NSImage? = NSImage(data: data!)
                            
                            if image != nil {
                                
                                do
                                {
                                    try data?.write(to: URL(fileURLWithPath:currentApp!.getGuidelineImagePath()), options: .withoutOverwriting)
                                }
                                catch let error as NSError {
                                    print("Image write Error at path \(error.localizedDescription)")
                                }
                                
                            }
                            
                            self.downloadImage()
                        }
                        else
                        {
                            print("Image data Error")
                        }
                    }
                    else
                    {
                        print("Image download error" )
                    }
                    
                })
                
                task.resume()
                
            }
        }
        else
        {
            if (appStoreSearchURLs.count == 0)
            {
                reloadGuidelines(appArray, searchText:"")
            }
            else
            {
                downloadGuidelineWithURL(appStoreSearchURLs[0] as! URL);
            }
        }
    
    }
    
    
    func getImagePath(_ currentApp: NSDictionary) -> String {
        
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        //let trackIdString = String(describing: currentApp["trackId"])

        
        let trackId: Int = currentApp["trackId"] as! Int
        
        let trackIdString = String(describing: trackId)
        
        let version = currentApp["version"] as! String
    
        return documentDirectory + "/Images/" + trackIdString + "_" + version + ".png"
    }
    
    func getNextElement() -> Guideline? {
        
        if (appArray.count > 0)
        {
            if currentDownloadingGuideline == nil
            {
                currentDownloadingGuideline = appArray[0]
                return currentDownloadingGuideline;
            }
            else
            {
                let currentItemIndex = appArray.index(of: currentDownloadingGuideline!)
                
                if currentItemIndex != appArray.count - 1 && currentItemIndex != NSNotFound
                {
                    currentDownloadingGuideline = appArray[currentItemIndex! + 1]
                    
                    return currentDownloadingGuideline;
                }
            }
        }
        
        return nil;
    }
}



extension ViewController: NSCollectionViewDataSource {
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let count: Int = guidelineItems.count
        
        if appArray.count == 0
        {
            setCollectionViewPlaceHolder("No guidelines found")
        }
        else if count == 0
        {
            setCollectionViewPlaceHolder("No result found")
        }
        else
        {
            setCollectionViewPlaceHolder("")
        }
        
        return count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        
        let item: GuidelineItem = collectionView.makeItem(withIdentifier: "GuidelineItem", for: indexPath) as! GuidelineItem
        
        let guideline: Guideline = guidelineItems[indexPath.item]
        
        if let image = guideline.getGuidelineImage()
        {
            item.guidelineImage.image = image;
            item.guidelineTitleLabel.stringValue = guideline.guidelineName;
        }
        
        return item
    }
    
}

extension ViewController: NSCollectionViewDelegate {
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {

    }
    
    
    func collectionView(_ collectionView: NSCollectionView, willDisplay item: NSCollectionViewItem, forRepresentedObjectAt indexPath: IndexPath) {
        
        let guideline = guidelineItems[indexPath.item]
        
        if let image = guideline.getGuidelineImage()
        {
            let guidelineItem: GuidelineItem = item as! GuidelineItem;
            guidelineItem.guidelineImage.image = image;
        }
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
        
        let guideline = guidelineItems[indexPath.item]
        
        let pb = NSPasteboardItem()
        pb.setString(guideline.guidelineId as String, forType: NSPasteboardTypeString)
        return pb
    }
    
    func collectionView(_ collectionView: NSCollectionView, validateDrop draggingInfo: NSDraggingInfo, proposedIndexPath proposedDropIndexPath: AutoreleasingUnsafeMutablePointer<NSIndexPath>, dropOperation proposedDropOperation: UnsafeMutablePointer<NSCollectionViewDropOperation>) -> NSDragOperation {
        
        if case let proposedDropIndexPath = proposedDropIndexPath.pointee,
            case let draggingItem = draggingItem,
            case let currentIndexPath = collectionView.indexPath(for: draggingItem!), currentIndexPath != proposedDropIndexPath as IndexPath {
            
            collectionView.animator().moveItem(at: currentIndexPath!, to: proposedDropIndexPath as IndexPath)
        }
        
        return .move
    }
    
    
    func collectionView(_ collectionView: NSCollectionView, acceptDrop draggingInfo: NSDraggingInfo, index: Int, dropOperation: NSCollectionViewDropOperation) -> Bool {
        
        for fromIndexPath in draggingIndexPaths {
            
            let item = guidelineItems.removeFirst()
            
            guidelineItems.insert(item, at: (index <= fromIndexPath.item) ? index : (index - 1))
            
            NSAnimationContext.current().duration = 0
            
            let toIndexPath: IndexPath = IndexPath(item: index, section: fromIndexPath.section)
            
            collectionView.animator().moveItem(at: fromIndexPath, to: toIndexPath)
        }
        
        return true
    }
}
