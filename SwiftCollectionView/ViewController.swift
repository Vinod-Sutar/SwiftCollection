//
//  ViewController.swift
//  SwiftCollectionView
//
//  Created by BBI-M USER1033 on 01/09/17.
//  Copyright © 2017 BBI-M USER1033. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    var appArray: NSMutableArray = []
    var appStoreSearchURLs: NSMutableArray = []
    
    var currentImageDownloadApp: NSDictionary = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        
        //[appStoreSearchURLs ([ (string: "https://itunes.apple.com/lookup?id=336125492&entity=software&limit=200")])];
        
        appStoreSearchURLs.add(URL(string: "https://itunes.apple.com/lookup?id=336125492&entity=software&limit=200")!)
        appStoreSearchURLs.add(URL(string: "https://itunes.apple.com/lookup?id=344107499&entity=software&limit=200")!)
        
        downloadGuidelineWithURL(appStoreSearchURLs[0] as! URL);
    }
    
    func downloadGuidelineWithURL(_ url: URL) {
        
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
                            self.appArray.add(appDictionary)
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
        
        let currentApp = getNextElement()
        
        if currentApp.allKeys.count > 0
        {
            let imagePath = getImagePath(currentApp)
            
            let fileManager = FileManager.default
            
            if fileManager.fileExists(atPath: imagePath)
            {
                downloadImage();
            }
            else
            {
                let urlString = currentApp["artworkUrl512"] as! String
                
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
                                    try data?.write(to: URL(fileURLWithPath: imagePath), options: .withoutOverwriting)
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
                //[guidelineCollectionView reloadWithGuidelines:appArray searchText:[searchTextField stringValue]];
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
    
    func getNextElement() -> NSDictionary {
        
        if (appArray.count > 0)
        {
            if currentImageDownloadApp.allKeys.count == 0
            {
                currentImageDownloadApp = appArray[0] as! NSDictionary;
                return currentImageDownloadApp
            }
            else
            {
                let currentItemIndex = appArray.index(of: currentImageDownloadApp)
                
                if currentItemIndex == appArray.count - 1
                {
                    
                }
                else if currentItemIndex != NSNotFound
                {
                    currentImageDownloadApp = appArray.object(at: currentItemIndex + 1) as! NSDictionary;
                    return currentImageDownloadApp;
                }
                else
                {
                    print("Err");
                }
            }
        }
        
        return [:]
    }
    
    
    
}


