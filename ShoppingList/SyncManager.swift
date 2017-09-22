//
//  SyncManager.swift
//  ShoppingList
//
//  Created by Mark Watson on 9/21/17.
//  Copyright © 2017 IBM Watson Data Lab. All rights reserved.
//

import Foundation

protocol SyncListener {
    func onSyncComplete()
}

class SyncManager {
    
    static var syncListener: SyncListener? = nil
    private static var running = false
    
    static func startSync() {
        running = true
        let queue = DispatchQueue(label: "com.ibm.shoppinglist.sync", qos: DispatchQoS.userInteractive)
        queue.async {
            while running {
                StateManager.datastore.shoppingListRepository.sync()
                sleep(2)
            }
        }
    }
    
    static func stopSync() {
        running = false
    }
    
    static func onSyncComplete() {
        DispatchQueue.main.sync {
            syncListener?.onSyncComplete()
        }
    }
    
}
