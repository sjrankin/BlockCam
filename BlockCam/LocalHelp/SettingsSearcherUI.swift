//
//  SettingsSearcherUI.swift
//  BlockCam
//
//  Created by Stuart Rankin on 3/22/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class SettingsSearcherUI: UIViewController, UITableViewDelegate, UITableViewDataSource,
    UISearchBarDelegate
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        SearchResultsTable.layer.borderColor = UIColor.black.cgColor
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        return UITableViewCell()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        print("Start searching for \((searchBar.text)!)")
    }
    
    @IBOutlet weak var SearchEntry: UISearchBar!
    @IBOutlet weak var SearchResultsTable: UITableView!
}
