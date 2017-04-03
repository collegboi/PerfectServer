//
//  Backup.swift
//  MyAwesomeProject
//
//  Created by Timothy Barnard on 18/02/2017.
//
//

import PerfectZip
import Foundation
import SwiftMoment

class BackupService {
    
    private class var nowDate: String {
        let m = moment()
        return m.format()
    }
    
    static func doBackupNow() {
        
        var collectionVals = [String]()
        
        let storage = Storage()
        storage.setAppKey("JKHSDGHFKJGH454645GRRLKJF")
        
        let collections: [String] = storage.getAllColectionsArr()
        
        for collection in collections {
            
            storage.setCollectionName(collection)
            let collectionStr = storage.getCollectionStr()
            
            FileController.sharedFileHandler?.updateContentsOfFile("backup/"+collection+".json", collectionStr)
            
            collectionVals.append(collection)
        }
        
        let zippy = Zip()
        
        let thisZipFile = "/Users/timothybarnard/Library/Developer/Xcode/DerivedData/MyAwesomeProject-eyzphcspgetoixfjpdefxftmfpsd/Build/Products/Debug/webroot/backup_"+nowDate+".zip"
        let sourceDir = "/Users/timothybarnard/Library/Developer/Xcode/DerivedData/MyAwesomeProject-eyzphcspgetoixfjpdefxftmfpsd/Build/Products/Debug/webroot/backup"
        
        let ZipResult = zippy.zipFiles(
            paths: [sourceDir],
            zipFilePath: thisZipFile,
            overwrite: true, password: ""
        )
        print("ZipResult Result: \(ZipResult.description)")
        
        #if os(Linux)
            let configData: [String:AnyObject] = [
                "collections": collectionVals as! AnyObject,
                "path_backup" : thisZipFile as! AnyObject
            ]
        #else
            let configData: [String:AnyObject] = [
                "collections": collectionVals as AnyObject,
                "path_backup" : thisZipFile as AnyObject
            ]
        #endif
        
        
        let configStr = JSONController.parseJSONToStr(dict: configData)
        
        storage.setCollectionName("TBBackups")
        storage.insertDocument(jsonStr: configStr)
    }
    
    static func setupBackupTimes(_ jsonString: String) {
        
        
        
    }
    
}
