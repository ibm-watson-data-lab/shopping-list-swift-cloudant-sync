//
//  ShoppingListAddViewController.swift
//  ShoppingList
//
//  Created by Mark Watson on 9/21/17.
//  Copyright © 2017 IBM Watson Data Lab. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet var doneButton: UIBarButtonItem!
    @IBOutlet var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.doneButton.action = #selector(SettingsViewController.save)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.textField.text = SyncManager.activeSyncUrl
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.textField.text = ""
    }
    
    func save() {
        SyncManager.updateSyncUrl(syncUrl: self.textField!.text)
        _ = self.navigationController?.popViewController(animated: true)
    }
    
}

