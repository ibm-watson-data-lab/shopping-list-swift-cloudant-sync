//
//  ShoppingListFactory.swift
//  ShoppingList
//
//  Created by Mark Watson on 9/21/17.
//  Copyright © 2017 IBM Watson Data Lab. All rights reserved.
//

import CDTDatastore

class ShoppingListFactory {
    
    static func newShoppingList(title: String) -> CDTDocumentRevision {
        let rev = CDTDocumentRevision(docId: "list:\(UUID().uuidString)")
        rev.body = ["type":"list", "title":title]
        return rev
    }
    
    static func newShoppingListItem(title: String, list: CDTDocumentRevision) -> CDTDocumentRevision {
        let rev = CDTDocumentRevision(docId: "item:\(UUID().uuidString)")
        rev.body = ["type":"item", "title":title, "list":list.docId!]
        return rev
    }
    
}
