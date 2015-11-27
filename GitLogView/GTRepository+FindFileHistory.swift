//
//  GTRepository+FindFirstCommit.swift
//  CoprightModifier
//
//  Created by Dominik Pich on 11/22/15.
//  Copyright © 2015 Dominik Pich. All rights reserved.
//

import Foundation
import ObjectiveGit

extension GTRepository {
    func findFileHistory(relativeFilePath:String) -> [(GTCommit,String)]? {
        var seen = [(GTCommit,String)]()

        //setup enumerator
        var enumerator: GTEnumerator!
        do {
            enumerator = try GTEnumerator(repository: self)
            enumerator.resetWithOptions( GTEnumeratorOptions.TopologicalSort.union(.TimeSort))
            let head = try self.headReference()
            try enumerator.pushSHA(head.OID.SHA)
        }
        catch let error as NSError {
            print("cant setup enumerator: \(error)")
            return nil
        }

        //get HEAD commit
        var commit = enumerator.nextObject() as! GTCommit?

        //look for commits
        var seenInCommit: GTCommit?
        var filePath = relativeFilePath
        while(commit != nil) {
            //check tree and see if touches file
            do {
                //throws error if not seen!
                try commit!.tree?.entryWithPath(filePath)
                seenInCommit = commit
                seen.append((commit!, filePath))
                
            }
            catch {
                var refound = false
                
                //might have been renamed?! see if we can find it via it's sha
                if let tree = commit?.tree, oldTree = seenInCommit?.tree {
                    do {
                        let entry = try oldTree.entryWithPath(filePath)
                        if entry.type == .Blob {
                            if let sha = try entry.GTObject().SHA {
                                if let itemAndPath = tree.entryWithBlobSHA(sha) {
                                    filePath = itemAndPath.1
                                    seenInCommit = commit
                                    seen.append((commit!, filePath))
                                    refound = true
                                }
                            }
                        }
                    }
                    catch {
                        print("cant get file blob SHA")
                    }
                }
                
                if !refound {
                    break;
                }
            }
            commit = enumerator.nextObject() as! GTCommit?
        }
        
        //now we filter the commits. starting with the last :)
        var changed = [(GTCommit,String)]()
        var oldSha: String?
        var oldPath: String?
        
        for entry in seen.reverse() {
            var sha: String?
            let path = entry.1
            
            //get seen sha AND path
            do {
                if let tree = entry.0.tree {
                    let entry = try tree.entryWithPath(path)
                    if entry.type == .Blob {
                        sha = try entry.GTObject().SHA
                    }
                }
            }
            catch {
                print("cant get file blob SHA")
            }
            
            //only add when sha or path chaanged
            if(oldSha == nil) {
                changed.append(entry)
            }
            else if(oldSha != sha) {
                changed.append(entry)
            }
            else {
                //fallback to path!
                if(oldPath == nil) {
                    changed.append(entry)
                }
                else if(oldPath != path) {
                    changed.append(entry)
                }
            }
            oldSha = sha
            oldPath = path
        }
        
        return changed.reverse()
    }
}