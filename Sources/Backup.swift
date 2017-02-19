//
//  Backup.swift
//  MyAwesomeProject
//
//  Created by Timothy Barnard on 18/02/2017.
//
//

import PerfectZip
import Foundation

class BackupService {
    
    private class func moment(_ seconds: TimeInterval) -> Date {
        let interval = TimeInterval(seconds)
        let date = Date(timeIntervalSince1970: interval)
        return date
    }
    
    private class func getNow() -> Double {
        
        var posixTime = timeval()
        gettimeofday(&posixTime, nil)
        return Double((posixTime.tv_sec * 1000) + (Int(posixTime.tv_usec)/1000))
    }
    
    private class var nowDate: String {
        return "\(self.moment(self.getNow()))"
    }
    
    
    static func doBackupNow() {
        
        var collectionVals = [String]()
        
        let collections: [String] = DatabaseController.getAllColectionsArr("JKHSDGHFKJGH454645GRRLKJF")
        
        for collection in collections {
            
            let collectionStr = DatabaseController.retrieveCollectionString("JKHSDGHFKJGH454645GRRLKJF",collection)
            
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
        
        let configData: [String:AnyObject] = [
            "collections": collectionVals as AnyObject,
            "path_backup" : thisZipFile as AnyObject
        ]
        let configStr = JSONController.parseJSONToStr(dict: configData)
        
        DatabaseController.insertDocument("JKHSDGHFKJGH454645GRRLKJF","Backup", jsonStr: configStr)

    }
}
