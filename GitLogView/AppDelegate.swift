//
//  AppDelegate.swift
//  GitLogView
//
//  Created by Dominik Pich on 11/22/15.
//  Copyright © 2015 Dominik Pich. All rights reserved.
//

import Cocoa
import ObjectiveGit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var table: NSTableView!
    @IBOutlet weak var button: NSButton!

    var commitsAndPaths: [(GTCommit, String)]?
    
    override func awakeFromNib() {
        load("/Users/dpich/Documents/SapientSources/myaudi-ios/myAudi/deployAll.sh")
    }
    
    func load(absoluteFilePath: String) {
        // Insert code here to initialize your application
        
        let url = NSURL(fileURLWithPath: absoluteFilePath)
        guard let repo = GTRepository.findCachedRepositoryWithURL(url) else {
            return
        }
        
        //ugly path fix .. make it relative
        guard var path = repo.fileURL.path else {
            return
        }
        if(!path.hasSuffix("/")) {
            path = path.stringByAppendingString("/")
        }
        let filePath = absoluteFilePath.stringByReplacingOccurrencesOfString(path, withString: "")
        commitsAndPaths = repo.findFileHistory(filePath)
        
        table.reloadData()
    }

    @IBAction func browse(sender: AnyObject) {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = true
        
        panel.beginWithCompletionHandler { (result) -> Void in
            if(result==NSFileHandlingPanelOKButton) {
                if let p = panel.URL?.path {
                    self.load(p)
                }
            }
        }
    }
    // MARK: NSTableViewDataSource, NSTableViewDelegate
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return commitsAndPaths != nil ? commitsAndPaths!.count : 0
    }
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        guard commitsAndPaths != nil && row < commitsAndPaths!.count else {
            return nil
        }
        
        let commitsAndPath = commitsAndPaths![row]
        
        if tableColumn?.identifier == "date" {
            return commitsAndPath.0.commitDate
        }
        else if tableColumn?.identifier == "path" {
            return commitsAndPath.1
        }
        else if tableColumn?.identifier == "message" {
            return commitsAndPath.0.message
        }
        return nil
    }
}

