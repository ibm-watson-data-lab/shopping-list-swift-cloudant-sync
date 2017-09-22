//
//  ShoppingListRepository.swift
//  ShoppingList
//
//  Created by Mark Watson on 9/21/17.
//  Copyright © 2017 IBM Watson Data Lab. All rights reserved.
//

import CDTDatastore

class ShoppingListRepository {
    
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
    
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
        if (list.revId == nil) {
            list.body["createdAt"] = ShoppingListRepository.iso8601.string(from: Date())
            list.body["updatedAt"] = ShoppingListRepository.iso8601.string(from: Date())
            return try self.datastore.createDocument(from: list)
        }
        else {
            list.body["updatedAt"] = ShoppingListRepository.iso8601.string(from: Date())
            return try self.datastore.updateDocument(from: list)
        }
    }
    
    public func delete(list: CDTDocumentRevision) throws -> CDTDocumentRevision {
        return try self.datastore.deleteDocument(from: list)
    }
    
    public func getItem(itemId: String) throws -> CDTDocumentRevision {
        return try self.datastore.getDocumentWithId(itemId)
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
        if (item.revId == nil) {
            item.body["createdAt"] = ShoppingListRepository.iso8601.string(from: Date())
            item.body["updatedAt"] = ShoppingListRepository.iso8601.string(from: Date())
            return try self.datastore.createDocument(from: item)
        }
        else {
            item.body["updatedAt"] = ShoppingListRepository.iso8601.string(from: Date())
            return try self.datastore.updateDocument(from: item)
        }
    }
    
    public func deleteItem(item: CDTDocumentRevision) throws -> CDTDocumentRevision {
        return try self.datastore.deleteDocument(from: item)
    }
    
}
