//
//  new_edit_ebay.swift
//  AnzeigenChef
//
//  Created by DerDaHinten on 14.05.15.
//  Copyright (c) 2015 Anon. All rights reserved.
//

import Cocoa

class new_edit_ebay: NSWindowController {
    
    var editId = ""
    var currentfolder : Int = -10
    var mydb = dbfunc()
    var dataArray : NSArray = []
    var catSel : catselector!
    var picsel : picselect!
    var imglist : NSMutableArray = []

    @IBOutlet var catSelButton: NSButton!
    @IBOutlet var adType: NSMatrix!
    @IBOutlet var adTitle: NSTextField!
    
    @IBOutlet var adPrice: NSTextField!
    @IBOutlet var adDesc: NSTextView!
    
    @IBOutlet var adPriceType: NSMatrix!
    @IBOutlet var adPostalCode: NSTextField!
    @IBOutlet var adStreet: NSTextField!
    
    @IBOutlet var adPhone: NSTextField!
    @IBOutlet var adYourName: NSTextField!
    
    @IBOutlet var listAccount: NSComboBox!
    @IBOutlet var okButton: NSButton!
    
    
    override func windowDidLoad() {
        super.windowDidLoad()
    }
    
    override func awakeFromNib() {
        dataArray = mydb.sql_read_accounts("")
        self.listAccount.removeAllItems()
        for var i=0; i<dataArray.count; ++i{
            let accName : String = dataArray[i]["username"] as! String
            self.listAccount.addItemWithObjectValue(accName)
        }
        if (dataArray.count>0) {
            self.listAccount.selectItemAtIndex(0)
        }
    }
    
    convenience init(){
        self.init(windowNibName: "new_edit_ebay")
    }
    
    @IBAction func selectCatAction(sender: AnyObject) {
        if (self.catSel == nil) {
            self.catSel = catselector();
        }
        
        self.window!.beginSheet(self.catSel.window!, completionHandler: {(returnCode) -> Void in
            if (returnCode == NSModalResponseOK){
                self.catSelButton.toolTip = self.catSel.selid
                self.catSelButton.title = self.catSel.selpath
            }
        });
        
    }
    
    
    @IBAction func cancelAction(sender: AnyObject) {
        self.window?.sheetParent?.endSheet(self.window!, returnCode: NSModalResponseCancel)
    }
    
