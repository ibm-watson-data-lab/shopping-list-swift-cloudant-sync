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
    
    public func put(list: CDTDocumentRevision) throws -> CDTDocumentRevision {
        if (list.revId != nil) {
            return try self.datastore.createDocument(from: list)
        }
        else {
            return try self.datastore.updateDocument(from: list)
        }
    }
    
    
}
