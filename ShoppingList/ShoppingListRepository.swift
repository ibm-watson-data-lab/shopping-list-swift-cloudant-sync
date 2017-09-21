//
//  ShoppingListRepository.swift
//  ShoppingList
//
//  Created by Mark Watson on 9/21/17.
//  Copyright © 2017 IBM Watson Data Lab. All rights reserved.
//


import CDTDatastore

class ShoppingListRepository {
    
    let datastore: CDTDatastore
    
    init(datastore: CDTDatastore) {
        self.datastore = datastore
    }
    
    public func get(listId: String) throws -> CDTDocumentRevision {
        return try self.datastore.getDocumentWithId(listId)
    }
    
    public func find() -> [CDTDocumentRevision] {
        var lists = [CDTDocumentRevision]()
        let result = self.datastore.find(["type": "list"])
        result?.enumerateObjects { rev, idx, stop in
            lists.append(rev)
        }
        return lists
    }
    
    public func put(list: CDTDocumentRevision) throws -> CDTDocumentRevision {
        if (list.revId != nil) {
            return try self.datastore.createDocument(from: list)
        }
        else {
            return try self.datastore.updateDocument(from: list)
        }
    }
    
    public func findItems(query: [AnyHashable: Any]) -> [CDTDocumentRevision] {
        var items = [CDTDocumentRevision]()
        let result = self.datastore.find(query)
        result?.enumerateObjects { rev, idx, stop in
            items.append(rev)
        }
        return items
    }
    
    public func putItem(item: CDTDocumentRevision) throws -> CDTDocumentRevision {
        if (item.revId != nil) {
            return try self.datastore.createDocument(from: item)
        }
        else {
            return try self.datastore.updateDocument(from: item)
        }
    }
    
    
}