    @IBAction func selectPicButton(sender: AnyObject) {
        if (self.picsel == nil) {
            self.picsel = picselect();
        }
        self.window!.beginSheet(self.picsel.window!, completionHandler: {(returnCode) -> Void in
            if (returnCode == NSModalResponseOK){
                self.imglist.removeAllObjects()
                if (self.picsel.pic1.getmyfile() != ""){
                    self.imglist.addObject(self.picsel.pic1.getmyfile())
                }
                if (self.picsel.pic2.getmyfile() != ""){
                    self.imglist.addObject(self.picsel.pic2.getmyfile())
                }
                if (self.picsel.pic3.getmyfile() != ""){
                    self.imglist.addObject(self.picsel.pic3.getmyfile())
                }
                if (self.picsel.pic4.getmyfile() != ""){
                    self.imglist.addObject(self.picsel.pic4.getmyfile())
                }
                if (self.picsel.pic5.getmyfile() != ""){
                    self.imglist.addObject(self.picsel.pic5.getmyfile())
                }
                if (self.picsel.pic6.getmyfile() != ""){
                    self.imglist.addObject(self.picsel.pic6.getmyfile())
                }
                if (self.picsel.pic7.getmyfile() != ""){
                    self.imglist.addObject(self.picsel.pic7.getmyfile())
                }
                if (self.picsel.pic8.getmyfile() != ""){
                    self.imglist.addObject(self.picsel.pic8.getmyfile())
                }
                if (self.picsel.pic9.getmyfile() != ""){
                    self.imglist.addObject(self.picsel.pic9.getmyfile())
                }
                if (self.picsel.pic10.getmyfile() != ""){
                    self.imglist.addObject(self.picsel.pic10.getmyfile())
                }
                if (self.picsel.pic11.getmyfile() != ""){
                    self.imglist.addObject(self.picsel.pic11.getmyfile())
                }
                if (self.picsel.pic12.getmyfile() != ""){
                    self.imglist.addObject(self.picsel.pic12.getmyfile())
                }
                if (self.picsel.pic13.getmyfile() != ""){
                    self.imglist.addObject(self.picsel.pic13.getmyfile())
                }
                if (self.picsel.pic14.getmyfile() != ""){
                    self.imglist.addObject(self.picsel.pic14.getmyfile())
                }
                if (self.picsel.pic15.getmyfile() != ""){
                    self.imglist.addObject(self.picsel.pic15.getmyfile())
                }
                if (self.picsel.pic16.getmyfile() != ""){
                    self.imglist.addObject(self.picsel.pic16.getmyfile())
                }
                if (self.picsel.pic17.getmyfile() != ""){
                    self.imglist.addObject(self.picsel.pic17.getmyfile())
                }
                if (self.picsel.pic18.getmyfile() != ""){
                    self.imglist.addObject(self.picsel.pic18.getmyfile())
                }
                if (self.picsel.pic19.getmyfile() != ""){
                    self.imglist.addObject(self.picsel.pic19.getmyfile())
                }
                if (self.picsel.pic20.getmyfile() != ""){
                    self.imglist.addObject(self.picsel.pic20.getmyfile())
                }
            }
        });
    }
    
    
    @IBAction func okAction(sender: AnyObject) {
        
        // Check fields
        var infoArray : NSMutableArray = []
        if (self.catSelButton.toolTip == ""){
            infoArray.addObject(NSLocalizedString("Category is empty", comment: "Category empty?"))
        }
        
        if (self.adTitle.stringValue == ""){
            infoArray.addObject(NSLocalizedString("Title is empty", comment: "Title empty?"))
        }
        
        if (self.adDesc.string == ""){
            infoArray.addObject(NSLocalizedString("Description is empty", comment: "Description empty?"))
        }
        
        if (self.adPrice.stringValue == "" && self.adPriceType.selectedRow<2){
            infoArray.addObject(NSLocalizedString("Price is empty", comment: "Price empty?"))
        }
        
        if (self.adYourName.stringValue == ""){
            infoArray.addObject(NSLocalizedString("Your name is empty", comment: "Your name empty?"))
        }
        
        if (infoArray.count>0){
            let errFieldList : String = infoArray.componentsJoinedByString("\n")
            let alert = NSAlert()
            alert.messageText = NSLocalizedString("Please fill the following fields", comment: "FieldsNeedHeader")
            alert.informativeText = errFieldList
            alert.addButtonWithTitle(NSLocalizedString("OK", comment: "OK Button"))
            alert.alertStyle = NSAlertStyle.WarningAlertStyle
            let result = alert.runModal()
            return
        }
        
        var sqlStr = ""
        let selectedAccount = dataArray[self.listAccount.indexOfSelectedItem]["id"] as! String
        
        // Build PIC String
        var picstringupdate = ""
        var picstringnewfields = ""
        var picstringnew = ""
        var currentimagename = ""
        for var i = 0; i<self.imglist.count; ++i{
            if (i==0){
                currentimagename = "image"
            } else {
                currentimagename = "image" + String(i+1)
            }
            if (picstringupdate == ""){
                picstringupdate = currentimagename + "=" + self.mydb.quotedstring(self.imglist[i])
            } else {
                picstringupdate += "," + currentimagename + "=" + self.mydb.quotedstring(self.imglist[i])
            }
            picstringnewfields += "," + currentimagename
            picstringnew += ", " + self.mydb.quotedstring(self.imglist[i])
        }
        
        // Build SQL
        if (self.editId == ""){
            sqlStr = "INSERT INTO items (account, state, price, title, category, categoryId, shippingprovided, folder, adtype, attribute, pricetype, postalcode, street, myname, myphone, desc\(picstringnewfields)) VALUES ("
            sqlStr += "'" + selectedAccount + "',"
            sqlStr += "'template',"
            sqlStr += "'" + String(format:"%f", self.adPrice.doubleValue) + "',"
            sqlStr += self.mydb.quotedstring(self.adTitle.stringValue) + ","
            sqlStr += self.mydb.quotedstring(self.catSelButton.title) + ","
            sqlStr += self.mydb.quotedstring(self.catSelButton.toolTip) + ","
            sqlStr += "0," // shipping provided?
            sqlStr += "'" + String(self.currentfolder) + "',"
            
            if (adType.selectedRow == 0){
                sqlStr += "0,"
            } else {
                sqlStr += "1,"
            }
            
            sqlStr += "''," // attribute?
            
            if (adPriceType.selectedRow == 0){
                sqlStr += "1,"
            } else if adPriceType.selectedRow == 1 {
                sqlStr += "2,"
            } else {
                sqlStr += "3,"
            }
            
            sqlStr += self.mydb.quotedstring(self.adPostalCode.stringValue) + ","
            sqlStr += self.mydb.quotedstring(self.adStreet.stringValue) + ","
            sqlStr += self.mydb.quotedstring(self.adYourName.stringValue) + ","
            sqlStr += self.mydb.quotedstring(self.adPhone.stringValue) + ","
            sqlStr += self.mydb.quotedstring(self.adDesc.string) 
            sqlStr += "\(picstringnew))"
            
            if self.mydb.executesql(sqlStr){
                self.editId = String(self.mydb.lastId())
                println("Gespeichert: " + self.editId)
                self.window?.sheetParent?.endSheet(self.window!, returnCode: NSModalResponseOK)
            } else {
                // SHOW FAIL!
            }
        } else {
            
        }
        
        
        
    }
}
