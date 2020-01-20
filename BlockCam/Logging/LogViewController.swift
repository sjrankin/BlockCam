//
//  LogViewController.swift
//  BlockCam
//
//  Created by Stuart Rankin on 12/16/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class LogViewController: UIViewController,
    UITableViewDelegate, UITableViewDataSource,
    LogViewProtocol
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        PleaseWaitLayer.isHidden = true
        PleaseWaitLayer.layer.borderColor = UIColor.black.cgColor
        PleaseWaitLayer.frame = CGRect(x: self.view.frame.width / 2.0 - PleaseWaitLayer.frame.width / 2.0,
                                       y: 150.0,
                                       width: PleaseWaitLayer.frame.width,
                                       height: PleaseWaitLayer.frame.height)
        ExportButton.isEnabled = false
        SessionTable.layer.borderColor = UIColor.black.cgColor
        SessionDataTable.layer.borderColor = UIColor.black.cgColor
        LoadSessions()
    }
    
    func LoadSessions()
    {
        SessionList = Log.GetSessionList()
        SessionList.forEach{$0.ScratchCount = Log.GetEntryCount(ForSessionID: $0.ID)}
        SessionList.sort{$0.ConvertedSessionDate > $1.ConvertedSessionDate}
        SessionTable.reloadData()
    }
    
    var SessionList: [LoggingSession] = []
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch tableView.tag
        {
            case 100:
                if SessionList.count == 0
                {
                    DeleteButton.isEnabled = false
                    DeleteButton.tintColor = UIColor.systemGray
                }
                else
                {
                    DeleteButton.isEnabled = true
                    DeleteButton.tintColor = UIColor.systemRed
                }
                return SessionList.count
            
            case 200:
                return SessionDataList.count
            
            default:
                return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        switch tableView.tag
        {
            case 100:
                let Cell = LogSessionCell(style: .default, reuseIdentifier: "SessionCell")
                var SubTitle = SessionList[indexPath.row].AppName
                SubTitle.append(" " + SessionList[indexPath.row].AppVersion)
                SubTitle.append(" build \(SessionList[indexPath.row].AppBuild)")
                let Count = Log.GetEntryCount(ForSessionID: SessionList[indexPath.row].ID)
                Cell.LoadData(Title: SessionList[indexPath.row].SessionDate, SubTitle: SubTitle, Count: Count,
                              Width: tableView.frame.width)
                return Cell
            
            case 200:
                let Cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "SessionDataCell")
                Cell.textLabel!.text = SessionDataList[indexPath.row].1
                Cell.detailTextLabel!.text = SessionDataList[indexPath.row].0
                return Cell
            
            default:
                return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        switch tableView.tag
        {
            case 100:
                CurrentSessionID = SessionList[indexPath.row].ID
                if SessionList[indexPath.row].ScratchCount > 0
                {
                    ViewSessionButton.isEnabled = true
                }
                else
                {
                    ViewSessionButton.isEnabled = false
                }
                SessionDataList.removeAll()
                if let TheSession = Log.GetSession(CurrentSessionID)
                {
                    let EntryCount = Log.GetEntryCount(ForSessionID: CurrentSessionID)
                    if !TheSession.Name.isEmpty
                    {
                        SessionDataList.append(("Name", TheSession.Name))
                    }
                    SessionDataList.append(("ID", TheSession.ID.uuidString))
                    SessionDataList.append(("Date", TheSession.SessionDate))
                    SessionDataList.append(("Entries", "\(EntryCount)"))
                    SessionDataList.append(("App", TheSession.AppName))
                    SessionDataList.append(("App Version", TheSession.AppVersion))
                    SessionDataList.append(("App Build", "\(TheSession.AppBuild)"))
                    SessionDataList.append(("Device", TheSession.Device))
                    SessionDataList.append(("OS", TheSession.OSVersion))
                }
                SessionDataTable.reloadData()
                //If the currently selected session is the curren logging session, set the flag that prevents the user
                //from deleting it.
                CanDeleteCurrentSession = !(CurrentSessionID == Log.SessionID)
                //We can export only if something is selected
                ExportButton.isEnabled = true
            
            case 200:
                break
            
            default:
                break
        }
    }
    
    var CanDeleteCurrentSession = false
    
    var SessionDataList = [(String, String)]()
    
    var CurrentSessionID = UUID()
    
    func GetSessionID() -> UUID
    {
        return CurrentSessionID
    }
    
    @IBSegueAction func InstantiateEntryViewer(_ coder: NSCoder) -> EntryViewController?
    {
        let Viewer = EntryViewController(coder: coder)
        Viewer?.Delegate = self
        return Viewer
    }
    
    @IBAction func HandleDeleteSomething(_ sender: Any)
    {
        let Alert = UIAlertController(title: "Select Object to Delete",
                                      message: "You can delete either the currently selected session or all sessions. You cannot delete the current logging session.",
                                      preferredStyle: .alert)
        if CanDeleteCurrentSession
        {
            Alert.addAction(UIAlertAction(title: "Delete Session", style: .destructive, handler: HandleDoDeleteSomething(_:)))
        }
        Alert.addAction(UIAlertAction(title: "Delete All", style: .destructive, handler: HandleDoDeleteSomething(_:)))
        Alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(Alert, animated: true)
    }
    
    @objc func HandleDoDeleteSomething(_ Action: UIAlertAction)
    {
        switch Action.title
        {
            case "Delete Session":
                let FinalAlert = UIAlertController(title: "Really Delete This Session?",
                                                   message: "Do you really want to delete the selected session? This is non-recoverable.",
                                                   preferredStyle: .alert)
                FinalAlert.addAction(UIAlertAction(title: "Delete Session", style: .destructive, handler: DoDeleteSelectedSession(_:)))
                FinalAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(FinalAlert, animated: true)
            
            case "Delete All":
                let FinalAlert = UIAlertController(title: "Really Delete All Sessions?",
                                                   message: "Do you really want to delete all stored logging sessions? (The current logging session will not be deleted.) This is non-recoverable.",
                                                   preferredStyle: .alert)
                FinalAlert.addAction(UIAlertAction(title: "Delete All", style: .destructive, handler: DoDeleteEverything(_:)))
                FinalAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(FinalAlert, animated: true)
            
            default:
                break
        }
    }
    
    /// Delete all logs (other than the current log).
    /// - Parameter Action: Not used.
    @objc func DoDeleteEverything(_ Action: UIAlertAction)
    {
        PleaseWaitLayer.isHidden = false
        self.navigationItem.hidesBackButton = true
        for Session in SessionList
        {
            if Session.ID == Log.SessionID
            {
                //Not allowed to delete the current logging session.
                continue
            }
            Log.DeleteSession(Session.ID)
            Log.Message("Deleting log \(Session.ID.uuidString)")
        }
        PleaseWaitLayer.isHidden = true
        self.navigationItem.hidesBackButton = false
        LoadSessions()
        for Cell in SessionTable.visibleCells
        {
            Cell.setSelected(false, animated: true)
        }
        LoadSessions()
        SessionDataList.removeAll()
        SessionDataTable.reloadData()
    }
    
    /// Delete the currently selected session. The user is not allowed to delete the currently *used* log.
    /// - Parameter Action: Not used.
    @objc func DoDeleteSelectedSession(_ Action: UIAlertAction)
    {
        Log.Message("Deleting log \(CurrentSessionID)")
        if Log.DeleteSession(CurrentSessionID)
        {
            LoadSessions()
            for Cell in SessionTable.visibleCells
            {
                Cell.setSelected(false, animated: true)
            }
            LoadSessions()
            SessionDataList.removeAll()
            SessionDataTable.reloadData()
        }
    }
    
    /// Handle the export/share button pressed.
    /// - Note: If no log session is selected, this code should not be called.
    /// - Parameter sender: Not used.
    @IBAction func HandleExportButtonPressed(_ sender: Any)
    {
        let AlertView = UIAlertController(title: "Export Log",
                                          message: "Export the selected log.",
                                          preferredStyle: .alert)
        AlertView.addAction(UIAlertAction(title: "Export", style: .default, handler: GetExportType(Action:)))
        AlertView.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(AlertView, animated: true)
    }
    
    /// Get the export type from the user. Run export code once the type is selected.
    @objc func GetExportType(Action: UIAlertAction)
    {
        let AlertView = UIAlertController(title: "Select Export Type",
                                          message: "Select the type the data will be exported as.",
                                          preferredStyle: .alert)
        AlertView.addAction(UIAlertAction(title: "SQLite", style: .default, handler: HandleExportType(Action:)))
        AlertView.addAction(UIAlertAction(title: "XML", style: .default, handler: HandleExportType(Action:)))
        AlertView.addAction(UIAlertAction(title: "JSON", style: .default, handler: HandleExportType(Action:)))
        AlertView.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: HandleExportType(Action:)))
        self.present(AlertView, animated: true)
    }
    
    /// Handle the format type action.
    /// - Parameter Action: Determines the type the selected log is saved as.
    @objc func HandleExportType(Action: UIAlertAction)
    {
        switch Action.title
        {
            case "SQLite":
                DoExportSomething(As: .SQLite)
            
            case "XML":
                DoExportSomething(As: .XML)
            
            case "JSON":
                DoExportSomething(As: .JSON)
            
            case "Cancel":
                return
            
            default:
                return
        }
    }
    
    /// Export the currently selected log as the passed type. Runs the UIActivityView to let the user select where to save the data.
    /// - Parameter As: Determines the format of the exported log.
    func DoExportSomething(As: ExportTypes)
    {
        if let Session = Log.GetSession(CurrentSessionID)
        {
            Log.PopulateStructuredMessages(Session)
            ResultsToExport = Session.Export(As: As)
            var FileName = Session.SessionDate
            if !Session.Name.isEmpty && !Session.Name.IsAll(" ")
            {
                FileName = Session.Name
            }
            var Extension = ".txt"
            switch As
            {
                case .XML:
                    Extension = ".xml"
                
                case .JSON:
                    Extension = ".json"
                
                default:
                    break
            }
            FileName = FileName + Extension
            
            let FileURL = FileIO.SaveTextFile(With: ResultsToExport, FileName: FileName)
            let Items: [Any] = [FileURL]
            let ACV = UIActivityViewController(activityItems: Items, applicationActivities: nil)
            ACV.popoverPresentationController?.sourceView = self.view
            ACV.popoverPresentationController?.sourceRect = self.view.frame
            ACV.popoverPresentationController?.canOverlapSourceViewRect = true
            ACV.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.any
            ACV.completionWithItemsHandler =
                {
                    (type, completed, items, error) in
                    FileIO.DeleteFile(FileURL)
            }
            self.present(ACV, animated: true)
        }
    }
    
    var ResultsToExport: String = ""
    
    var ExportAs: ExportTypes = .Cancel
    
    @IBOutlet weak var PleaseWaitLayer: UIView!
    @IBOutlet weak var ExportButton: UIBarButtonItem!
    @IBOutlet weak var DeleteButton: UIBarButtonItem!
    @IBOutlet weak var SessionDataTable: UITableView!
    @IBOutlet weak var SessionTable: UITableView!
    @IBOutlet weak var ViewSessionButton: UIBarButtonItem!
}

