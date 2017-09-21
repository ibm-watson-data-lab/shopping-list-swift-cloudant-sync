//
//  ShoppingListsViewController.swift
//  ShoppingList
//
//  Created by Mark Watson on 9/21/17.
//  Copyright © 2017 IBM Watson Data Lab. All rights reserved.
//

import UIKit

class ShoppingListsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var lists: [ListMeta] = []
    let cellReuseIdentifier = "ShoppingListsCell"
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
//        do {
//            try StateManager.datastore.deleteAllDocs()
//        }
//        catch {}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.lists = StateManager.datastore.loadLists()
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.lists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let listMeta = self.lists[indexPath.row]
        let cell:ShoppingListsTableCell = self.tableView.dequeueReusableCell(withIdentifier: "ShoppingListsCell") as! ShoppingListsTableCell!
        cell.titleLabel?.text = listMeta.list.body["title"] as? String
        cell.checkedItemsLabel?.text = self.getItemsChecked(list: listMeta)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.lists.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    func getItemsChecked(list: ListMeta) -> String {
        var itemsString = ""
        if (list.itemCount == 0) {
            itemsString = "0 items"
        }
        else if (list.itemCount == 1) {
            itemsString = "1 item \(list.itemCheckedCount > 0 ? "" : "un")checked."
        }
        else {
            itemsString = "\(list.itemCheckedCount) of \(list.itemCount) items checked."
        }
        return itemsString
    }

}

