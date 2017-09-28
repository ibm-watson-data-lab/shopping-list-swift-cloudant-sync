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
    
    let settingsDB: CDTDatastore
    let shoppingListDB: CDTDatastore
    let shoppingListRepository: ShoppingListRepository
    
    init?() {
        let fileManager = FileManager.default
        let documentsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).last!
        let storeURL = documentsDir.appendingPathComponent("cloudant-sync-datastore")
        let path = storeURL.path
        do {
            let manager = try CDTDatastoreManager(directory: path)
            self.settingsDB = try manager.datastoreNamed("settings")
            self.shoppingListDB = try manager.datastoreNamed("shopping-list")
            self.shoppingListRepository = ShoppingListRepository(datastore: self.shoppingListDB)
        } catch {
            print("Encountered an error: \(error)")
            return nil
        }
    }
    
    func loadLists() -> [ShoppingListDetails] {
        var lists = [ShoppingListDetails]()
        let allLists = self.shoppingListRepository.find()
        for list in allLists {
            let items = self.shoppingListRepository.findItems(query: ["type": "item", "list": list.docId!])
            let listDetails = ShoppingListDetails(list: list)
            listDetails.itemCount = items.count
            listDetails.itemCheckedCount = items.filter{ $0.body["checked"] as! Bool }.count
            lists.append(listDetails)
        }
        return lists
    }
    
    func addList(title: String) throws -> CDTDocumentRevision {
        let list = ShoppingListFactory.newShoppingList(title: title)
        return try self.shoppingListRepository.put(shoppingList: list)
    }
    
    func deleteList(list: CDTDocumentRevision) throws -> CDTDocumentRevision {
        let existingList = try self.shoppingListRepository.get(listId: list.docId!)
        let deletedList = try self.shoppingListRepository.delete(shoppingList: existingList)
        return deletedList
    }
    
    func loadItems(list: CDTDocumentRevision) -> [CDTDocumentRevision] {
        let result = self.shoppingListDB.find(["type": "item", "list": list.docId!])
        var items = [CDTDocumentRevision]()
        result?.enumerateObjects { rev, idx, stop in
            items.append(rev)
        }
        return items
    }
    
    func addItem(title: String, listId: String) throws -> CDTDocumentRevision {
        let list = try self.shoppingListRepository.get(listId: listId)
        let item = ShoppingListFactory.newShoppingListItem(title: title, list: list)
        let newItem = try self.shoppingListRepository.putItem(shoppingListItem: item)
        return newItem
    }
    
    func toggleItemChecked(item: CDTDocumentRevision) throws -> CDTDocumentRevision {
        let checked = !(item.body["checked"] as! Bool)
        let existingItem = try self.shoppingListRepository.getItem(itemId: item.docId!)
        existingItem.body["checked"] = checked
        let updatedItem = try self.shoppingListRepository.putItem(shoppingListItem: existingItem)
        return updatedItem
    }
    
    func deleteItem(item: CDTDocumentRevision) throws -> CDTDocumentRevision {
        let existingItem = try self.shoppingListRepository.getItem(itemId: item.docId!)
        let deletedItem = try self.shoppingListRepository.deleteItem(shoppingListItem: existingItem)
        return deletedItem
    }
    
    func deleteAllDocs() throws {
        let allDocs = self.shoppingListDB.getAllDocuments()
        for doc in allDocs {
            try self.shoppingListDB.deleteDocument(from: doc)
        }
    }

}
