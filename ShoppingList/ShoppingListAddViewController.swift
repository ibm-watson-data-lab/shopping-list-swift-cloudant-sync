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
        self.disableDoneButton()
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
        self.disableDoneButton()
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
    }
    
    func enableDoneButton() {
        if self.doneButton.isEnabled {
            return
        }
        self.doneButton.isEnabled = true
        self.doneButton.tintColor = self.doneButtonColor
        self.doneButton.action = #selector(ShoppingListManageViewController.save)
    }
    
    func disableDoneButton() {
        if !self.doneButton.isEnabled {
            return
        }
        self.doneButton.isEnabled = false
        self.doneButton.tintColor = UIColor.clear
        self.doneButton.action = nil
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        if (textField.text != nil && textField.text != "") {
            self.enableDoneButton()
        }
        else {
            self.disableDoneButton()
        }
    }
    
}

