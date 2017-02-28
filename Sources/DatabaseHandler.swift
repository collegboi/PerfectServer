//
//  DatabaseHandler.swift
//  MyAwesomeProject
//
//  Created by Timothy Barnard on 05/02/2017.
//
//

import PerfectLib
import PerfectHTTP
import MongoDB

/// Defines and returns the Web Authentication routes
public func makeDatabaseRoutes() -> Routes {
    var routes = Routes()

    //routes.add(method: .get, uri: "/storage/Tables", handler: mongoGetCollections)
    routes.add(method: .get, uri: "/api/{appkey}/storage/createIndex/{collection}/{index}/", handler: mongoCreateIndex)
    routes.add(method: .get, uri: "/api/{appkey}/storage/dropCollection/{collection}/", handler: mongoDropCollection)
    routes.add(method: .get, uri: "/api/{appkey}/storage/dropIndex/{collection}/{index}/", handler: mongoDropIndex)
    routes.add(method: .get, uri: "/api/{appkey}/storage/rename/{oldcollection}/{newcollection}", handler: mongoRenameCollection)
    routes.add(method: .get, uri: "/api/{appkey}/storage/{collection}", handler: mongoHandler)
    routes.add(method: .get, uri: "/api/{appkey}/storage/{collection}", handler: mongoHandler)
    routes.add(method: .get, uri: "/api/{appkey}/storage/{collection}/{skip}/{limit}", handler: mongoQueryLimit)
    routes.add(method: .get, uri: "/api/{appkey}/storage/{collection}/{objectid}", handler: mongoFilterHandler)
    routes.add(method: .post, uri: "/api/{appkey}/storage", handler: databasePost)
    routes.add(method: .post, uri: "/api/{appkey}/storage/{collection}", handler: databaseCollectionPost)
    routes.add(method: .post, uri: "/api/{appkey}/storage/all/{collection}", handler: databaseCollectionsPost)
    routes.add(method: .delete, uri: "/api/{appkey}/storage/{collection}", handler: removeCollection)
    routes.add(method: .delete, uri: "/api/{appkey}/storage/{collection}/{objectid}", handler: removeCollectionDoc)
    routes.add(method: .post, uri: "/api/{appkey}/storage/remove/{collection}/{objectid}", handler: safeRemoveCollectionDoc)
    routes.add(method: .post, uri: "/api/{appkey}/storage/query/{collection}/{skip}/{limit}", handler: databaseGetQuery)
    routes.add(method: .post, uri: "/api/{appkey}/storage/query/{collection}/", handler: databaseGetQuery)
    
    // Check the console to see the logical structure of what was installed.
    print("\(routes.navigator.description)")
    
    return routes
}

func databaseGetQuery(request: HTTPRequest, _ response: HTTPResponse) {
    
    var skip: Int = 0
    var limit: Int = 100
    
    guard let appkey = request.urlVariables["appkey"] else {
        response.appendBody(string: ResultBody.errorBody(value: "missing appkey"))
        response.completed()
        return
    }
    
    guard let collectionName = request.urlVariables["collection"] else {
        response.appendBody(string: ResultBody.errorBody(value: "nocollection"))
        response.completed()
        return
    }
    
    if let skipValue = request.urlVariables["skip"] {
        skip = skipValue.toInt() ?? 0
    }
    
    if let limitValue = request.urlVariables["limit"] {
        limit = limitValue.toInt() ?? 100
    }
    
    guard let jsonStr = request.postBodyString else {
        response.appendBody(string: ResultBody.errorBody(value: "no json body"))
        response.completed()
        return
    }
    
    let data = Storage.getQueryCollection(appkey, collectionName, json: jsonStr, skip: skip, limit: limit)
    
    response.appendBody(string: data)
    response.completed()
    
    
}

func mongoDropCollection(request: HTTPRequest, _ response: HTTPResponse) {
    
    guard let appkey = request.urlVariables["appkey"] else {
        response.appendBody(string: ResultBody.errorBody(value: "missing appkey"))
        response.completed()
        return
    }
    
    guard let collectionName = request.urlVariables["collection"] else {
        response.appendBody(string: ResultBody.errorBody(value: "no collection"))
        response.completed()
        return
    }
    Storage.dropCollection(appkey, collectionName)
    
    response.appendBody(string: ResultBody.successBody(value: collectionName + " dropped"))
    response.completed()
    
}

func mongoCreateIndex(request: HTTPRequest, _ response: HTTPResponse) {
    
    guard let appkey = request.urlVariables["appkey"] else {
        response.appendBody(string: ResultBody.errorBody(value: "missing appkey"))
        response.completed()
        return
    }
    
    guard let collectionName = request.urlVariables["collection"] else {
        response.appendBody(string: ResultBody.errorBody(value: "no collection"))
        response.completed()
        return
    }
    
    guard let index = request.urlVariables["index"] else {
        response.appendBody(string: ResultBody.errorBody(value: "no index"))
        response.completed()
        return
    }
   
    let indexVal = Storage.createIndex(appkey, collectionName, index: index)
    
    response.appendBody(string: ResultBody.successBody(value: indexVal))
    response.completed()
    
}


