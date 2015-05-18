//
//  catselector.swift
//  AnzeigenChef
//
//  Created by DerDaHinten on 18.05.15.
//  Copyright (c) 2015 Anon. All rights reserved.
//

import Cocoa

class catselector: NSWindowController {
    var catdata : NSDictionary = ["name" : "root", "id" : "0"]

    @IBOutlet var catlisttable: NSOutlineView!
    @IBOutlet var okButton: NSButton!
    
    override func windowDidLoad() {
        super.windowDidLoad()
    }
    
    convenience init(){
        self.init(windowNibName: "catselector")
    }
    
    override func awakeFromNib() {
        let documents = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        let path = documents.stringByAppendingPathComponent("ebaykats.ini")
        
        if (NSFileManager.defaultManager().fileExistsAtPath(path))
        {
            self.catdata = NSDictionary(contentsOfFile: path)!
        } else {
            let alert = NSAlert()
            alert.messageText = NSLocalizedString("No categoryfile found, please sync your accounts", comment: "NoAccounts")
            alert.addButtonWithTitle(NSLocalizedString("OK", comment: "OK Button"))
            alert.alertStyle = NSAlertStyle.CriticalAlertStyle
            let result = alert.runModal()
        }
        
        self.catlisttable.reloadData()
        if(self.catlisttable.itemAtRow(0) != nil){
           self.catlisttable.expandItem(self.catlisttable.itemAtRow(0))
        }
        
        
    }
    
    @IBAction func okbuttonAction(sender: AnyObject) {
        self.window?.sheetParent?.endSheet(self.window!, returnCode: NSModalResponseOK)
        
    }
    
    @IBAction func cancelAction(sender: AnyObject) {
        self.window?.sheetParent?.endSheet(self.window!, returnCode: NSModalResponseCancel)
    }
    
    func outlineView(outlineView: NSOutlineView, selectionIndexesForProposedSelection proposedSelectionIndexes: NSIndexSet) -> NSIndexSet{
        self.okButton.enabled = false
        if (proposedSelectionIndexes.count>0){
            let n : NSDictionary = self.catlisttable.itemAtRow(proposedSelectionIndexes.firstIndex) as! NSDictionary
            if (n["children"] != nil){
                if ((n["children"] as! NSArray).count==0){
                    self.okButton.enabled = true
                }
            } else {
                self.okButton.enabled = true
            }
        }
        return proposedSelectionIndexes
    }
    
    
    func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        if (item == nil){
            return self.catdata
        } else {
            return ((item as! NSDictionary)["children"] as! NSArray).objectAtIndex(index)
        }
    }
    
    func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
        if let it = item as? NSDictionary {
            if (it["children"] != nil){
                if (it["children"] as! NSArray).count > 0 {
                    return true
                }
            }
        }
        return false
    }
    
    func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
        if let it = item as? NSDictionary {
            if (it["children"] != nil){
                if (it["children"] as! NSArray).count > 0 {
                    return (it["children"] as! NSArray).count
                }
            }
        }
        return 1
    }
    
    func outlineView(outlineView: NSOutlineView, objectValueForTableColumn tableColumn: NSTableColumn?, byItem item: AnyObject?) -> AnyObject?{
        if let it = item as? NSDictionary {
            if (it == catdata) {
                return NSLocalizedString("Categories", comment: "CatselDesc")
            } else {
                return it["name"]
            }
        }
        return nil
    }
    
}
