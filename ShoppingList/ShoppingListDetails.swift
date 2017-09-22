//
//  ListMeta.swift
//  ShoppingList
//
//  Created by Mark Watson on 9/21/17.
//  Copyright © 2017 IBM Watson Data Lab. All rights reserved.
//

import CDTDatastore
import UIKit

class ShoppingListDetails {
    
    public let list: CDTDocumentRevision
    public var itemCount: Int = 0
    public var itemCheckedCount: Int = 0
    
    init(list: CDTDocumentRevision) {
        self.list = list
    }

}