func mongoDropIndex(request: HTTPRequest, _ response: HTTPResponse) {
    
    guard let appkey = request.urlVariables["appkey"] else {
        response.appendBody(string: ResultBody.errorBody(value: "missing appkey"))
        response.completed()
        return
    }
    
    guard let collectionName = request.urlVariables["collection"] else {
        response.appendBody(string: ResultBody.errorBody(value: "no collection"))
        response.completed()
        return
    }
    
    guard let index = request.urlVariables["index"] else {
        response.appendBody(string: ResultBody.errorBody(value: "no index"))
        response.completed()
        return
    }
    
    Storage.dropIndex(appkey, collectionName, index: index)
    
    response.appendBody(string: ResultBody.successBody(value: "dropped index"))
    response.completed()
}

func mongoRenameCollection(request: HTTPRequest, _ response: HTTPResponse) {
    
    guard let appkey = request.urlVariables["appkey"] else {
        response.appendBody(string: ResultBody.errorBody(value: "missing appkey"))
        response.completed()
        return
    }
    
    guard let oldCollectionName = request.urlVariables["oldcollection"] else {
        response.appendBody(string: ResultBody.errorBody(value: "old collection missing"))
        response.completed()
        return
    }
    
    guard let newCollectionName = request.urlVariables["newcollection"] else {
        response.appendBody(string: ResultBody.errorBody(value: "new collection missing"))
        response.completed()
        return
    }
    
    Storage.renameCollection(appkey, oldCollectionName, newCollection: newCollectionName)
    
    response.appendBody(string: ResultBody.successBody(value: "collection renamed"))
    response.completed()
}


func mongoGetCollections(request: HTTPRequest, _ response: HTTPResponse) {
    
    guard let appkey = request.urlVariables["appkey"] else {
        response.appendBody(string: ResultBody.errorBody(value: "missing appkey"))
        response.completed()
        return
    }
    
    let returning = Storage.getAllCollections(appkey)
    
    // Return the JSON string
    response.appendBody(string: returning)
    response.completed()
}


func databasePost(request: HTTPRequest, _ response: HTTPResponse) {
    
    guard let appkey = request.urlVariables["appkey"] else {
        response.appendBody(string: ResultBody.errorBody(value: "missing appkey"))
        response.completed()
        return
    }
    
    guard let jsonStr = request.postBodyString else {
        response.appendBody(string: ResultBody.errorBody(value: "no json body"))
        response.completed()
        return
    }
    
    if Storage.parseAndStoreObject(appkey, jsonStr) {
        response.appendBody(string: ResultBody.errorBody(value: "nocollection"))
    } else {
        response.appendBody(string: ResultBody.successBody(value: "collection added"))
    }
    
    response.completed()
}

func databaseCollectionsPost(request: HTTPRequest, _ response: HTTPResponse) {
    
    guard let appkey = request.urlVariables["appkey"] else {
        response.appendBody(string: ResultBody.errorBody(value: "missing appkey"))
        response.completed()
        return
    }
    
    guard let collectionName = request.urlVariables["collection"] else {
        response.appendBody(string: ResultBody.errorBody(value: "nocollection"))
        response.completed()
        return
    }
    
    guard let jsonStr = request.postBodyString else {
        response.appendBody(string: ResultBody.errorBody(value: "no json body"))
        response.completed()
        return
    }
    
    if Storage.StoreObjects(appkey, collectionName, jsonStr) {
        response.appendBody(string: ResultBody.errorBody(value: "nocollection"))
    } else {
        response.appendBody(string: ResultBody.successBody(value: "collection added"))
    }
    response.completed()
}

func databaseCollectionPost(request: HTTPRequest, _ response: HTTPResponse) {
    
    guard let appkey = request.urlVariables["appkey"] else {
        response.appendBody(string: ResultBody.errorBody(value: "missing appkey"))
        response.completed()
        return
    }
    
    guard let collectionName = request.urlVariables["collection"] else {
        response.appendBody(string: ResultBody.errorBody(value: "nocollection"))
        response.completed()
        return
    }
    
    guard let jsonStr = request.postBodyString else {
        response.appendBody(string: ResultBody.errorBody(value: "no json body"))
        response.completed()
        return
    }
    
    if Storage.StoreObject(appkey, collectionName, jsonStr) {
        response.appendBody(string: ResultBody.errorBody(value: "nocollection"))
    } else {
        response.appendBody(string: ResultBody.successBody(value: "collection added"))
    }
    response.completed()
}

func mongoFilterHandler(request: HTTPRequest, _ response: HTTPResponse) {
    
    guard let appkey = request.urlVariables["appkey"] else {
        response.appendBody(string: ResultBody.errorBody(value: "missing appkey"))
        response.completed()
        return
    }
    
    guard let collectionName = request.urlVariables["collection"] else {
        response.appendBody(string: ResultBody.errorBody(value: "nocollection"))
        response.completed()
        return
    }
    
    guard let objectID = request.urlVariables["objectid"] else {
        response.appendBody(string: ResultBody.errorBody(value: "no objectID"))
        response.completed()
        return
    }
    
    let returning = Storage.getDocumentWithObjectID(appkey, collectionName, objectID)
    
    // Return the JSON string
    response.appendBody(string: returning)
    response.completed()
    
}


