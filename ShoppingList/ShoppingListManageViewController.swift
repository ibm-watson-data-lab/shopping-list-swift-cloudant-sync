//
//  ShoppingListManageViewController.swift
//  ShoppingList
//
//  Created by Mark Watson on 9/21/17.
//  Copyright © 2017 IBM Watson Data Lab. All rights reserved.
//

import CDTDatastore
import UIKit

class ShoppingListManageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SyncListener {
    
    var items: [CDTDocumentRevision] = []
    var newItemTitleText: String = ""
    var doneButtonColor: UIColor!
    @IBOutlet var doneButton: UIBarButtonItem!
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.doneButtonColor = self.doneButton.tintColor
        self.disableDoneButton()
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SyncManager.syncListener = self
        self.reloadItems()
    }
    
    internal func onSyncComplete() {
        self.reloadItems()
    }
    
    private func reloadItems() {
        self.items = StateManager.datastore.loadItems(list: StateManager.activeList!)
        self.tableView.reloadData()
        self.tableView.setNeedsDisplay()
    }
    
    func save() {
        print("save")
        do {
            let item = try StateManager.datastore.addItem(title: self.newItemTitleText, listId: StateManager.activeList!.docId!)
            self.items.append(item)
            self.newItemTitleText = ""
            self.disableDoneButton()
            self.tableView.reloadData()
        }
        catch {
            print("ERROR \(error)")
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
            self.newItemTitleText = textField.text!
            self.enableDoneButton()
        }
        else {
            self.newItemTitleText = ""
            self.disableDoneButton()
        }
    }
    
    func switchDidChange(s: UISwitch) {
        do {
            let item = self.items[s.tag]
            let updatedItem = try StateManager.datastore.toggleItemChecked(item: item)
            self.items[s.tag] = updatedItem
            self.tableView.reloadData()
        }
        catch {
            print("caught: \(error)")
            // TODO:
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count + 1
    }
    
    static func setBottomBorderToTextFields(cell: ShoppingListTableCell)  {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: cell.titleTextField.frame.height - 1, width: cell.titleTextField.frame.width, height: 1)
        bottomLine.backgroundColor = UIColor.lightGray.cgColor // background color
        cell.titleTextField.borderStyle = UITextBorderStyle.none // border style
        cell.titleTextField.layer.addSublayer(bottomLine)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:ShoppingListTableCell = self.tableView.dequeueReusableCell(withIdentifier: "ShoppingListCell") as! ShoppingListTableCell!
        if indexPath.row < self.items.count {
            cell.checkedSwitch.isEnabled = true
            cell.checkedSwitch.isOn = self.items[indexPath.row].body["checked"] as! Bool
            cell.checkedSwitch.tag = indexPath.row
            cell.checkedSwitch.addTarget(self, action: #selector(switchDidChange), for: UIControlEvents.valueChanged)
            cell.titleTextField.isEnabled = false
            cell.titleTextField.text = self.items[indexPath.row].body["title"] as? String
            cell.titleTextField.removeTarget(self, action: nil, for: .editingChanged)
            cell.titleTextField.layer.sublayers?.removeAll()
        }
        else {
            cell.checkedSwitch.isEnabled = false
            cell.checkedSwitch.removeTarget(self, action: nil, for: UIControlEvents.valueChanged)
            cell.titleTextField.isEnabled = true
            cell.titleTextField.text = self.newItemTitleText
            cell.titleTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            ShoppingListManageViewController.setBottomBorderToTextFields(cell: cell)
            cell.titleTextField.becomeFirstResponder()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if indexPath.row < self.items.count {
            return UITableViewCellEditingStyle.delete
        }
        else {
            return UITableViewCellEditingStyle.none
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if indexPath.row < self.items.count {
                do {
                    _ = try StateManager.datastore.deleteItem(item: self.items[indexPath.row])
                    self.items.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
                catch {
                    // TODO:
                }
            }
        }
    }
}

