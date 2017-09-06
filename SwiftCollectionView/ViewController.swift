//
//  ViewController.swift
//  SwiftCollectionView
//
//  Created by BBI-M USER1033 on 01/09/17.
//  Copyright © 2017 BBI-M USER1033. All rights reserved.
//

import Cocoa
import MultipeerConnectivity

class ViewController: NSViewController {
    
    var allApps:[Guideline] = []
    
    var appStoreSearchURLs: NSMutableArray = []
    
    var currentDownloadingGuideline: Guideline?
    
    var filteredApps:[Guideline] = []
    
    var draggingIndexPaths: Set<IndexPath> = []
    
    var draggingItem: NSCollectionViewItem?
    
    var mpcManager:MPCManager = MPCManager()
    
    @IBOutlet var guidelineCollectionView: GuidelineCollectionView!
    
    @IBOutlet var searchTextField: NSTextField!
    
    @IBOutlet var loadingLabel: NSTextField!
    
    @IBOutlet var connectedDevicesLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTextField.delegate = self;
        mpcManager.delegate = self;
        guidelineCollectionView.register(forDraggedTypes: [NSPasteboardTypeString])
        guidelineCollectionView.setDraggingSourceOperationMask(.every, forLocal:true)
        
        NotificationCenter.default.addObserver(self, selector:#selector(fieldTextDidChange), name:NSNotification.Name(rawValue: "NSTextDidChangeNotification"), object: nil)

        
        // Do any additional setup after loading the view.
    }
    
    func fieldTextDidChange() {
        
        reloadGuidelines(allApps, searchText: searchTextField.stringValue)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    
    @IBAction func searchTextChanged(_ sender: Any) {
        
    }
    
    @IBAction func refreshClicked(_ sender: Any) {
        
        sendAppDataToConnectedDevices()
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
            filteredApps = guidelines;
        }
        else
        {
            filteredApps = filteredApps.filter { $0.name.localizedCaseInsensitiveContains(searchText)}
        }
        
        filteredApps = filteredApps.sorted(by: {$0.name < $1.name})
        
        setCollectionViewPlaceHolder("")
        
        guidelineCollectionView.reloadData()
        
        sendAppDataToConnectedDevices()
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
                            self.allApps.append(Guideline(appDictionary))
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
                let urlString:String = currentApp!.imagePath
                
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
                reloadGuidelines(allApps, searchText:"")
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
        
        if (allApps.count > 0)
        {
            if currentDownloadingGuideline == nil
            {
                currentDownloadingGuideline = allApps[0]
                return currentDownloadingGuideline;
            }
            else
            {
                let currentItemIndex = allApps.index(of: currentDownloadingGuideline!)
                
                if currentItemIndex != allApps.count - 1 && currentItemIndex != NSNotFound
                {
                    currentDownloadingGuideline = allApps[currentItemIndex! + 1]
                    
                    return currentDownloadingGuideline;
                }
            }
        }
        
        return nil;
    }
    
    func sendAppDataToConnectedDevices() {
        
        let appDictionary = NSMutableArray()
        
        for guideline in filteredApps {
            
            let temp: [String: String] = [
                "identifier": guideline.identifier,
                "name": guideline.name,
                "version": guideline.version,
                "imagePath": guideline.imagePath
            ]
            
            appDictionary.add(temp)
        }
        
        
        let appDict: [String: Any] = [
            "wrapperType": "apps",
            "results": appDictionary
            ]
        
        mpcManager.sendDataToConnectedPeers(appDict)
    }
}

extension ViewController: NSTextFieldDelegate {
    
    func textField(_ textField: NSTextField, textView: NSTextView, shouldSelectCandidateAt index: Int) -> Bool {
        
        print("Hurray")
        return true
    }
}

extension ViewController: MPCManagerDelegate {
    
    func didConnectedPeersListUpdated() {
        
        var connectedDeviceString = ""
        
        let connectedPeers = mpcManager.session.connectedPeers;
        
        if connectedPeers.count == 0 {
            
        }
        else {
            
            connectedDeviceString = connectedDeviceString.appending("Device connected: ")
            
            for peerID in connectedPeers {
                
                if peerID == connectedPeers.first && peerID == connectedPeers.last
                {
                    connectedDeviceString = connectedDeviceString.appending("\(peerID.displayName).")
                }
                else if peerID == connectedPeers.first
                {
                    connectedDeviceString = connectedDeviceString.appending("\(peerID.displayName)")
                }
                else if peerID == connectedPeers.last
                {
                    connectedDeviceString = connectedDeviceString.appending(" and \(peerID.displayName).")
                }
                else
                {
                    connectedDeviceString = connectedDeviceString.appending(", \(peerID.displayName)")
                }
                
                OperationQueue.main.addOperation (){
                    
                    self.connectedDevicesLabel.stringValue = connectedDeviceString
                }
            }
            
            sendAppDataToConnectedDevices()
        }
    }
}


extension ViewController: MCBrowserViewControllerDelegate {
    
    // Notifies the delegate, when the user taps the done button.
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(nil)
    }
    
    // Notifies delegate that the user taps the cancel button.
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(nil)
    }
}

extension ViewController: NSCollectionViewDataSource {
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let count: Int = filteredApps.count
        
        if allApps.count == 0
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
        
        let guideline: Guideline = filteredApps[indexPath.item]
        
        if let image = guideline.getGuidelineImage()
        {
            item.guidelineImage.image = image;
            item.guidelineTitleLabel.stringValue = guideline.name;
        }
        
        return item
    }
    
}

extension ViewController: NSCollectionViewDelegate {
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {

    }
    
    
    func collectionView(_ collectionView: NSCollectionView, willDisplay item: NSCollectionViewItem, forRepresentedObjectAt indexPath: IndexPath) {
        
        let guideline = filteredApps[indexPath.item]
        
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
        
        let guideline = filteredApps[indexPath.item]
        
        let pb = NSPasteboardItem()
        pb.setString(guideline.identifier as String, forType: NSPasteboardTypeString)
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
    
    func collectionView(_ collectionView: NSCollectionView, acceptDrop draggingInfo: NSDraggingInfo, indexPath: IndexPath, dropOperation: NSCollectionViewDropOperation) -> Bool {
        
        
        for fromIndexPath in draggingIndexPaths {
            
            let removeIndex = fromIndexPath.item
            
            let removedGuideline = filteredApps.remove(at: removeIndex)
    
            filteredApps.insert(removedGuideline, at: indexPath.item)
            
            
            let appDict: [String: Any] = [
                "wrapperType": "apps-position",
                "position": [
                    "from" : removeIndex,
                    "to" : indexPath.item
                ]
            ]
            
            mpcManager.sendDataToConnectedPeers(appDict)
        }
        
        
        
        return true
    }
}
