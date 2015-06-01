//
//  new_edit_search.swift
//  AnzeigenChef
//
//  Created by DerDaHinten on 01.06.15.
//  Copyright (c) 2015 Anon. All rights reserved.
//

import Cocoa

class new_edit_search: NSWindowController,NSTextFieldDelegate {

    @IBOutlet var menuname: NSTextField!
    @IBOutlet var searchactive: NSButton!
    @IBOutlet var postalcode: NSTextField!
    @IBOutlet var distance: NSComboBox!
    @IBOutlet var query: NSTextField!
    @IBOutlet var okbutton: NSButton!
    var catSel : catselector!
    @IBOutlet var catSelButton: NSButton!
    var mydb = dbfunc()
    var currentEditId = ""
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
    }
    
    convenience init(){
        self.init(windowNibName: "new_edit_search")
    }
    
    override func awakeFromNib() {
        distance.removeAllItems()
        distance.addItemWithObjectValue(NSLocalizedString("All", comment: "Show all search results"))
        distance.addItemWithObjectValue(NSLocalizedString("5 km", comment: "Show 5km"))
        distance.addItemWithObjectValue(NSLocalizedString("10 km", comment: "Show 10km"))
        distance.addItemWithObjectValue(NSLocalizedString("20 km", comment: "Show 20km"))
        distance.addItemWithObjectValue(NSLocalizedString("30 km", comment: "Show 30km"))
        distance.addItemWithObjectValue(NSLocalizedString("50 km", comment: "Show 50km"))
        distance.addItemWithObjectValue(NSLocalizedString("100 km", comment: "Show 100km"))
        distance.addItemWithObjectValue(NSLocalizedString("150 km", comment: "Show 150km"))
        distance.addItemWithObjectValue(NSLocalizedString("200 km", comment: "Show 200km"))
        distance.selectItemAtIndex(0)
        self.catSelButton.toolTip = ""
 
        
        if (self.currentEditId != ""){
            var ndata = self.mydb.sql_read_select("SELECT * FROM searchquery WHERE id='" + self.currentEditId + "'")
            catSelButton.toolTip = ndata[0]["category"]!
            catSelButton.title = ndata[0]["category_text"]!
            query.stringValue = ndata[0]["query"]!
            postalcode.stringValue = ndata[0]["ziporcity"]!
            menuname.stringValue = ndata[0]["desc"]!
            
            let dist : String = ndata[0]["distance"]!
            
            // 0 is already selected
            if dist == "5" {
                distance.selectItemAtIndex(1)
            } else if dist == "10" {
                distance.selectItemAtIndex(2)
            } else if dist == "20" {
                distance.selectItemAtIndex(3)
            } else if dist == "30" {
                distance.selectItemAtIndex(4)
            } else if dist == "50" {
                distance.selectItemAtIndex(5)
            } else if dist == "100" {
                distance.selectItemAtIndex(6)
            } else if dist == "150" {
                distance.selectItemAtIndex(7)
            } else if dist == "200" {
                distance.selectItemAtIndex(8)
            } else {
                distance.selectItemAtIndex(0)
            }
            
            if ndata[0]["active"]! == "1" {
                self.searchactive.state = NSOnState
            } else {
                self.searchactive.state = NSOffState
            }
            
            self.checkup()
        }
    }
    
    @IBAction func okaction(sender: AnyObject) {
        
        
        if (self.currentEditId != ""){
            var sqlarray : NSMutableArray = []
            sqlarray.addObject("category='" + self.catSelButton.toolTip! + "'")
            sqlarray.addObject("query=" + self.mydb.quotedstring(self.query.stringValue))
            sqlarray.addObject("desc=" + self.mydb.quotedstring(self.menuname.stringValue))
            sqlarray.addObject("ziporcity=" + self.mydb.quotedstring(self.postalcode.stringValue))
            
            if distance.indexOfSelectedItem == 0 {
                sqlarray.addObject("distance=0")
            } else if distance.indexOfSelectedItem == 1 {
                sqlarray.addObject("distance=5")
            } else if distance.indexOfSelectedItem == 2 {
                sqlarray.addObject("distance=10")
            } else if distance.indexOfSelectedItem == 3 {
                sqlarray.addObject("distance=20")
            } else if distance.indexOfSelectedItem == 4 {
                sqlarray.addObject("distance=30")
            } else if distance.indexOfSelectedItem == 5 {
                sqlarray.addObject("distance=50")
            } else if distance.indexOfSelectedItem == 6 {
                sqlarray.addObject("distance=100")
            } else if distance.indexOfSelectedItem == 7 {
                sqlarray.addObject("distance=150")
            } else if distance.indexOfSelectedItem == 8 {
                sqlarray.addObject("distance=200")
            } else {
                sqlarray.addObject("distance=0")
            }
            
            if self.searchactive.state == NSOnState {
                sqlarray.addObject("active=1")
            } else {
                sqlarray.addObject("active=0")
            }
            
            if self.mydb.executesql("UPDATE searchquery SET " + sqlarray.componentsJoinedByString(", ") + " WHERE id=" + self.currentEditId) {
                self.window?.sheetParent?.endSheet(self.window!, returnCode: NSModalResponseOK)
            } else {
                println("NO!")
            }
            
        } else {
            var sqlarray : NSMutableArray = []
            var sqlstart = "INSERT INTO searchquery (category,query,desc,ziporcity,distance,active) VALUES ("
            sqlarray.addObject(self.mydb.quotedstring(self.catSelButton.toolTip!))
            sqlarray.addObject(self.mydb.quotedstring(self.query.stringValue))
            sqlarray.addObject(self.mydb.quotedstring(self.menuname.stringValue))
            sqlarray.addObject(self.mydb.quotedstring(self.postalcode.stringValue))
            
            if distance.indexOfSelectedItem == 0 {
                sqlarray.addObject("0")
            } else if distance.indexOfSelectedItem == 1 {
                sqlarray.addObject("5")
            } else if distance.indexOfSelectedItem == 2 {
                sqlarray.addObject("10")
            } else if distance.indexOfSelectedItem == 3 {
                sqlarray.addObject("20")
            } else if distance.indexOfSelectedItem == 4 {
                sqlarray.addObject("30")
            } else if distance.indexOfSelectedItem == 5 {
                sqlarray.addObject("50")
            } else if distance.indexOfSelectedItem == 6 {
                sqlarray.addObject("100")
            } else if distance.indexOfSelectedItem == 7 {
                sqlarray.addObject("150")
            } else if distance.indexOfSelectedItem == 8 {
                sqlarray.addObject("200")
            } else {
                sqlarray.addObject("0")
            }
            
            if self.searchactive.state == NSOnState {
                sqlarray.addObject("1")
            } else {
                sqlarray.addObject("0")
            }
            
            if self.mydb.executesql(sqlstart + sqlarray.componentsJoinedByString(", ") + ")") {
                self.currentEditId = String(self.mydb.lastId())
                self.window?.sheetParent?.endSheet(self.window!, returnCode: NSModalResponseOK)
            } else {
                println("NO!")
            }
        }
        
        
        
    }
    
    @IBAction func cancelaction(sender: AnyObject) {
        self.window?.sheetParent?.endSheet(self.window!, returnCode: NSModalResponseCancel)
    }
    
    @IBAction func selectcataction(sender: AnyObject) {
        if (self.catSel == nil) {
            self.catSel = catselector();
        }
        
        self.window!.beginSheet(self.catSel.window!, completionHandler: {(returnCode) -> Void in
            if (returnCode == NSModalResponseOK){
                self.catSelButton.toolTip = self.catSel.selid
                self.catSelButton.title = self.catSel.selpath
                self.checkup()
            }
        });
    }
    
    override func controlTextDidChange(obj: NSNotification){
        self.checkup()
    }
    
    func checkup(){
        if (menuname.stringValue != "" && postalcode.stringValue != "" && query.stringValue != "" && self.catSelButton.toolTip != "" && distance.indexOfSelectedItem >= 0){
            okbutton.enabled = true
        } else {
            okbutton.enabled = false
        }
    }
}