func mongoQueryLimit(request: HTTPRequest, _ response: HTTPResponse) {
    
    var skip: Int = 0
    var limit: Int = 100
    
    guard let appkey = request.urlVariables["appkey"] else {
        response.appendBody(string: ResultBody.errorBody(value: "missing appkey"))
        response.completed()
        return
    }
    
    guard let collectionName = request.urlVariables["collection"] else {
        response.appendBody(string: ResultBody.errorBody(value: "nocollection"))
        response.completed()
        return
    }
    
    if let skipValue = request.urlVariables["skip"] {
        skip = skipValue.toInt() ?? 0
    }
    
    if let limitValue = request.urlVariables["limit"] {
        limit = limitValue.toInt() ?? 100
    }
    
    var returning = ResultBody.errorBody(value: "nocollections")
    
    if collectionName == "Tables" {
        returning = Storage.getAllCollections(appkey)
    } else {
        returning = Storage.getQueryCollection(appkey, collectionName, json: "", skip: skip, limit: limit)
    }

    // Return the JSON string
    response.appendBody(string: returning)
    response.completed()
}


func mongoHandler(request: HTTPRequest, _ response: HTTPResponse) {
    
    //ConfigureNotfications.init()
    
    var appVersion = "0.0"
    
    let queryParams = request.queryParams
    
    if queryParams.count > 0 {
        let (_, version ) = queryParams[0] as (String, String)
        appVersion = version
    }
    
    guard let appkey = request.urlVariables["appkey"] else {
        response.appendBody(string: ResultBody.errorBody(value: "missing appkey"))
        response.completed()
        return
    }
    
    guard let collectionName = request.urlVariables["collection"] else {
        response.appendBody(string: ResultBody.errorBody(value: "nocollection"))
        response.completed()
        return
    }
    
    
    var returning = ResultBody.errorBody(value: "nocollections")
    
    if collectionName == "Tables" {
        returning = Storage.getAllCollections(appkey)
    //} else if collectionName == "" {
        //returning = Storage.getAllCollections(appkey)
    } else {
        returning = Storage.getCollectionValues(appkey, collectionName, appVersion: appVersion)
    }
    
    // Return the JSON string
    response.appendBody(string: returning)
    response.completed()
}

func removeCollectionDoc(request: HTTPRequest, _ response: HTTPResponse) {
    
    guard let appkey = request.urlVariables["appkey"] else {
        response.appendBody(string: ResultBody.errorBody(value: "missing appkey"))
        response.completed()
        return
    }
    
    guard let collectionName = request.urlVariables["collection"] else {
        response.appendBody(string: ResultBody.errorBody(value: "nocollection"))
        response.completed()
        return
    }
    
    guard let objectID = request.urlVariables["objectid"] else {
        response.appendBody(string: ResultBody.errorBody(value: "no objectID"))
        response.completed()
        return
    }
    
    
    var resultBody = ResultBody.successBody(value:  "removed")
    
    if !DatabaseController.removeDocument(appkey, collectionName, objectID) {
        resultBody = ResultBody.errorBody(value: "not removed")
    }
    
    response.appendBody(string: resultBody)
    response.completed()

}

func removeCollection(request: HTTPRequest, _ response: HTTPResponse) {
    
    guard let appkey = request.urlVariables["appkey"] else {
        response.appendBody(string: ResultBody.errorBody(value: "missing appkey"))
        response.completed()
        return
    }
    
    guard let collectionName = request.urlVariables["collection"] else {
        response.appendBody(string: ResultBody.errorBody(value: "nocollection"))
        response.completed()
        return
    }
    
    
    var resultBody = ResultBody.successBody(value:  "removed")
    
    if !DatabaseController.removeCollection(appkey, collectionName) {
        resultBody = ResultBody.errorBody(value: "not removed")
    }
    
    response.appendBody(string: resultBody)
    response.completed()
    
}



func safeRemoveCollectionDoc(request: HTTPRequest, _ response: HTTPResponse) {
    
    guard let appkey = request.urlVariables["appkey"] else {
        response.appendBody(string: ResultBody.errorBody(value: "missing appkey"))
        response.completed()
        return
    }
    
    guard let collectionName = request.urlVariables["collection"] else {
        response.appendBody(string: ResultBody.errorBody(value: "nocollection"))
        response.completed()
        return
    }
    
    guard let jsonStr = request.postBodyString else {
        response.appendBody(string: ResultBody.errorBody(value: "no json body"))
        response.completed()
        return
    }
    
    
    var resultBody = ResultBody.successBody(value:  "removed")
    
    if !DatabaseController.safeRemoveDocument(appkey, collectionName, jsonStr) {
        resultBody = ResultBody.errorBody(value: "not removed")
    }
    
    response.appendBody(string: resultBody)
    response.completed()
    
}

