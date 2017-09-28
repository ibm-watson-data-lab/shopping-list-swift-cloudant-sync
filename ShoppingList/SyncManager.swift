//
//  SyncManager.swift
//  ShoppingList
//
//  Created by Mark Watson on 9/21/17.
//  Copyright © 2017 IBM Watson Data Lab. All rights reserved.
//

import CDTDatastore
import Foundation

protocol SyncListener {
    func onSyncComplete()
}

class SyncManager {
    
    static var syncListener: SyncListener? = nil
    static var activeSyncUrl : String? = nil
    private static var settingsDatastore: CDTDatastore? = nil
    private static var settingsDoc: CDTDocumentRevision? = nil
    private static var running = false
    
    static func startSync(settingsDatastore: CDTDatastore) {
        SyncManager.activeSyncUrl = nil
        SyncManager.settingsDatastore = settingsDatastore
        do {
            SyncManager.settingsDoc = try SyncManager.settingsDatastore?.getDocumentWithId("settings")
            SyncManager.applySyncUrl(syncUrl: SyncManager.settingsDoc?.body["syncUrl"] as? String, updateDB: false)
        }
        catch {
            // ignore
        }
    }
    
    private static func start() {
        guard let syncUrl = StateManager.datastore.shoppingListRepository.syncUrl, !syncUrl.isEmpty else {
            SyncManager.running = false
            return // or break, continue, throw
        }
        SyncManager.running = true
        let queue = DispatchQueue(label: "com.ibm.shoppinglist.sync", qos: DispatchQoS.userInteractive)
        queue.async {
            while SyncManager.running {
                StateManager.datastore.shoppingListRepository.sync()
                sleep(2)
            }
        }
    }
    
    static func stopSync() {
        SyncManager.running = false
    }
    
    static func onSyncComplete() {
        DispatchQueue.main.sync {
            SyncManager.syncListener?.onSyncComplete()
        }
    }
    
    static func updateSyncUrl(syncUrl: String?) {
        SyncManager.applySyncUrl(syncUrl: syncUrl, updateDB: true)
    }
    
    private static func applySyncUrl(syncUrl: String?, updateDB: Bool) {
        print(syncUrl)
        if (syncUrl != SyncManager.activeSyncUrl) {
            if (updateDB) {
                if (SyncManager.settingsDoc == nil) {
                    SyncManager.settingsDoc = CDTDocumentRevision(docId: "settings")
                    SyncManager.settingsDoc!.body = ["syncUrl": syncUrl ?? ""]
                    do {
                        SyncManager.settingsDoc = try SyncManager.settingsDatastore!.createDocument(from: SyncManager.settingsDoc!)
                    }
                    catch {
                        // TODO
                    }
                }
                else {
                    SyncManager.settingsDoc!.body = ["syncUrl": syncUrl ?? ""]
                    do {
                        SyncManager.settingsDoc = try SyncManager.settingsDatastore!.updateDocument(from: SyncManager.settingsDoc!)
                    }
                    catch {
                        // TODO
                    }
                }
            }
            SyncManager.activeSyncUrl = syncUrl
            StateManager.datastore.shoppingListRepository.syncUrl = syncUrl
            if (!SyncManager.running) {
                SyncManager.start()
            }
        }
    }
    
}
