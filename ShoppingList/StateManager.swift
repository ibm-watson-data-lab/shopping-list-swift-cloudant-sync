//
//  StateManager.swift
//  ShoppingList
//
//  Created by Mark Watson on 9/21/17.
//  Copyright © 2017 IBM Watson Data Lab. All rights reserved.
//

import CDTDatastore

class StateManager {
    
    private static var _datastore: Datastore?
    
    public static var datastore: Datastore {
        get {
            if (_datastore == nil) {
                _datastore = Datastore()
            }
            return _datastore!
        }
    }
    
    public static var activeShoppingList: CDTDocumentRevision?
    
}
