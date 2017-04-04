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
    
    routes.add(method: .post, uri: "/storage/{collection}", handler: databaseCollectionPost)
    
    routes.add(method: .post, uri: "/api/{appkey}/replicate", handler: replicateDatabase)

    print("\(routes.navigator.description)")
    
    return routes
}

private func getStorageInstanceCol(request: HTTPRequest, _ response: HTTPResponse) -> Storage? {
    
    guard let appkey = request.urlVariables["appkey"] else {
        response.appendBody(string: ResultBody.errorBody(value: "missing appkey"))
        response.completed()
        return nil
    }
    
    guard let collectionName = request.urlVariables["collection"] else {
        response.appendBody(string: ResultBody.errorBody(value: "nocollection"))
        response.completed()
        return nil
    }
    
    let storage = Storage()
    storage.setTestMode(AuthenChecker.checkTestMode(request: request))
    storage.setAppVersion(AuthenChecker.checkVersion(request: request))
    storage.setAppKey(appkey)
    storage.setCollectionName(collectionName)
    
    return storage

}

private func getStorageInstance(request: HTTPRequest, _ response: HTTPResponse) -> Storage? {
    
    guard let appkey = request.urlVariables["appkey"] else {
        response.appendBody(string: ResultBody.errorBody(value: "missing appkey"))
        response.completed()
        return nil
    }

    let storage = Storage()
    storage.setAppVersion(AuthenChecker.checkVersion(request: request))
    storage.setTestMode(AuthenChecker.checkTestMode(request: request))
    storage.setAppKey(appkey)
    
    return storage
    
}

func databaseGetQuery(request: HTTPRequest, _ response: HTTPResponse) {
    
    var skip: Int = 0
    var limit: Int = 100
    
    
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
    
    let storageObj = getStorageInstanceCol(request: request, response)
    
    let data = storageObj?.getQueryCollection(jsonStr, skip: skip, limit: limit)
    
    //let data = Storage.getQueryCollection(appkey, collectionName, json: jsonStr, skip: skip, limit: limit)
    
    response.appendBody(string: data!)
    response.completed()
    
    
}

func replicateDatabase(request: HTTPRequest, _ response: HTTPResponse) {
    
    guard let appkey = request.urlVariables["appkey"] else {
        response.appendBody(string: ResultBody.errorBody(value: "missing appkey"))
        response.completed()
        return
    }
    
    Storage.replicateDatabase(appkey)
    
    response.appendBody(string: ResultBody.successBody(value: ""))
    response.completed()
    
}

func mongoDropCollection(request: HTTPRequest, _ response: HTTPResponse) {
    
    let storageObj = getStorageInstanceCol(request: request, response)
    storageObj?.dropCollection()
    
    response.appendBody(string: ResultBody.successBody(value: storageObj?.getCollectioName() ?? "" + " dropped"))
    response.completed()
    
}

func mongoCreateIndex(request: HTTPRequest, _ response: HTTPResponse) {
    
    let storageObj = getStorageInstanceCol(request: request, response)
    
    guard let index = request.urlVariables["index"] else {
        response.appendBody(string: ResultBody.errorBody(value: "no index"))
        response.completed()
        return
    }
   
    let indexVal = storageObj?.createIndex(index) ?? ""
    
    response.appendBody(string: ResultBody.successBody(value: indexVal))
    response.completed()
    
}


func mongoDropIndex(request: HTTPRequest, _ response: HTTPResponse) {
    
    let storageObj = getStorageInstanceCol(request: request, response)
    
    guard let index = request.urlVariables["index"] else {
        response.appendBody(string: ResultBody.errorBody(value: "no index"))
        response.completed()
        return
    }
    
    storageObj?.dropIndex(index)
    
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
    
    let storage = Storage()
    storage.setAppKey(appkey)
    
    storage.renameCollection(oldCollectionName, newCollection: newCollectionName)
    
    response.appendBody(string: ResultBody.successBody(value: "collection renamed"))
    response.completed()
}


func mongoGetCollections(request: HTTPRequest, _ response: HTTPResponse) {
    
    let storageObj = getStorageInstance(request: request, response)
    
    let returning = storageObj?.getAllCollections() ?? ""
    
    response.appendBody(string: returning)
    response.completed()
}


func databasePost(request: HTTPRequest, _ response: HTTPResponse) {
    
    let storageObj = getStorageInstance(request: request, response)
    
    guard let jsonStr = request.postBodyString else {
        response.appendBody(string: ResultBody.errorBody(value: "no json body"))
        response.completed()
        return
    }
    
    if (storageObj?.parseAndStoreObject(jsonStr))! {
        response.appendBody(string: ResultBody.errorBody(value: "nocollection"))
    } else {
        response.appendBody(string: ResultBody.successBody(value: "collection added"))
    }
    
    response.completed()
}

