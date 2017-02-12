//
//  FileHandler.swift
//  MyAwesomeProject
//
//  Created by Timothy Barnard on 08/02/2017.
//
//

import PerfectLib
import PerfectHTTP
import MongoDB

/// Defines and returns the Web Authentication routes
public func makeFileUploadRoutes() -> Routes {
    var routes = Routes()
    
    routes.add(method: .post, uri: "/upload/{directory}/", handler: uploadFile)
    
    // Check the console to see the logical structure of what was installed.
    print("\(routes.navigator.description)")
    
    return routes
}

func uploadFile(request: HTTPRequest, _ response: HTTPResponse) {
    
    guard let directory = request.urlVariables["directory"] else {
        response.appendBody(string: ResultBody.errorBody(value: "no type"))
        response.completed()
        return
    }
    
    guard let uploads = request.postFileUploads, uploads.count > 0  else {
        response.appendBody(string: ResultBody.errorBody(value: "uploads empty"))
        response.completed()
        return
    }
    // Create an array of dictionaries which will show what was uploaded
    var ary = [[String:Any]]()
    
    // create uploads dir to store files
    let fileDir = Dir(Dir.workingDir.path + directory)
    do {
        try fileDir.create()
    } catch {
        print(error)
    }
    
    for upload in uploads {
        
        // move file
        let thisFile = File(upload.tmpFileName)
        do {
            let _ = try thisFile.moveTo(path: fileDir.path + upload.fileName, overWrite: true)
        } catch {
            print(error)
        }
        
        let fileObject: [String:String] = [
            "fieldName": upload.fieldName,
            "timestamp": "12/02/2012 08:00:00",
            "fileSize": "\(upload.fileSize)",
            "filePath": fileDir.path + upload.fileName,
            "type": directory
        ]
        
        let objectStr = JSONController.parseJSONToStr(dict: fileObject)
        
        DatabaseController.insertDocument("Files", jsonStr: objectStr)

        
        ary.append([
            "fieldName": upload.fieldName,
            "contentType": upload.contentType,
            "fileName": upload.fileName,
            "fileSize": upload.fileSize,
            "tmpFileName": upload.tmpFileName
            ])
        
        
    }
    //values["files"] = ary
    //values["count"] = ary.count

    response.appendBody(string: "")
    response.completed()
}
