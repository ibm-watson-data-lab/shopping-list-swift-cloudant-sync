//
//  ShoppingListAddViewController.swift
//  ShoppingList
//
//  Created by Mark Watson on 9/21/17.
//  Copyright © 2017 IBM Watson Data Lab. All rights reserved.
//

import UIKit

class ShoppingListAddViewController: UIViewController {
    
    var doneButtonColor: UIColor!
    @IBOutlet var doneButton: UIBarButtonItem!
    @IBOutlet var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.doneButtonColor = self.doneButton.tintColor
        self.doneButton.isEnabled = false
        self.doneButton.tintColor = UIColor.clear
        self.doneButton.action = #selector(save)
        self.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.doneButton.isEnabled = false
        self.doneButton.tintColor = UIColor.clear
        self.textField.text = ""
    }
    
    func save() {
        do {
            _ = try StateManager.datastore.addList(title: self.textField!.text!)
            _ = self.navigationController?.popViewController(animated: true)
        }
        catch {
            // TODO:
        }
        //StateManager.datastore.addItem(title: self.textField.text, listId: StateManager.activeList.docId!)
    }
    
    @IBAction func textFieldDidChange(_ textField: UITextField) {
        if (self.textField.text != nil && self.textField?.text != "") {
            self.doneButton.isEnabled = true
            self.doneButton.tintColor = self.doneButtonColor
        }
        else {
            self.doneButton.isEnabled = false
            self.doneButton.tintColor = UIColor.clear
        }
    }
    
}

