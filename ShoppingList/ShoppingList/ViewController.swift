//
//  ViewController.swift
//  ShoppingList
//
//  Created by Mark Watson on 9/21/17.
//  Copyright © 2017 IBM Watson Data Lab. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    
    var datastore: Datastore? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.datastore = Datastore()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        do {
            try self.datastore?.deleteAllDocs()
            try self.datastore?.addList(title: "Lister 1")
            let lists = try self.datastore?.loadLists()
            if (lists != nil) {
                for list in lists! {
                    print(list.list?.body["title"] ?? "NO TITLE")
                }
            }
        }
        catch {}
    }


}

