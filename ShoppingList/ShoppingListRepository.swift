//
//  ShoppingListRepository.swift
//  ShoppingList
//
//  Created by Mark Watson on 9/21/17.
//  Copyright © 2017 IBM Watson Data Lab. All rights reserved.
//

import CDTDatastore

class ShoppingListRepository {
    
    class ReplicationListener : NSObject, CDTReplicatorDelegate {
        public func replicatorDidComplete(_ replicator: CDTReplicator) {
            if replicator.changesProcessed > 0 || replicator.changesProcessed > 0 {
                SyncManager.onSyncComplete()
            }
        }
    }
    
    private static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
    
    let datastore: CDTDatastore
    let replicationListener = ReplicationListener()
    var syncUrl: String? = nil
    
    init(datastore: CDTDatastore) {
        self.datastore = datastore
    }
    
    func sync() {
        if (self.syncUrl == nil) {
            return
        }
        let remote = URL(string: self.syncUrl!)!
        self.datastore.push(to: remote) { error in
            if let error = error {
                print("Error performing push replication: \(error)")
            }
            do {
                try self.datastore.pullReplicationSource(remote, username: nil, password: nil, with: self.replicationListener).start()
            }
            catch {
                // TODO:
                print("ERROR \(error)")
            }
        }
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
    
    public func put(shoppingList: CDTDocumentRevision) throws -> CDTDocumentRevision {
        let rev: CDTDocumentRevision
        let shoppingListCopy = CDTDocumentRevision(docId: shoppingList.docId, revisionId: shoppingList.revId, body: shoppingList.body as NSDictionary? as? [AnyHashable: Any], attachments: nil)
        if (shoppingList.revId == nil) {
            shoppingListCopy.body["createdAt"] = ShoppingListRepository.iso8601.string(from: Date())
            shoppingListCopy.body["updatedAt"] = ShoppingListRepository.iso8601.string(from: Date())
            rev = try self.datastore.createDocument(from: shoppingListCopy)
        }
        else {
            shoppingListCopy.body["updatedAt"] = ShoppingListRepository.iso8601.string(from: Date())
            rev = try self.datastore.updateDocument(from: shoppingListCopy)
        }
        self.sync()
        return rev
    }
    
    public func delete(shoppingList: CDTDocumentRevision) throws -> CDTDocumentRevision {
        let rev = try self.datastore.deleteDocument(from: shoppingList)
        self.sync()
        return rev
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
    
    public func putItem(shoppingListItem: CDTDocumentRevision) throws -> CDTDocumentRevision {
        let rev: CDTDocumentRevision
        let shoppingListItemCopy = CDTDocumentRevision(docId: shoppingListItem.docId, revisionId: shoppingListItem.revId, body: shoppingListItem.body as NSDictionary? as? [AnyHashable: Any], attachments: nil)
        if (shoppingListItem.revId == nil) {
            shoppingListItemCopy.body["createdAt"] = ShoppingListRepository.iso8601.string(from: Date())
            shoppingListItemCopy.body["updatedAt"] = ShoppingListRepository.iso8601.string(from: Date())
            rev = try self.datastore.createDocument(from: shoppingListItemCopy)
        }
        else {
            shoppingListItemCopy.body["updatedAt"] = ShoppingListRepository.iso8601.string(from: Date())
            rev = try self.datastore.updateDocument(from: shoppingListItemCopy)
        }
        self.sync()
        return rev
    }
    
    public func deleteItem(shoppingListItem: CDTDocumentRevision) throws -> CDTDocumentRevision {
        let rev = try self.datastore.deleteDocument(from: shoppingListItem)
        self.sync()
        return rev
    }
    
}
