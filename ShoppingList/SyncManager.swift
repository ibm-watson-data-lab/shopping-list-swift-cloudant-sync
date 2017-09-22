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
    private static var timer: Timer?
    private static var running = false
    
    static func startSync() {
        running = true
        let queue = DispatchQueue(label: "com.ibm.shoppinglist.sync", qos: DispatchQoS.userInteractive)
        queue.async {
            sync()
        }
    }
    
    static func sync() {
        StateManager.datastore.sync(onSyncComplete: { changes in
            if (changes > 0) {
                DispatchQueue.main.sync {
                    syncListener?.onSyncComplete()
                }
            }
            if running {
                sleep(2)
                sync()
            }
        })
    }
    
    static func stopSync() {
        running = false
        timer?.invalidate()
        timer = nil
    }
    
}
