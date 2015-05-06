//
//  setup.swift
//  AnzeigenChef
//
//  Created by DerDaHinten on 02.05.15.
//  Copyright (c) 2015 Anon. All rights reserved.
//

import Cocoa

class setup: NSWindowController,NSTableViewDataSource,NSTableViewDelegate {

    var setupAccount : setup_account!
    @IBOutlet var accountTable: NSTableView!
    @IBOutlet var deleteButton: NSButton!
    
    var dataArray : [[String : String]] = []
    var currentSelection = 0;
    
    override func windowDidLoad() {
        self.loaddata()
        super.windowDidLoad()
    }
    
    convenience init(){
        self.init(windowNibName: "setup");
    }


    func loaddata(){
        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        var mydb = dbfunc()
        dataArray = mydb.sql_read_accounts("");
    }
    
    
    
    //MARK: Accounts Table
    func numberOfRowsInTableView(aTableView: NSTableView) -> Int
    {
        let numberOfRows:Int = dataArray.count;
        return numberOfRows;
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject?
    {
        if (tableColumn?.identifier == "username"){
            return dataArray[row]["username"]
        }
        if (tableColumn?.identifier == "platform"){
            var returnStr = ""
            if (dataArray[row]["platform"] == "1"){
                returnStr = "eBay Kleinanzeigen"
            }
            if (dataArray[row]["platform"] == "2"){
                returnStr = "Quoka"
            }
            return returnStr
        }
        
        return "";
    }
    
    func tableView(tableView: NSTableView, selectionIndexesForProposedSelection proposedSelectionIndexes: NSIndexSet) -> NSIndexSet{
        if (proposedSelectionIndexes.count>0) {
            let i = proposedSelectionIndexes.firstIndex
            currentSelection = i;
            self.deleteButton.enabled=true
        } else {
            currentSelection = -1;
            self.deleteButton.enabled=false
        }
        return proposedSelectionIndexes
    }
    
    //MARK: Buttons
    @IBAction func addAccount(sender: AnyObject) {
        if (self.setupAccount == nil) {
            self.setupAccount = setup_account(windowNibName: "setup_account");
        }
        
        self.window!.beginSheet(self.setupAccount.window!, completionHandler: {(returnCode) -> Void in
            if (returnCode == NSModalResponseOK){
                
                // First check
                var l = httpcl()
                if (l.check_ebay_account(self.setupAccount.txt_username.stringValue, password: self.setupAccount.txt_password.stringValue)) {
                    var mydb = dbfunc();
                    let aType:String = toString(self.setupAccount.txt_accounttype.selectedItem!.tag)
                    mydb.executesql("INSERT INTO accounts (username,password,platform) VALUES ('"+self.setupAccount.txt_username.stringValue+"','"+self.setupAccount.txt_password.stringValue+"','"+aType+"')")
                    self.loaddata()
                    self.accountTable.reloadData()
                } else {
                    let myPopup: NSAlert = NSAlert()
                    myPopup.messageText = "Fail"
                    myPopup.informativeText = "Verify account fails"
                    myPopup.alertStyle = NSAlertStyle.WarningAlertStyle
                    myPopup.addButtonWithTitle("OK")
                    let res = myPopup.runModal()
                }
            }
            self.setupAccount = nil;
        });
        
    }
    
    @IBAction func deleteAccount(sender: AnyObject) {
        var mydb = dbfunc();
        mydb.executesql("DELETE FROM accounts WHERE id='"+dataArray[currentSelection]["id"]!+"'")
        self.loaddata()
        self.accountTable.reloadData()
    }
    
    @IBAction func saveAndClose(sender: AnyObject) {
        self.window?.sheetParent?.endSheet(self.window!, returnCode: NSModalResponseOK)
    }
    
    
}
