//
//  EntryViewController.swift
//  BlockCam
//
//  Created by Stuart Rankin on 12/16/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class EntryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    weak var Delegate: LogViewProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let ID = Delegate?.GetSessionID()
        let Session = Log.GetSession(ID!)
        Log.PopulateEntries(Session!)
        EntryTable.layer.borderColor = UIColor.black.cgColor
        Entries = Session!.Entries
        EntryTable.reloadData()
        EntryText.layer.borderColor = UIColor.black.cgColor
        EntryText.text = ""
        CopyButton.isUserInteractionEnabled = true
        CopyButton.tintColor = UIColor.systemGray
    }
    
    var Entries: [LogEntry] = []
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return Entries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let Cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "EntryCell")
        Cell.textLabel?.text = Entries[indexPath.row].Message
        Cell.detailTextLabel?.text = Entries[indexPath.row].TimeStamp
        if Entries[indexPath.row].Aborted
        {
            Cell.backgroundColor = UIColor(red: 1.0, green: 0.9, blue: 0.9, alpha: 1.0)
        }
        return Cell
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        CopyButton.isUserInteractionEnabled = true
        CopyButton.tintColor = UIColor.systemBlue
        let Message = Entries[indexPath.row].Message
        SelectedText = Message
        EntryText.text = Message
    }
    
    var SelectedText = ""
    
    //https://stackoverflow.com/questions/24670290/how-to-copy-text-to-clipboard-pasteboard-with-swift
    @IBAction func HandleCopyPressed(_ sender: Any)
    {
        if !SelectedText.isEmpty
        {
        UIPasteboard.general.string = SelectedText
        }
    }
    
    @IBOutlet weak var EntryTable: UITableView!
    @IBOutlet weak var EntryText: UITextView!
    @IBOutlet weak var CopyButton: UIToolbar!
}