func databaseCollectionsPost(request: HTTPRequest, _ response: HTTPResponse) {
    
    let storageObj = getStorageInstanceCol(request: request, response)
    
    guard let jsonStr = request.postBodyString else {
        response.appendBody(string: ResultBody.errorBody(value: "no json body"))
        response.completed()
        return
    }
    
    if storageObj!.StoreObjects(jsonStr) {
        response.appendBody(string: ResultBody.errorBody(value: "nocollection"))
    } else {
        response.appendBody(string: ResultBody.successBody(value: "collection added"))
    }
    response.completed()
}

func databaseCollectionPost(request: HTTPRequest, _ response: HTTPResponse) {
    
    var appKeys = "JKHSDGHFKJGH454645GRRLKJF"
    
    if let appkey = request.urlVariables["appkey"] {
        appKeys = appkey
    }
    
    let storageObj = getStorageInstanceCol(request: request, response)
    storageObj?.setAppKey(appKeys)
    

    guard let jsonStr = request.postBodyString else {
        response.appendBody(string: ResultBody.errorBody(value: "no json body"))
        response.completed()
        return
    }
    
    let (result, message) = storageObj!.StoreObject(jsonStr)
    
    if result {
        response.appendBody(string: ResultBody.errorBody(value: message))
    } else {
        response.appendBody(string: ResultBody.successBody(value: message))
    }
    response.completed()
}

func mongoFilterHandler(request: HTTPRequest, _ response: HTTPResponse) {
    
    let storageObj = getStorageInstanceCol(request: request, response)
    
    guard let objectID = request.urlVariables["objectid"] else {
        response.appendBody(string: ResultBody.errorBody(value: "no objectID"))
        response.completed()
        return
    }
    
    let returning = storageObj!.getDocumentWithObjectID(objectID)
    
    response.appendBody(string: returning)
    response.completed()
    
}


func mongoQueryLimit(request: HTTPRequest, _ response: HTTPResponse) {
    
    var skip: Int = 0
    var limit: Int = 100
    
    let storageObj = getStorageInstanceCol(request: request, response)
    
    if let skipValue = request.urlVariables["skip"] {
        skip = skipValue.toInt() ?? 0
    }
    
    if let limitValue = request.urlVariables["limit"] {
        limit = limitValue.toInt() ?? 100
    }
    
    var returning = ResultBody.errorBody(value: "nocollections")
    
    if storageObj!.getCollectioName() == "Tables" {
        returning = storageObj!.getAllCollections()
    } else {
        returning = storageObj!.getQueryCollection("", skip: skip, limit: limit)
    }

    
    response.appendBody(string: returning)
    response.completed()
}


func mongoHandler(request: HTTPRequest, _ response: HTTPResponse) {
    
    let storageObj = getStorageInstanceCol(request: request, response)
    
    var returning = ResultBody.errorBody(value: "nocollections")
    
    if storageObj!.getCollectioName() == "Tables" {
        returning = storageObj!.getAllCollections()
    } else {
        returning = storageObj!.getCollectionValues()
    }

    response.appendBody(string: returning)
    response.completed()
}

func removeCollectionDoc(request: HTTPRequest, _ response: HTTPResponse) {

    let storage = getStorageInstanceCol(request: request, response)
    
    guard let objectID = request.urlVariables["objectid"] else {
        response.appendBody(string: ResultBody.errorBody(value: "no objectID"))
        response.completed()
        return
    }
    
    
    var resultBody = ResultBody.successBody(value:  "removed")
    
    if !storage!.removeDocument(objectID) {
        resultBody = ResultBody.errorBody(value: "not removed")
    }
    
    response.appendBody(string: resultBody)
    response.completed()

}

func removeCollection(request: HTTPRequest, _ response: HTTPResponse) {
    
   let storage = getStorageInstanceCol(request: request, response)
    
    var resultBody = ResultBody.successBody(value:  "removed")
    
    if !storage!.removeCollection() {
        resultBody = ResultBody.errorBody(value: "not removed")
    }
    
    response.appendBody(string: resultBody)
    response.completed()
    
}



func safeRemoveCollectionDoc(request: HTTPRequest, _ response: HTTPResponse) {
    
    let storage = getStorageInstanceCol(request: request, response)
    
    guard let jsonStr = request.postBodyString else {
        response.appendBody(string: ResultBody.errorBody(value: "no json body"))
        response.completed()
        return
    }
    
    
    var resultBody = ResultBody.successBody(value:  "removed")
    
    if !storage!.safeRemoveDocument(jsonStr) {
        resultBody = ResultBody.errorBody(value: "not removed")
    }
    
    response.appendBody(string: resultBody)
    response.completed()
    
}

