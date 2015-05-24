//
//  AppDelegate.swift
//  AnzeigenChef
//
//  Created by DerDaHinten on 02.05.15.
//  Copyright (c) 2015 Anon. All rights reserved.
//

import Cocoa
import Foundation

// GLOBAL DB!
var db: COpaquePointer = nil



@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSOutlineViewDataSource, NSOutlineViewDelegate,NSMenuDelegate,NSTableViewDataSource,NSTableViewDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var catlist: NSOutlineView!
    @IBOutlet weak var catpopup: NSMenu!
    @IBOutlet weak var itemstableview: NSTableView!
    @IBOutlet weak var progressBar: NSProgressIndicator!
    @IBOutlet weak var currentFolderLabel: NSTextField!
    @IBOutlet weak var messControl: MessageControl!
    @IBOutlet weak var syncButton: NSToolbarItem!
    
    
    var my_new_edit_ebay : new_edit_ebay!
    var mydb = dbfunc()
    var myhttpcl = httpcl()
    var setupControl : setup!
    var folderControl : foldercontroller!
    var katDataArray : [[String : String]] = []
    var tableDataArray : NSArray = []
    var catlastclickrow : Int = -1
    var currentFolderID : Int = -8
    var syncinprocess : Bool = false
    var currentFilter = ""
    
    private let kNodesPBoardType = "myNodesPBoardType"
    private var dragNodesArray: [catitem] = []
    dynamic private var contents: [AnyObject] = []
    
 
    var firstCatItem : catitem = catitem(cname: NSBundle.mainBundle().infoDictionary!["CFBundleName"] as! String, cid: "0", cimg: "", istemplate:false, cparent : NSApp, cgroup : true)
    var templateCatItem : catitem!
    
    //MARK: Application
    func applicationShouldHandleReopen(sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool{
        window.makeKeyAndOrderFront(sender)
        return true;
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        mydb.opendb();
        let selk : catitem = self.addcat("Activ", myid: "-9", myimg : "NSStatusAvailable", cparent: firstCatItem, is_template:false);
        self.addcat("Inactive", myid: "-7", myimg : "NSStatusPartiallyAvailable", cparent: firstCatItem, is_template:false);
        self.addcat("Stopped", myid: "-8", myimg : "NSStatusUnavailable", cparent: firstCatItem, is_template:false);
        self.templateCatItem = self.addcat("Templates", myid: "-10", myimg: "NSFolder", cparent: firstCatItem, is_template:false);
        self.itemstableview.doubleAction = Selector("edit:")
        self.loadCats()
        self.catlist.setDataSource(self)
        self.catlist.reloadData()
        self.catlist.expandItem(firstCatItem);
        self.catlist.registerForDraggedTypes([kNodesPBoardType])
        self.catlist.setDelegate(self)
        self.catlist.selectRowIndexes(NSIndexSet(index: catlist.rowForItem(selk)), byExtendingSelection: true)
        self.currentFolderLabel.stringValue = selk.get_catname()
        self.currentFolderID = -9
        self.load_data("folder=-9")
        // self.syncbutton(self)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        
    }
    
    override func awakeFromNib() {
        
    }
    
    
    
  
    
    
    func menuNeedsUpdate(menu: NSMenu){
        
        catpopup.itemWithTag(1)?.enabled=false
        catpopup.itemWithTag(2)?.enabled=false
        catpopup.itemWithTag(3)?.enabled=false
        catpopup.itemWithTag(4)?.enabled=false
        
        let clickedRow = catlist.clickedRow
        catlastclickrow = clickedRow
        if (clickedRow > -1){
            let clickedItem : catitem = catlist.itemAtRow(clickedRow) as! catitem
            if (clickedItem.istemplate()){
                catpopup.itemWithTag(1)?.enabled=true
                catpopup.itemWithTag(2)?.enabled=true
                catpopup.itemWithTag(3)?.enabled=true
                catpopup.itemWithTag(4)?.enabled=true
            }
            if (clickedItem.get_catid().toInt() == -10){
                catpopup.itemWithTag(1)?.enabled=true
            }
        }
    }
    
    override func validateMenuItem(menuItem: NSMenuItem) -> Bool {
        if menuItem.action == Selector("edit:") {
            if (self.itemstableview.selectedRow > -1){
                return true
            } else {
                return false
            }
        }
        
        
        if menuItem.action == Selector("deactivate:") && menuItem.tag == 876 {
            if (self.currentFolderID == -9 && self.itemstableview.selectedRow > -1){
                return true
            } else {
                return false
            }
        }
        
        if menuItem.action == Selector("deactivate:") && menuItem.tag == 877 {
            if (self.currentFolderID == -7 && self.itemstableview.selectedRow > -1){
                return true
            } else {
                return false
            }
        }
        
        if menuItem.action == Selector("stopad:") {
            if ((self.currentFolderID == -9 || self.currentFolderID == -7) && self.itemstableview.selectedRow > -1){
                return true
            } else {
                return false
            }
        }
        
        if menuItem.action == Selector("sendNow:") {
            if ((self.currentFolderID == -10 || self.currentFolderID > 0) && self.itemstableview.selectedRow > -1){
                return true
            } else {
                return false
            }
        }
        
        return menuItem.enabled
    }
    
    override func validateToolbarItem(theItem: NSToolbarItem) -> Bool {
        if theItem.action == Selector("syncbutton:") {
            if syncinprocess {
                return false
            } else {
                return true
            }
        }
        
        if theItem.action == Selector("deactivate:") && theItem.tag == 876 {
            if (self.currentFolderID == -9 && self.itemstableview.selectedRow > -1){
                return true
            } else {
                return false
            }
        }
        
        if theItem.action == Selector("deactivate:") && theItem.tag == 877 {
            if (self.currentFolderID == -7 && self.itemstableview.selectedRow > -1){
                return true
            } else {
                return false
            }
        }
        
        if theItem.action == Selector("stopad:") {
            if ((self.currentFolderID == -9 || self.currentFolderID == -7) && self.itemstableview.selectedRow > -1){
                return true
            } else {
                return false
            }
        }
        
        if theItem.action == Selector("sendNow:") {
            if ((self.currentFolderID == -10 || self.currentFolderID > 0) && self.itemstableview.selectedRow > -1){
                return true
            } else {
                return false
            }
        }
        
        return theItem.enabled
    }
    
    //MARK: Outline
    func outlineView(outlineView: NSOutlineView, isGroupItem item: AnyObject) -> Bool{
        if let it = item as? catitem {
            return it.isgroup()
        }
        return false
    }
    
    func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        if let it = item as? catitem {
            return it.childAtIndex(index)
        } else {
            return self.firstCatItem;
        }
    }
    
    func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
        if let it = item as? catitem {
            if it.getChildCount() > 0 {
                return true
            } else {
                return false
            }
        } else {
            return true
        }
    }
    
    func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
        if let it = item as? catitem {
            return it.getChildCount()
        }
        return 1
    }
    
    func outlineView(outlineView: NSOutlineView, objectValueForTableColumn tableColumn: NSTableColumn?, byItem item: AnyObject?) -> AnyObject?{
        if let it = item as? catitem {
            return it.get_catname()
        }
        return nil
    }
    
    func outlineView(outlineView: NSOutlineView, viewForTableColumn tableColumn: NSTableColumn?, item: AnyObject) -> NSView?{
        if let it = item as? catitem {
            let cell = outlineView.makeViewWithIdentifier("catcellident", owner: self) as! NSTableCellView!
            cell?.textField!.stringValue = it.get_catname()
            if (!(it.getCatImage() as NSString).isEqualToString("")){
                cell?.imageView?.image = NSImage(named: it.getCatImage())
            } else {
                cell?.imageView?.image = nil;
            }
            return cell;
        }
        return nil;
    }
    
    func outlineView(outlineView: NSOutlineView, selectionIndexesForProposedSelection proposedSelectionIndexes: NSIndexSet) -> NSIndexSet{
        if (proposedSelectionIndexes.count>0){
            let n : catitem = self.catlist.itemAtRow(proposedSelectionIndexes.firstIndex) as! catitem
            self.currentFolderLabel.stringValue = n.get_catname()
            self.currentFolderID = n.get_catid().toInt()!
            self.load_data("folder="+String(self.currentFolderID))
        }
        return proposedSelectionIndexes
    }
    
    func addcat(myname : String, myid : String, myimg : String, cparent: catitem, is_template : Bool) -> catitem{
        var child1 : catitem = catitem(cname: myname, cid: myid, cimg : myimg, istemplate:is_template, cparent : cparent, cgroup: false)
        cparent.addChild(child1)
        return child1
    }
    
    
   
    
    
    //MARK: TableView
    func numberOfRowsInTableView(tableView: NSTableView) -> Int{
        return tableDataArray.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject?{
        if (tableDataArray.count-1 >= row){
            let nsdic : [String : String] = tableDataArray.objectAtIndex(row) as! [String : String]
            let fieldName : String = tableColumn!.identifier!
            let cstr = nsdic[fieldName]
            if (cstr != nil){
                var retval : String = nsdic[fieldName]!
                if (fieldName == "pricetype"){
                    if nsdic[fieldName]! == "1"{
                        retval = NSLocalizedString("Fixedprice", comment: "PriceType FixedPrice")
                    } else if nsdic[fieldName]! == "2" {
                        retval = NSLocalizedString("Deal", comment: "PriceType Deal")
                    } else {
                        retval = NSLocalizedString("Give away", comment: "PriceType GiveAway")
                    }
                }
                if (fieldName == "price"){
                    retval += ",00"
                }
                return retval
            }
        }
        return ""
    }
    
    func tableView(tableView: NSTableView, selectionIndexesForProposedSelection proposedSelectionIndexes: NSIndexSet) -> NSIndexSet{
        if (proposedSelectionIndexes.count>0){
            let n : [String : String] = tableDataArray.objectAtIndex(proposedSelectionIndexes.firstIndex) as! [String : String]
            let this_itemid : String = n["itemid"]!
            self.messControl.loadData("adid='"+this_itemid+"' ORDER BY receiveddate DESC")
        }
        return proposedSelectionIndexes
    }
    
    
  
    
    
    
    //MARK: CatList DragDROP!
    func outlineView(outlineView: NSOutlineView, writeItems items: [AnyObject], toPasteboard pasteboard: NSPasteboard) -> Bool{
        let mutableArray : NSMutableArray = NSMutableArray()
        dragNodesArray.removeAll(keepCapacity: false)
        
        for object : AnyObject in items{
            if (object is catitem ) {
                if (!(object as! catitem).istemplate() || (object as! catitem).get_catid() == "-10" ) {
                    return false
                }
                mutableArray.addObject((object as! catitem).get_catid())
                dragNodesArray.append(object as! catitem)
            }
        }
        
        let data : NSData = NSKeyedArchiver.archivedDataWithRootObject(mutableArray)
        pasteboard.setData(data, forType: kNodesPBoardType)
        
        return true
    }
    
    func outlineView(outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: AnyObject?, proposedChildIndex index: Int) -> NSDragOperation
    {
        var result = NSDragOperation.None
        
        // if nil?
        if (item == nil) {
            return result
        }
        
        // if no templatefolder and not templatemainfolder
        if (!(item as! catitem).istemplate() && (item as! catitem).get_catid() != "-10" ) {
            return result
        }
        
        // no dragnodes?
        if (dragNodesArray.count<=0) {
            return result
        }
        
        // if same node
        if (dragNodesArray[0].isEqual(item)){
            return result
        }
        
 
        
        // check, if node the parent?
        var mycheckitem = (item as! catitem)
        while mycheckitem.get_catid() != "-10"{
            if (mycheckitem.isEqual(dragNodesArray[0])){
                return result
            }
            mycheckitem = mycheckitem.get_parent()
        }

        result = .Move
        return result
    }

    func outlineView(outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: AnyObject?, childIndex index: Int) -> Bool {
        if (self.mydb.executesql("UPDATE folders SET folderparentid='"+(item as! catitem).get_catid()+"' WHERE id="+(dragNodesArray[0] as catitem).get_catid())){
            (dragNodesArray[0] as catitem).get_parent().removeChild((dragNodesArray[0] as catitem))
            (item as! catitem).addChild((dragNodesArray[0] as catitem))
            (dragNodesArray[0] as catitem).set_parent((item as! catitem))
            catlist.reloadData()
            catlist.selectRowIndexes(NSIndexSet(index:catlist.rowForItem((dragNodesArray[0] as catitem))), byExtendingSelection: true)
            
            return true
        }
        return false
    }
    
    
    
    //MARK: Buttons
    @IBAction func showSetup(sender: NSMenuItem){
        if (self.setupControl == nil) {
           self.setupControl = setup(windowNibName: "setup");
        }
        
        self.window!.beginSheet(self.setupControl.window!, completionHandler: {(returnCode) -> Void in
            if (returnCode == NSModalResponseOK){
                
            }
        });
        
        /*
        self.setupControl.window!.center()
        self.setupControl.window!.makeKeyAndOrderFront(self.setupControl.window!)
        */
    }
    // End ShowSetup ******
    
    
    @IBAction func syncbutton(sender: AnyObject) {
        self.syncinprocess = true
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            // cats done?
            var catsdone = false
            // get accounts
            var dataArray : [[String : String]] = self.mydb.sql_read_accounts("")
            // setup visual progress
            self.progressBar.maxValue = Double(dataArray.count)
            self.progressBar.doubleValue = 0
            self.progressBar.startAnimation(self)
            // move all running items to stopped
            self.mydb.executesql("UPDATE items SET folder=-8 WHERE folder=-9")
            
            for var i=0; i<dataArray.count; ++i{
                self.progressBar.doubleValue = Double(i)
                self.progressBar.startAnimation(self)
                let uname : String = dataArray[i]["username"]!
                let upass : String = dataArray[i]["password"]!
                
                // Logout
                self.myhttpcl.logout_ebay_account()
                
                // Login
                let isok : Bool = self.myhttpcl.check_ebay_account(uname, password: upass)
                if (isok == false){
                    println("Login für " + uname + " nicht möglich :( ")
                    continue
                }
                
                // Login ok, load cats
                if (catsdone == false){
                    let documents = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
                    let path = documents.stringByAppendingPathComponent("ebaykats.ini")
                    let m = httpcl()
                    let catdata : NSDictionary = m.getcats_ebay()
                    catdata.writeToFile(path, atomically: true)
                    catsdone = true
                }
                
                // get items
                let thelist : NSArray = self.myhttpcl.shortlist_ebay_account(uname, password: upass)
                
                // get conversations
                let conv : NSArray = self.myhttpcl.conversation_ebay(uname, password: upass)
 
                self.progressBar.maxValue = Double(thelist.count+conv.count)
                self.progressBar.doubleValue = 0
                
                for var ii=0; ii<thelist.count; ++ii{
                    self.progressBar.doubleValue+=1
                    if let ditem = thelist[ii] as? NSDictionary {
                        let cditem = self.fixdicttostrings(ditem)
                        var sqlstr : String = "INSERT OR IGNORE INTO items (account,itemid) VALUES (";
                        sqlstr += dataArray[i]["id"]! + ","
                        sqlstr += self.mydb.quotedstring(cditem["id"]) + ")"
                        if (self.mydb.executesql(sqlstr)){
                            var sqlstr : String = "UPDATE items SET ";
                            sqlstr += "category="+self.mydb.quotedstring(cditem["category"]) + ","
                             
                            var dateFormatter = NSDateFormatter()
                            dateFormatter.dateFormat = "dd.MM.yyyy"
                            let date = dateFormatter.dateFromString(cditem["endDate"] as! String)
                            dateFormatter.dateFormat = "yyyy-MM-dd"
                            var endDate = dateFormatter.stringFromDate(date!)
                            sqlstr += "enddate="+self.mydb.quotedstring(endDate) + ","
                            
                            sqlstr += "viewcount="+self.mydb.quotedstring(cditem["viewCount"]) + ","
                            sqlstr += "watchcount="+self.mydb.quotedstring(cditem["watchCount"]) + ","
                            sqlstr += "state="+self.mydb.quotedstring(cditem["state"]) + ","
                            sqlstr += "seourl="+self.mydb.quotedstring(cditem["seoUrl"]) + ","
                            sqlstr += "shippingprovided="+self.mydb.quotedstring(cditem["shippingProvided"]) + ","
                            
                            // details
                            let detailData = self.myhttpcl.get_ad_details(cditem["id"] as! String)
                            if (detailData["ad_title"] != nil){
                                sqlstr += "title=" + self.mydb.quotedstring(detailData["ad_title"]) + ","
                            }
                            
                            if (detailData["ad_description"] != nil){
                                sqlstr += "desc=" + self.mydb.quotedstring(detailData["ad_description"]) + ","
                            }
                            
                            if (detailData["ad_postalcode"] != nil){
                                sqlstr += "postalcode=" + self.mydb.quotedstring(detailData["ad_postalcode"]) + ","
                            }
                            
                            if (detailData["ad_street"] != nil){
                                sqlstr += "street=" + self.mydb.quotedstring(detailData["ad_street"]) + ","
                            }
                            
                            if (detailData["ad_myname"] != nil){
                                sqlstr += "myname=" + self.mydb.quotedstring(detailData["ad_myname"]) + ","
                            }
                            
                            if (detailData["ad_myphone"] != nil){
                                sqlstr += "myphone=" + self.mydb.quotedstring(detailData["ad_myphone"]) + ","
                            }
                            
                            if (detailData["ad_pricetype"] != nil){
                                sqlstr += "pricetype=" + self.mydb.quotedstring(detailData["ad_pricetype"]) + ","
                            }
                            
                            if (detailData["ad_price"] != nil){
                                sqlstr += "price=" + self.mydb.quotedstring(detailData["ad_price"]) + ","
                            }
                            
                            if (detailData["ad_type"] != nil){
                                sqlstr += "adtype=" + self.mydb.quotedstring(detailData["ad_type"]) + ","
                            }
                            
                            if (detailData["ad_category"] != nil){
                                sqlstr += "categoryId=" + self.mydb.quotedstring(detailData["ad_category"]) + ","
                            }

                            if (detailData["imglist"] != nil){
                                let imglist : NSMutableArray = detailData["imglist"]! as! NSMutableArray
                                var incer = 1
                                for var i = 0; i < imglist.count; ++i {
                                    if incer == 1 {
                                        sqlstr += "image" + "=" + self.mydb.quotedstring(imglist[i]) + ","
                                    } else {
                                        sqlstr += "image" + String(incer) + "=" + self.mydb.quotedstring(imglist[i]) + ","
                                    }
                                    ++incer
                                }
                                while incer < 20 {
                                    if incer == 1 {
                                        sqlstr += "image" + "='',"
                                    } else {
                                        sqlstr += "image" + String(incer) + "='',"
                                    }
                                    ++incer
                                }
                            }
                            sqlstr += "folder=-9 WHERE itemid="+self.mydb.quotedstring(cditem["id"])
                            self.mydb.executesql(sqlstr)
                        }
                    }
                }
                // end
                
                // now conversations to db..
                for var ii=0; ii<conv.count; ++ii{
                    self.progressBar.doubleValue+=1
                    if let ditem = conv[ii] as? NSDictionary {
                        let cditem = self.fixdicttostrings(ditem)
                        var sqlstr : String = "INSERT OR IGNORE INTO conversations (account,adtitle,adstatus,adimage,email,cid,buyername,sellername,adid,role,unread,textshort,boundness,receiveddate,negotiationenabled) VALUES (";
                        sqlstr += dataArray[i]["id"]! + ","
                        sqlstr += self.mydb.quotedstring(cditem["adTitle"]) + ","
                        sqlstr += self.mydb.quotedstring(cditem["adStatus"]) + ","
                        sqlstr += self.mydb.quotedstring(cditem["adImage"]) + ","
                        sqlstr += self.mydb.quotedstring(cditem["email"]) + ","
                        sqlstr += self.mydb.quotedstring(cditem["id"]) + ","
                        sqlstr += self.mydb.quotedstring(cditem["buyerName"]) + ","
                        sqlstr += self.mydb.quotedstring(cditem["sellerName"] ) + ","
                        sqlstr += self.mydb.quotedstring(cditem["adId"]) + ","
                        sqlstr += self.mydb.quotedstring(cditem["role"]) + ","
                        sqlstr += self.mydb.quotedstring(cditem["unread"]) + ","
                        sqlstr += self.mydb.quotedstring(cditem["textShortTrimmed"]) + ","
                        sqlstr += self.mydb.quotedstring(cditem["boundness"]) + ","
                        if (cditem["receivedDate"] != nil){
                            var date = NSDate(timeIntervalSince1970: (cditem["receivedDate"] as! NSString).doubleValue/1000)
                            var dateFormatter = NSDateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                            var receivedDate = dateFormatter.stringFromDate(date)
                            sqlstr += self.mydb.quotedstring(receivedDate) + ","
                        }
                        sqlstr += self.mydb.quotedstring(cditem["negotiationEnabled"])+")"
                        if (self.mydb.executesql(sqlstr)){
                            var sqlstr : String = "UPDATE conversations SET ";
                            sqlstr += "unread="+self.mydb.quotedstring(cditem["unread"])
                            sqlstr += " WHERE cid="+self.mydb.quotedstring(cditem["id"])
                            self.mydb.executesql(sqlstr)
                        }
                        
                        // Get messagedetails...
                        let conv_messages : NSArray = self.myhttpcl.conversation_detail_ebay(uname, password: upass, cid: cditem["id"] as! String)
                        for var iii=0; iii<conv_messages.count; ++iii{
                            if let convitem = conv_messages[iii] as? NSDictionary {
                                let cdconvitem = self.fixdicttostrings(convitem)
                                var sqlstr : String = "INSERT OR IGNORE INTO conversations_text (account, textshort, textshorttrimmed, boundness, type, receiveddate, attachments, cid, unread) VALUES ("
                                sqlstr += dataArray[i]["id"]! + ","
                                sqlstr += self.mydb.quotedstring(cdconvitem["textShort"]) + ","
                                sqlstr += self.mydb.quotedstring(cdconvitem["textShortTrimmed"]) + ","
                                sqlstr += self.mydb.quotedstring(cdconvitem["boundness"]) + ","
                                sqlstr += self.mydb.quotedstring(cdconvitem["type"]) + ","
                                if (cdconvitem["receivedDate"] != nil){
                                    var date = NSDate(timeIntervalSince1970: (cdconvitem["receivedDate"] as! NSString).doubleValue/1000)
                                    var dateFormatter = NSDateFormatter()
                                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                    var receivedDate = dateFormatter.stringFromDate(date)
                                    sqlstr += self.mydb.quotedstring(receivedDate) + ","
                                }
                                
                                var attachStr = ""
                                if  let new_attachments = conv_messages[iii]["attachments"] as? NSArray {
                                    for var ai=0; ai<new_attachments.count; ++ai{
                                        let new_attachments_item = self.fixdicttostrings(new_attachments[ai] as! NSDictionary)
                                        if new_attachments_item["format"] as! String == "image/jpeg" {
                                            attachStr += "<img src=\"" + (new_attachments_item["url"] as! String) + "\" height=120><br/><br/>"
                                        }
                                    }
                                }
                                
                                sqlstr += self.mydb.quotedstring(attachStr) + ","
                                sqlstr += self.mydb.quotedstring(cditem["id"]) + ","
                                if (cditem["unread"] as! NSString).isEqualToString("true"){
                                    sqlstr += "'1'"
                                } else {
                                    sqlstr += "'0'"
                                }
                                sqlstr += ")"
                                if (self.mydb.executesql(sqlstr)){
                                    // OK?
                                }
                            }
                        }
                    }
                }
                // end
            }
            
            
            
            dispatch_async(dispatch_get_main_queue()) {
                self.progressBar.doubleValue = 0
                self.progressBar.stopAnimation(self)
                if (self.currentFolderID == -9){
                    self.load_data("folder=-9")
                }
                self.syncinprocess = false
            }
            
            
        }
    }
    
    
    func fixdicttostrings(oldDic : NSDictionary) -> NSMutableDictionary{
        var newDic : NSMutableDictionary = NSMutableDictionary.new()
        for (key, value) in oldDic {
            // checkVal
            var newval : String = ""
            if (value is NSNumber){
                newval = (value as AnyObject?)!.stringValue
            } else if(value is Bool){
                if (value as! Bool){
                    newval = "true"
                } else {
                    newval = "false"
                }
            } else if(value is String) {
                newval = value as! String
            } else {
                newval = ""
            }
            newDic.setObject(newval, forKey: key as! String)
        }
        return newDic
    }
    
    func add(sender: NSMenuItem){
        self.my_new_edit_ebay = nil
        self.my_new_edit_ebay = new_edit_ebay(windowNibName: "new_edit_ebay");
        self.my_new_edit_ebay.currentfolder = self.currentFolderID
        if (self.my_new_edit_ebay.currentfolder<=0 && self.my_new_edit_ebay.currentfolder != -10){
            self.my_new_edit_ebay.currentfolder = -10
        }
        
        self.window!.beginSheet(self.my_new_edit_ebay.window!, completionHandler: {(returnCode) -> Void in
            if (returnCode == NSModalResponseOK){
                self.load_data(self.currentFilter)
            }
        });
    }
    
    
    @IBAction func edit(sender: AnyObject) {
        if self.itemstableview.selectedRow<0 { return }
        self.my_new_edit_ebay = nil
        self.my_new_edit_ebay = new_edit_ebay(windowNibName: "new_edit_ebay");
        
        let nsdic : [String : String] = self.tableDataArray.objectAtIndex(self.itemstableview.selectedRowIndexes.firstIndex) as! [String : String]
        
        self.my_new_edit_ebay.currentfolder = self.currentFolderID
        self.my_new_edit_ebay.editId = nsdic["id"]!
        
        self.window!.beginSheet(self.my_new_edit_ebay.window!, completionHandler: {(returnCode) -> Void in
            if (returnCode == NSModalResponseOK){
                self.load_data(self.currentFilter)
            }
        });
    }
    
    
    @IBAction func deactivate(sender: AnyObject) {
        let selx = itemstableview.selectedRowIndexes.toArray()
        for var i=0; i<selx.count; ++i{
            let nsdic : [String : String] = self.tableDataArray.objectAtIndex(selx[i]) as! [String : String]
            let current_account : String = nsdic["account"]!
            let current_item : String = nsdic["itemid"]!
            let current_state : String = nsdic["state"]!
            var dowa = ""
            
            var dataArray : [[String : String]] = self.mydb.sql_read_accounts("id=" + current_account)
            if (dataArray.count>0){
                self.myhttpcl.logout_ebay_account()
                if (self.myhttpcl.check_ebay_account(dataArray[0]["username"]!, password: dataArray[0]["password"]!)){
                    
                    if current_state == "active" {
                        dowa = "paused"
                    } else {
                        dowa = "active"
                    }
                    
                    self.myhttpcl.get_ad_details(current_item)
                    /*
                    if (self.myhttpcl.pause_ad_ebay(current_item, whatDo: dowa)){
                        self.mydb.executesql("UPDATE items SET state='"+dowa+"' WHERE itemid='"+current_item+"' AND account='"+current_account+"'")
                        if (dowa == "paused"){
                            self.mydb.executesql("UPDATE items SET folder='-7' WHERE itemid='"+current_item+"' AND account='"+current_account+"'")
                        } else {
                            self.mydb.executesql("UPDATE items SET folder='-9' WHERE itemid='"+current_item+"' AND account='"+current_account+"'")
                        }
                    } else {
                        println(current_item + " not " + dowa)
                    }
                    */
                }
            }
        }
        self.load_data(currentFilter)
    }
    
    
    @IBAction func stopad(sender: AnyObject) {
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("Are you sure you want to delete the selected ads?", comment: "Delete message...")
        alert.informativeText = NSLocalizedString("Deleted ads cannot resume", comment: "Delete message header...")
        alert.addButtonWithTitle(NSLocalizedString("Yes", comment: "Alert yes"))
        alert.addButtonWithTitle(NSLocalizedString("No", comment: "Alert no"))
        alert.alertStyle = NSAlertStyle.WarningAlertStyle
        let result = alert.runModal()
        switch(result) {
        case NSAlertFirstButtonReturn:
            let selx = itemstableview.selectedRowIndexes.toArray()
            for var i=0; i<selx.count; ++i{
                let nsdic : [String : String] = self.tableDataArray.objectAtIndex(selx[i]) as! [String : String]
                let current_account : String = nsdic["account"]!
                let current_item : String = nsdic["itemid"]!
                let current_state : String = nsdic["state"]!
                
                var dataArray : [[String : String]] = self.mydb.sql_read_accounts("id=" + current_account)
                if (dataArray.count>0){
                    self.myhttpcl.logout_ebay_account()
                    if (self.myhttpcl.check_ebay_account(dataArray[0]["username"]!, password: dataArray[0]["password"]!)){
                        
                        if (self.myhttpcl.stop_ad_ebay(current_item)){
                            self.mydb.executesql("UPDATE items SET state='stopped', folder='-8' WHERE itemid='"+current_item+"' AND account='"+current_account+"'")
                            self.load_data(currentFilter)
                        } else {
                            println(current_item + " not stopped")
                        }
                        
                    }
                }
            }
        case NSAlertSecondButtonReturn:
            return
        default:
            break
        }
    }
    
    
    
    @IBAction func sendNow(sender: AnyObject) {
        let selx = itemstableview.selectedRowIndexes.toArray()
        for var i=0; i<selx.count; ++i{
            let nsdic : [String : String] = self.tableDataArray.objectAtIndex(selx[i]) as! [String : String]
            let current_account : String = nsdic["account"]!
            let current_id : String = nsdic["id"]!
            
            var dataArray : [[String : String]] = self.mydb.sql_read_accounts("id=" + current_account)
            if (dataArray.count>0){
                self.myhttpcl.logout_ebay_account()
                if (self.myhttpcl.check_ebay_account(dataArray[0]["username"]!, password: dataArray[0]["password"]!)){
                    
                    let ok = self.myhttpcl.addItem(nsdic)
                    if (ok){
                        self.syncbutton(self)
                        let alert = NSAlert()
                        alert.messageText = NSLocalizedString("Your ad will be visible in two minutes.", comment: "Visible Message")
                        alert.informativeText = NSLocalizedString("Listing success!", comment: "Listing success")
                        alert.addButtonWithTitle(NSLocalizedString("OK", comment: "OK Button"))
                        alert.alertStyle = NSAlertStyle.InformationalAlertStyle
                        let result = alert.runModal()
                    } else {
                        let alert = NSAlert()
                        alert.informativeText = self.myhttpcl.lastError
                        alert.messageText = NSLocalizedString("Listing fails!", comment: "Listing fails")
                        alert.addButtonWithTitle(NSLocalizedString("OK", comment: "OK Button"))
                        alert.alertStyle = NSAlertStyle.CriticalAlertStyle
                        let result = alert.runModal()
                    }
                }
            }
        }
        self.load_data(currentFilter)
    }
    
    
    
    
    //MARK:CatPopUp actions
    @IBAction func addFolderAction(sender: AnyObject) {
        
        self.folderControl = nil
        self.folderControl = foldercontroller(windowNibName: "foldercontroller");
        
        self.folderControl.currentData = ""
        
        self.window!.beginSheet(self.folderControl.window!, completionHandler: {(returnCode) -> Void in
            if (returnCode == NSModalResponseOK){
                if (self.catlastclickrow > -1){
                    
                    
                    let currentitem = self.catlist.itemAtRow(self.catlastclickrow) as! catitem
                    if (self.mydb.executesql("INSERT INTO folders (foldername,folderparentid) VALUES ('"+self.folderControl.folderNameEdit.stringValue+"','"+String(currentitem.get_catid())+"')")){
                        self.addcat(self.folderControl.folderNameEdit.stringValue, myid: String(self.mydb.lastId()), myimg: "NSFolder", cparent: currentitem, is_template: true)
                        self.catlist.reloadItem(currentitem, reloadChildren: true)
                        self.catlist.expandItem(currentitem)
                    }
                }
            }
        });
        
        
    }
    
    @IBAction func renameFolderAction(sender: AnyObject) {
        if (self.catlastclickrow < 0){
            return
        }
        
        let currentitem = self.catlist.itemAtRow(self.catlastclickrow) as! catitem
        
        self.folderControl = nil
        self.folderControl = foldercontroller(windowNibName: "foldercontroller");
        
        
        self.folderControl.currentData = currentitem.get_catname()
        
        
        self.window!.beginSheet(self.folderControl.window!, completionHandler: {(returnCode) -> Void in
            if (returnCode == NSModalResponseOK){
                if (self.mydb.executesql("UPDATE folders SET foldername='"+self.folderControl.folderNameEdit.stringValue+"' WHERE id="+currentitem.get_catid())){
                    currentitem.set_catname(self.folderControl.folderNameEdit.stringValue)
                    self.catlist.reloadDataForRowIndexes(NSIndexSet(index: self.catlastclickrow), columnIndexes: NSIndexSet(index: 0))
                }
            }
        });
        
    }
    
    @IBAction func deleteFolderAction(sender: AnyObject) {
        if (self.catlastclickrow < 0){
            return
        }
        
        let currentitem = self.catlist.itemAtRow(self.catlastclickrow) as! catitem
        
        
        if (!currentitem.get_parent().isEqual(currentitem)){
            self.mydb.executesql("DELETE FROM folders WHERE id="+currentitem.get_catid())
            self.catdelete(currentitem.get_catid())
            currentitem.get_parent().removeChild(currentitem)
            self.catlist.reloadData()
        }
    }
    
    //MARK:DB CAT
    func loadCats(){
        let ldata = mydb.sql_read_folders("folderparentid='-10'")
        for var i=0; i<ldata.count; ++i{
            let newcat = self.addcat(ldata[i]["foldername"]!, myid: ldata[i]["id"]!, myimg: "NSFolder", cparent: templateCatItem, is_template: true)
            loadChilds(newcat)
        }
        // AB jetzt Schleife, bis nix mehr kommt
    }
    
    func loadChilds(fromCat : catitem){
        let ldata = mydb.sql_read_folders("folderparentid='"+fromCat.get_catid()+"'")
        for var i=0; i<ldata.count; ++i{
            let newcat = self.addcat(ldata[i]["foldername"]!, myid: ldata[i]["id"]!, myimg: "NSFolder", cparent: fromCat, is_template: true)
            self.loadChilds(newcat)
        }
    }
    
    func catdelete(which : String){
        let ldata = mydb.sql_read_folders("folderparentid='"+which+"'")
        for var i=0; i<ldata.count; ++i{
            self.mydb.executesql("DELETE FROM folders WHERE id="+ldata[i]["id"]!)
            self.catdelete(ldata[i]["id"]!)
        }
    }
    
    //MARK:DB Items
    func load_data(filterStr : String){
        self.currentFilter = filterStr
        var newFilter = "SELECT * FROM items"
        if (filterStr != "") {
            newFilter += " WHERE " + filterStr
        }
        tableDataArray = self.mydb.sql_read_select(newFilter)
        itemstableview.reloadData()
        let itemtext : String = NSLocalizedString("Items", comment: "Quantity of items in current view")
        var newWinTitle = NSBundle.mainBundle().infoDictionary!["CFBundleName"] as! String + " "
        newWinTitle += NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String
        newWinTitle += " (" + String(tableDataArray.count) + " " + itemtext + ")"
        self.window.title = newWinTitle
        if (tableDataArray.count>0){
            self.tableView(itemstableview, selectionIndexesForProposedSelection: NSIndexSet(index: 0))
        } else {
            self.messControl.resetAll()
        }
    }


}

