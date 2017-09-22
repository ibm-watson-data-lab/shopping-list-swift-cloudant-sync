//
//  Datastore.swift
//  ShoppingList
//
//  Created by Mark Watson on 9/21/17.
//  Copyright © 2017 IBM Watson Data Lab. All rights reserved.
//

import CDTDatastore
import UIKit

class ReplicatorListener : NSObject, CDTReplicatorDelegate {
    
    var onChangesReplicated: ((Int) -> Void)?
    
    override init() {
    }
    
    public func replicatorDidComplete(_ replicator: CDTReplicator) {
        self.onChangesReplicated?(replicator.changesTotal)
    }

}

class Datastore {
    
    let datastore: CDTDatastore
    let shoppingListRepository: ShoppingListRepository
    let replicatorListener: ReplicatorListener = ReplicatorListener()
    
    init?() {
        let fileManager = FileManager.default
        let documentsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).last!
        let storeURL = documentsDir.appendingPathComponent("cloudant-sync-datastore")
        let path = storeURL.path
        do {
            let manager = try CDTDatastoreManager(directory: path)
            self.datastore = try manager.datastoreNamed("shopping-list")
            self.shoppingListRepository = ShoppingListRepository(datastore: self.datastore)
        } catch {
            print("Encountered an error: \(error)")
            return nil
        }
    }
    
    func sync(onSyncComplete:@escaping (Int) -> Void) {
        // Replicate from the local to remote database
        let remote = URL(string: "http://admin:pass@192.168.1.70:35984/shopping-list")!
        self.datastore.push(to: remote) { error in
            if let error = error {
                print("Error performing push replication: \(error)")
            } else {
                do {
                    self.replicatorListener.onChangesReplicated = onSyncComplete
                    try self.datastore.pullReplicationSource(remote, username: nil, password: nil, with: self.replicatorListener).start()
                }
                catch {
                    print("ERROR \(error)")
                }
//                self.datastore.pull(from: remote) { error in
//                    if let error = error {
//                        print("Error performing pull replication: \(error)")
//                    } else {
//                        onSyncComplete()
//                    }
//                }
            }
        }
    }
    
    
    func loadLists() -> [ListMeta] {
        var lists = [ListMeta]()
        let allLists = self.shoppingListRepository.find()
        for list in allLists {
            let items = self.shoppingListRepository.findItems(query: ["type": "item", "list": list.docId!])
            let listMeta = ListMeta(list: list)
            listMeta.itemCount = items.count
            listMeta.itemCheckedCount = items.filter{ $0.body["checked"] as! Bool }.count
            lists.append(listMeta)
        }
        return lists
    }
    
    func addList(title: String) throws -> CDTDocumentRevision {
        let list = ShoppingListFactory.newShoppingList(title: title)
        let newList = try self.shoppingListRepository.put(list: list)
        self.sync(onSyncComplete: { _ in })
        return newList
    }
    
    func deleteList(list: CDTDocumentRevision) throws -> CDTDocumentRevision {
        let existingList = try self.shoppingListRepository.get(listId: list.docId!)
        let deletedList = try self.shoppingListRepository.delete(list: existingList)
        self.sync(onSyncComplete: { _ in })
        return deletedList
    }
    
    func loadItems(list: CDTDocumentRevision) -> [CDTDocumentRevision] {
        let result = self.datastore.find(["type": "item", "list": list.docId!])
        var items = [CDTDocumentRevision]()
        result?.enumerateObjects { rev, idx, stop in
            items.append(rev)
        }
        return items
    }
    
    func addItem(title: String, listId: String) throws -> CDTDocumentRevision {
        let list = try self.shoppingListRepository.get(listId: listId)
        let item = ShoppingListFactory.newShoppingListItem(title: title, list: list)
        let newItem = try self.shoppingListRepository.putItem(item: item)
        self.sync(onSyncComplete: { _ in })
        return newItem
    }
    
    func toggleItemChecked(item: CDTDocumentRevision) throws -> CDTDocumentRevision {
        let checked = !(item.body["checked"] as! Bool)
        let existingItem = try self.shoppingListRepository.getItem(itemId: item.docId!)
        existingItem.body["checked"] = checked
        let updatedItem = try self.shoppingListRepository.putItem(item: existingItem)
        self.sync(onSyncComplete: { _ in })
        return updatedItem
    }
    
    func deleteItem(item: CDTDocumentRevision) throws -> CDTDocumentRevision {
        let existingItem = try self.shoppingListRepository.getItem(itemId: item.docId!)
        let deletedItem = try self.shoppingListRepository.deleteItem(item: existingItem)
        self.sync(onSyncComplete: { _ in })
        return deletedItem
    }
    
    func deleteAllDocs() throws {
        let allDocs = self.datastore.getAllDocuments()
        for doc in allDocs {
            try self.datastore.deleteDocument(from: doc)
        }
    }

}
