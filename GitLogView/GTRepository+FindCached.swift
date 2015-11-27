//
//  GTRepository+Find.swift
//  CoprightModifier
//
//  Created by Dominik Pich on 15/06/15.
//  Copyright (c) 2015 Dominik Pich. All rights reserved.
//

import Foundation
import ObjectiveGit


extension GTRepository {
    private static var cachedRepositories = Dictionary<String, GTRepository>()
    
    //searches for the closest repo for a given fileUrl. Same as the git CLI client.
    
    class func findCachedRepositoryWithURL(fileUrl:NSURL) -> GTRepository? {
        
        //search on disk
        var path = fileUrl.path

        var repo:GTRepository?
        
        //search in our list of cached repos
        if cachedRepositories.count > 0 {
            while(repo == nil && path != nil) {
                repo = cachedRepositories[path!]
                
                //change stringByDeletingLastPathComponent behaviour ;)
                if path == "/" {
                    path = nil
                }
                else {
                    let url = NSURL(fileURLWithPath: path!)
                    path = url.URLByDeletingLastPathComponent?.path
                }
            }
        }
        
        if  repo != nil {
            return repo
        }
        
        //search on disk
        path = fileUrl.path
        
        while(repo == nil && path != nil) {
            let url = NSURL(fileURLWithPath: path!)
            do {
                try repo = GTRepository(URL: url)
                cachedRepositories[path!] = repo
            }
            catch {
            }
            
            //change stringByDeletingLastPathComponent behaviour ;)
            if path == "/" {
                path = nil
            }
            else {
                let url = NSURL(fileURLWithPath: path!)
                path = url.URLByDeletingLastPathComponent?.path
            }
        }

        
        return repo
    }
}