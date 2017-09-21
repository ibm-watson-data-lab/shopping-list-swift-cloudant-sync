//
//  Datastore.swift
//  ShoppingList
//
//  Created by Mark Watson on 9/21/17.
//  Copyright © 2017 IBM Watson Data Lab. All rights reserved.
//

import CDTDatastore
import UIKit

class Datastore {
    
    let datastore: CDTDatastore
    let shoppingListRepository: ShoppingListRepository
    
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
    
    func loadLists() -> [ListMeta] {
        var lists = [ListMeta]()
        let allLists = self.shoppingListRepository.find()
        for list in allLists {
            let items = self.shoppingListRepository.findItems(query: ["type": "item", "list": list.docId!])
            let listMeta = ListMeta(list: list)
            listMeta.itemCount = items.count
            listMeta.itemCount = items.filter{ $0.body["checked"] as! Bool }.count
            lists.append(listMeta)
        }
        return lists
    }
    
    func addList(title: String) throws -> CDTDocumentRevision {
        let list = ShoppingListFactory.newShoppingList(title: title)
        return try self.shoppingListRepository.put(list: list)
    }
    
    func deleteAllDocs() throws {
        let allDocs = self.datastore.getAllDocuments()
        for doc in allDocs {
            try self.datastore.deleteDocument(from: doc)
        }
    }
    
    func loadActiveItems(list: CDTDocumentRevision) -> [CDTDocumentRevision] {
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
        return try self.shoppingListRepository.putItem(item: item)
    }

}
