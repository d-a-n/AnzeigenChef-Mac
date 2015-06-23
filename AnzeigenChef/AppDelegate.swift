//
//  AppDelegate.swift
//  AnzeigenChef
//
//  Created by DerDaHinten on 02.05.15.
//  Copyright (c) 2015 Anon. All rights reserved.
//  http://www.customicondesign.com/free-icons/flatastic-icon-set/flatastic-part-8/

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
    var tableDataArray : NSMutableArray = []
    var catlastclickrow : Int = -1
    var currentFolderID : Int = -8
    var currentFolderParentID : Int = 0
    var currentcatitemobj : catitem!
    var syncinprocess : Bool = false
    var currentFilter = ""
    var cat_start_expandlist : NSMutableArray = []
    var searchCat : catitem!
    var my_new_edit_search : new_edit_search!
 
    
    private let kNodesPBoardType = "myNodesPBoardType"
    private let kRowPBoardType = "myRowsPBoardType"
    private var dragNodesArray: [catitem] = []
    private var dragRowsArray: [String] = [] // ids!
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
        self.itemstableview.registerForDraggedTypes([kRowPBoardType])
        self.loadCats()
        
        searchCat = self.addcat("Search", myid: "-5", myimg: "NSQuickLookTemplate", cparent: firstCatItem, is_template: false)
        self.loadSearch()
        self.updateCatCount()
        
        
        self.catlist.setDataSource(self)
        self.catlist.reloadData()
        self.catlist.expandItem(firstCatItem)
        self.catlist.expandItem(templateCatItem)
        self.catlist.expandItem(searchCat)
        self.catlist.registerForDraggedTypes([kNodesPBoardType,kRowPBoardType])
        self.catlist.setDelegate(self)
        self.catlist.selectRowIndexes(NSIndexSet(index: catlist.rowForItem(selk)), byExtendingSelection: true)
        self.currentFolderLabel.stringValue = selk.get_catname()
        self.currentFolderID = -9
        self.load_data("folder=-9")
        
        for var i=0; i < cat_start_expandlist.count; ++i {
            self.catlist.expandItem(cat_start_expandlist[i])
        }
        
        cat_start_expandlist.removeAllObjects()
        
        // self.syncbutton(self)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        
    }
    
    
   
    
    
    override func validateMenuItem(menuItem: NSMenuItem) -> Bool {
        self.catlastclickrow = catlist.clickedRow
        
        if menuItem.action == Selector("addFolderAction:") {
            if (self.catlastclickrow > -1){
                let clickedItem : catitem = catlist.itemAtRow(self.catlastclickrow) as! catitem
                if (clickedItem.istemplate() || clickedItem.get_catid() == "-10" ){
                    return true
                } else {
                    return false
                }
            } else {
                return false
            }
        }
        
        if menuItem.action == Selector("renameFolderAction:") {
            if (self.catlastclickrow > -1){
                let clickedItem : catitem = catlist.itemAtRow(self.catlastclickrow) as! catitem
                if (clickedItem.istemplate()){
                    return true
                } else {
                    return false
                }
            } else {
                return false
            }
        }
        
        if menuItem.action == Selector("editSearch:") {
            if (self.catlastclickrow > 0){
                let clickedItem : catitem = catlist.itemAtRow(self.catlastclickrow) as! catitem
                if (clickedItem.get_parent().get_catid() == "-5"){
                    return true
                } else {
                    return false
                }
            } else {
                return false
            }
        }
        
        if menuItem.action == Selector("deleteFolderAction:") {
            if (self.catlastclickrow > -1){
                let clickedItem : catitem = catlist.itemAtRow(self.catlastclickrow) as! catitem
                if (clickedItem.istemplate() || clickedItem.get_parent().get_catid() == "-5"){
                    return true
                } else {
                    return false
                }
            } else {
                return false
            }
        }
        
        if menuItem.action == Selector("edit:") {
            if (self.itemstableview.selectedRow > -1 && self.currentFolderParentID != -5){
                return true
            } else {
                return false
            }
        }
        
        if menuItem.action == Selector("duplicateAction:") {
            if (self.itemstableview.selectedRow > -1 && self.currentFolderParentID != -5){
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
            if ((self.currentFolderID == -10 || self.currentFolderID > 0) && self.itemstableview.selectedRow > -1 && self.currentFolderParentID != -5){
                return true
            } else {
                return false
            }
        }
        
        if menuItem.action == Selector("printFlyerAction:") {
            if ((self.currentFolderID == -9) && self.itemstableview.selectedRow > -1){
                return true
            } else {
                return false
            }
        }
        
        if menuItem.action == Selector("delete:") {
            if ((self.currentFolderID == -10 || self.currentFolderID > 0 || self.currentFolderID == -8) && self.itemstableview.selectedRow > -1 && self.currentFolderParentID != -5){
                return true
            } else {
                return false
            }
        }
        
        if menuItem.action == Selector("showOnlineAction:") {
            if (((self.currentFolderID < 0 && self.currentFolderID != -10) || currentFolderParentID == -5) && self.itemstableview.selectedRow > -1){
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
        
        if theItem.action == Selector("duplicateAction:") {
            if (self.itemstableview.selectedRow > -1 && self.currentFolderParentID != -5){
                return true
            } else {
                return false
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
        
        if theItem.action == Selector("printFlyerAction:") {
            if ((self.currentFolderID == -9 ) && self.itemstableview.selectedRow > -1){
                return true
            } else {
                return false
            }
        }
        
        if theItem.action == Selector("sendNow:") {
            if (self.currentFolderID == -9){
                theItem.label = "Update now"
            } else {
                theItem.label = "Send now"
            }
            
            if ((self.currentFolderID == -10 || self.currentFolderID > 0 || self.currentFolderID == -9) && self.itemstableview.selectedRow > -1 && self.currentFolderParentID != -5){
                return true
            } else {
                return false
            }
        }
        
        if theItem.action == Selector("delete:") {
            if ((self.currentFolderID == -10 || self.currentFolderID > 0 || self.currentFolderID == -8) && self.itemstableview.selectedRow > -1 && self.currentFolderParentID != -5){
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
            self.currentFolderParentID = n.get_parent().get_catid().toInt()!
            self.currentcatitemobj = n;
            self.load_data("folder="+String(self.currentFolderID))
        }
        return proposedSelectionIndexes
    }
    
    func addcat(myname : String, myid : String, myimg : String, cparent: catitem, is_template : Bool) -> catitem{
        var gr = false
        if myimg == "NSQuickLookTemplate" {
            gr = true
        }
        var child1 : catitem = catitem(cname: myname, cid: myid, cimg : myimg, istemplate:is_template, cparent : cparent, cgroup: gr)
        cparent.addChild(child1)
        return child1
    }
    
    func outlineView(outlineView: NSOutlineView, shouldExpandItem item: AnyObject) -> Bool {
        if let it = item as? catitem {
            self.mydb.executesql("UPDATE folders SET expand=1 WHERE id=" + (item as! catitem).get_catid())
        }
        return true
    }
   
    func outlineView(outlineView: NSOutlineView, shouldCollapseItem item: AnyObject) -> Bool {
        if let it = item as? catitem {
            self.mydb.executesql("UPDATE folders SET expand=0 WHERE id=" + (item as! catitem).get_catid())
        }
        return true
    }
    
    
    //MARK: TableView
    func numberOfRowsInTableView(tableView: NSTableView) -> Int{
        return tableDataArray.count
    }
    
    
    func tableView(tableView: NSTableView, selectionIndexesForProposedSelection proposedSelectionIndexes: NSIndexSet) -> NSIndexSet{
        if (proposedSelectionIndexes.count>0){
            var n : [String : String] = tableDataArray.objectAtIndex(proposedSelectionIndexes.firstIndex) as! [String : String]
            
            if self.currentFolderParentID == -5 && n["messageunread"]! == "1" {
                self.mydb.executesql("UPDATE searchqueryurls SET messageunread=0 WHERE id=" + n["id"]!)
                n["messageunread"] = "0"
                tableDataArray.replaceObjectAtIndex(proposedSelectionIndexes.firstIndex, withObject: n)
                tableView.reloadDataForRowIndexes(NSIndexSet(index: proposedSelectionIndexes.firstIndex), columnIndexes: NSIndexSet(index: 0))
                currentcatitemobj.reducecatcount()
                let oldSel : NSIndexSet = self.catlist.selectedRowIndexes
                self.catlist.reloadItem(self.searchCat, reloadChildren: true)
                self.catlist.selectRowIndexes(oldSel, byExtendingSelection: false)
            }
            
            let this_itemid : String = n["itemid"]!
            self.messControl.loadData("adid='"+this_itemid+"' ORDER BY receiveddate DESC")
        }
        return proposedSelectionIndexes
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView?{
        let cell = tableView.makeViewWithIdentifier("itemstablecell", owner: self) as! itemstablecell!
        let nsdic : [String : String] = tableDataArray.objectAtIndex(row) as! [String : String]
        
        cell.titleLabel.stringValue = nsdic["title"]!
        cell.descLabel.stringValue = nsdic["desc"]!
        cell.watchLabel.stringValue = nsdic["watchcount"]!
        cell.visitLabel.stringValue = nsdic["viewcount"]!
        cell.postalCodeLabel.stringValue = nsdic["postalcode"]!
        
        if (nsdic["image"] != ""){
            self.loadImage(nsdic["image"]!, myImage: cell.image)
        } else {
            cell.image.image = nil
        }
        
        if nsdic["pricetype"]! == "1"{
            cell.priceLabel.stringValue = nsdic["price"]! + " €"
        } else if nsdic["pricetype"]! == "2" {
            cell.priceLabel.stringValue = nsdic["price"]! + " € " + NSLocalizedString("VB", comment: "ItemsTable VB Label")
        } else {
            cell.priceLabel.stringValue = NSLocalizedString("Give away", comment: "ItemsTable GiveAway")
        }
        
        if nsdic["adtype"] == "1" {
            cell.priceLabel.stringValue = NSLocalizedString("Wanted", comment: "ItemsTable Wanted")
        }
        
        var messagecount : String = nsdic["messagecount"]!
        if (messagecount == ""){ messagecount = "0" }
        if messagecount.toInt() > 0 {
            cell.rightImage.image = NSImage(named: "Talk - Ellipses_48x48")
        } else if nsdic["messageunread"]! == "1" {
            cell.rightImage.image = NSImage(named: "Tag - Blue_48x48")
        } else {
            cell.rightImage.image = nil
        }
        
        return cell
    }
    
    func tableView(tableView: NSTableView, writeRowsWithIndexes rowIndexes: NSIndexSet, toPasteboard pboard: NSPasteboard) -> Bool {
        
        // no drag from outside of templates!
        if currentFolderID <= 0 && (currentFolderID > -10 || currentFolderID < -10) {
            return false
        }
        
        let mutableArray : NSMutableArray = NSMutableArray()
        dragRowsArray.removeAll(keepCapacity: false)
        
        let indexArray = rowIndexes.toArray()
        for var i=0; i < indexArray.count; ++i {
            let itemId = tableDataArray[indexArray[i]]["id"] as! String
            mutableArray.addObject(itemId)
            dragRowsArray.append(itemId)
        }
        
        let data : NSData = NSKeyedArchiver.archivedDataWithRootObject(mutableArray)
        pboard.setData(data, forType: kRowPBoardType)
        
        return true
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
        
        // drag come from tableview
        if (info.draggingSource() === self.itemstableview ) {
            if (item == nil) {
                result = .None
            } else {
                if (item as! catitem).get_catid().toInt() == -10 || (item as! catitem).get_catid().toInt() > 0 {
                    result = .Move
                } else {
                    result = .None
                }
            }
            return result
        }
        
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
        
        if (info.draggingSource() === self.itemstableview) {
            for var i=0; i < dragRowsArray.count; ++i {
                if (self.mydb.executesql("UPDATE items SET folder='"+(item as! catitem).get_catid()+"' WHERE id="+dragRowsArray[i])){
                    
                }
            }
            self.load_data(currentFilter)
            return true
        }
        
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
                        let accountid : String = dataArray[i]["id"]!
                        let itemid : String = cditem["id"]! as! String
                        
                        // check if exists
                        let checkCount = self.mydb.sql_read_select("SELECT COUNT(*) AS M FROM items WHERE itemid='" + itemid + "' AND account=" + accountid)
                        let foundItem : Bool = checkCount[0]["M"]?.toInt() > 0
                        
                        var sqlstr : String = "INSERT OR IGNORE INTO items (account,itemid) VALUES (";
                        sqlstr += dataArray[i]["id"]! + ","
                        sqlstr += self.mydb.quotedstring(cditem["id"]) + ")"
                        if (self.mydb.executesql(sqlstr)){
                            var sqlstr : String = "UPDATE items SET ";
                            sqlstr += "category="+self.mydb.quotedstring(cditem["category"]) + ","
                            
                            if cditem["endDate"] != nil {
                                var dateFormatter = NSDateFormatter()
                                dateFormatter.dateFormat = "dd.MM.yyyy"
                                let date = dateFormatter.dateFromString(cditem["endDate"] as! String)
                                dateFormatter.dateFormat = "yyyy-MM-dd"
                                var endDate = dateFormatter.stringFromDate(date!)
                                sqlstr += "enddate="+self.mydb.quotedstring(endDate) + ","
                            } else {
                                sqlstr += "enddate='',"
                            }
                            sqlstr += "viewcount="+self.mydb.quotedstring(cditem["viewCount"]) + ","
                            sqlstr += "watchcount="+self.mydb.quotedstring(cditem["watchCount"]) + ","
                            sqlstr += "state="+self.mydb.quotedstring(cditem["state"]) + ","
                            sqlstr += "seourl="+self.mydb.quotedstring(cditem["seoUrl"]) + ","
                            sqlstr += "shippingprovided="+self.mydb.quotedstring(cditem["shippingProvided"]) + ","
                            
                            // details
                            // only if not exists!
                            if (foundItem){
                                var folderNow = "-9"
                                if (cditem["state"] as! String == "paused"){
                                    folderNow = "-7"
                                }
                                sqlstr += "folder=\(folderNow) WHERE itemid="+self.mydb.quotedstring(cditem["id"])
                                self.mydb.executesql(sqlstr)
                            } else {
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
                                var folderNow = "-9"
                                if (cditem["state"] as! String == "paused"){
                                    folderNow = "-7"
                                }
                                sqlstr += "folder=\(folderNow) WHERE itemid="+self.mydb.quotedstring(cditem["id"])
                                self.mydb.executesql(sqlstr)
                            }
                            
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
                
                // Update Message Counts
                let mcountquery = self.mydb.sql_read_select("SELECT count(*) AS M, adid, account FROM conversations GROUP BY account,adid")
                for var m = 0; m < mcountquery.count; ++m {
                    let mdic = mcountquery[m]
                    let mdic_adid : String = mdic["adid"]!
                    let mdic_count : String = mdic["M"]!
                    let mdic_account : String = mdic["account"]!
                    self.mydb.executesql("UPDATE items SET messagecount='" + mdic_count + "' WHERE itemid='" + mdic_adid + "' AND account='" + mdic_account + "'")
                }
                // end
            }
            
            self.progressBar.doubleValue = 0
            self.progressBar.stopAnimation(self)
            
            dispatch_async(dispatch_get_main_queue()) {
                self.progressBar.doubleValue = 0
                self.progressBar.stopAnimation(self)
                if (self.currentFolderID == -9){
                    self.load_data("folder=-9")
                }
                self.catlist.reloadItem(self.searchCat, reloadChildren: true)
                self.syncinprocess = false
                
                self.sync_search()
            }
        }
        
        
        
    }
    
    func sync_search(){
        self.syncinprocess = true
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            var dataArray : [[String : String]] = self.mydb.sql_read_select("SELECT * FROM searchquery WHERE active=1")
            self.progressBar.maxValue = Double(dataArray.count)
            self.progressBar.doubleValue = 0
            for var i=0; i<dataArray.count; ++i {
                self.progressBar.doubleValue = self.progressBar.doubleValue + 1
                // self.mydb.executesql("DELETE FROM searchqueryurls WHERE searchquery_id=" + dataArray[i]["id"]!)
                let mdata : [[String : String]] = self.myhttpcl.get_search(dataArray[i])
                for var ii=0; ii<mdata.count; ++ii {
                    var sqlstr = "INSERT OR IGNORE INTO searchqueryurls (searchquery_id,image,title,seourl,desc,price,postalcode,pricetype,folder,messageunread) VALUES (" + dataArray[i]["id"]! + ","
                    sqlstr += self.mydb.quotedstring(mdata[ii]["image"]) + ","
                    sqlstr += self.mydb.quotedstring(mdata[ii]["title"]) + ","
                    sqlstr += self.mydb.quotedstring(mdata[ii]["url"]) + ","
                    sqlstr += self.mydb.quotedstring(mdata[ii]["desc"]) + ","
                    sqlstr += self.mydb.quotedstring(mdata[ii]["price"]) + ","
                    sqlstr += self.mydb.quotedstring(mdata[ii]["dist"]) + ","
                    sqlstr += self.mydb.quotedstring(mdata[ii]["pricetype"]) + ","
                    sqlstr += self.mydb.quotedstring(dataArray[i]["id"]!) + ",1)"
                    self.mydb.executesql(sqlstr)
                }
            }
        
            self.progressBar.doubleValue = 0
            self.progressBar.stopAnimation(self)
            
            dispatch_async(dispatch_get_main_queue()) {
                self.progressBar.doubleValue = self.progressBar.maxValue
                self.progressBar.stopAnimation(self)
                self.syncinprocess = false
                self.updateCatCount()
                self.catlist.reloadItem(self.searchCat, reloadChildren: true)
            }
        }
    }
    
    
    
    func loadImage(url:String, myImage: NSImageView) {
        let image_url:String = url.stringByAddingPercentEscapesUsingEncoding(NSASCIIStringEncoding)!
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            if let new_url : NSURL? = NSURL(string:image_url.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())) {
                var data:NSData?
                
                if url.contains("file:"){
                   data = NSData(contentsOfFile: new_url!.path! )
                } else {
                   data = NSData(contentsOfURL: new_url!)
                }
                
                var temppic : NSImage?
                if data == nil{
                    temppic = nil
                } else {
                    temppic = NSImage(data: data!)!
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    myImage.image = temppic
                }
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
 
    @IBAction func duplicateAction(sender: AnyObject){
        let selx = itemstableview.selectedRowIndexes.toArray()
        for var i=0; i<selx.count; ++i{
            let nsdic : [String : String] = self.tableDataArray.objectAtIndex(selx[i]) as! [String : String]
            let id = nsdic["id"]!
            self.mydb.executesql("DROP TABLE IF EXISTS tmp")
            self.mydb.executesql("CREATE TEMPORARY TABLE tmp AS SELECT * FROM items WHERE id="+id)
            if currentFolderID < 0 && currentFolderID != -10 {
                self.mydb.executesql("UPDATE tmp SET id = NULL, itemid = NULL, folder=-10, watchcount=0, viewcount=0, messageunread=0, messagecount=0")
            } else {
                self.mydb.executesql("UPDATE tmp SET id = NULL, itemid = NULL, watchcount=0, viewcount=0, messageunread=0, messagecount=0")
            }
            self.mydb.executesql("INSERT INTO items SELECT * FROM tmp")
        }
        if currentFolderID < 0 && currentFolderID != -10 {
            let alert = NSAlert()
            alert.messageText = NSLocalizedString("Ad is in templates now", comment: "Duplicate message...")
            alert.informativeText = NSLocalizedString("Duplicated ad moved", comment: "Duplicate message header...")
            alert.addButtonWithTitle(NSLocalizedString("OK", comment: "Alert OK"))
            alert.alertStyle = NSAlertStyle.WarningAlertStyle
            let result = alert.runModal()
        }
        self.load_data(self.currentFilter)
    }
    
    func delete(sender: NSMenuItem){
        let selx = itemstableview.selectedRowIndexes.toArray()
        for var i=0; i<selx.count; ++i{
            let nsdic : [String : String] = self.tableDataArray.objectAtIndex(selx[i]) as! [String : String]
            let id = nsdic["id"]!
            self.mydb.executesql("DELETE FROM items WHERE id=" + id)
        }
        self.load_data(self.currentFilter)
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
    
    @IBAction func addSearch(sender: AnyObject) {
        self.my_new_edit_search = nil
        self.my_new_edit_search = new_edit_search(windowNibName: "new_edit_search");
        
        self.window!.beginSheet(self.my_new_edit_search.window!, completionHandler: {(returnCode) -> Void in
            if (returnCode == NSModalResponseOK){
                self.addcat(self.my_new_edit_search.menuname.stringValue, myid: self.my_new_edit_search.currentEditId , myimg: "Tag - Blue_48x48", cparent: self.searchCat, is_template: false)
                self.catlist.reloadItem(self.searchCat, reloadChildren: true)
                self.catlist.expandItem(self.searchCat, expandChildren: true)
                self.sync_search()
            }
        });
    }
    
    
    @IBAction func edit(sender: AnyObject) {
        
        if self.itemstableview.selectedRow<0 { return }
        
        let nsdic : [String : String] = self.tableDataArray.objectAtIndex(self.itemstableview.selectedRowIndexes.firstIndex) as! [String : String]
        
        if (self.currentFolderParentID == -5){
            if nsdic["seourl"] != nil {
                var seourl : String = nsdic["seourl"]!
                seourl = "http://kleinanzeigen.ebay.de\(seourl)"
                NSWorkspace.sharedWorkspace().openURL(NSURL(string: seourl.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)!)
            } else {
                println(nsdic);
            }
            return
        }
        
        self.my_new_edit_ebay = nil
        self.my_new_edit_ebay = new_edit_ebay(windowNibName: "new_edit_ebay");
        self.my_new_edit_ebay.currentfolder = self.currentFolderID
        self.my_new_edit_ebay.editId = nsdic["id"]!
        
        self.window!.beginSheet(self.my_new_edit_ebay.window!, completionHandler: {(returnCode) -> Void in
            if (returnCode == NSModalResponseOK){
                self.load_data(self.currentFilter)
            }
        });
    }
    
    
    @IBAction func showOnlineAction(sender: AnyObject) {
        if self.itemstableview.selectedRow<0 { return }
        
        let nsdic : [String : String] = self.tableDataArray.objectAtIndex(self.itemstableview.selectedRowIndexes.firstIndex) as! [String : String]
        
        if (self.currentFolderParentID == -5){
            if nsdic["seourl"] != nil {
                var seourl : String = nsdic["seourl"]!
                seourl = "http://kleinanzeigen.ebay.de\(seourl)"
                NSWorkspace.sharedWorkspace().openURL(NSURL(string: seourl.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)!)
            } else {
                println(nsdic);
            }
            return
        }
        
        
        if nsdic["seourl"] != nil {
            var seourl : String = nsdic["seourl"]!
            seourl = "\(seourl)"
            NSWorkspace.sharedWorkspace().openURL(NSURL(string: seourl.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)!)
        }
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
                        } else {
                            println(current_item + " not stopped")
                        }
                        
                    }
                }
            }
            self.load_data(currentFilter)
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
            let current_itemid : String = nsdic["itemid"]!
            
            var dataArray : [[String : String]] = self.mydb.sql_read_accounts("id=" + current_account)
            if (dataArray.count>0){
                self.myhttpcl.logout_ebay_account()
                if (self.myhttpcl.check_ebay_account(dataArray[0]["username"]!, password: dataArray[0]["password"]!)){
                    
                    let ok = self.myhttpcl.addItem(nsdic)
                    if (ok){
                        if current_itemid != "" {
                            let alert = NSAlert()
                            alert.messageText = NSLocalizedString("Your ad has been updated.", comment: "AdUpdated Message")
                            alert.informativeText = NSLocalizedString("Update success!", comment: "Update success")
                            alert.addButtonWithTitle(NSLocalizedString("OK", comment: "OK Button"))
                            alert.alertStyle = NSAlertStyle.InformationalAlertStyle
                            let result = alert.runModal()
                        } else {
                            self.syncbutton(self)
                            let alert = NSAlert()
                            alert.messageText = NSLocalizedString("Your ad will be visible in two minutes.", comment: "Visible Message")
                            alert.informativeText = NSLocalizedString("Listing success!", comment: "Listing success")
                            alert.addButtonWithTitle(NSLocalizedString("OK", comment: "OK Button"))
                            alert.alertStyle = NSAlertStyle.InformationalAlertStyle
                            let result = alert.runModal()
                        }
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
    
    
    @IBAction func printFlyerAction(sender: AnyObject) {
        let selx = itemstableview.selectedRowIndexes.toArray()
        for var i=0; i<selx.count; ++i{
            let nsdic : [String : String] = self.tableDataArray.objectAtIndex(selx[i]) as! [String : String]
            let current_account : String = nsdic["account"]!
            let current_id : String = nsdic["id"]!
            
            var dataArray : [[String : String]] = self.mydb.sql_read_accounts("id=" + current_account)
            if (dataArray.count>0){
                self.myhttpcl.logout_ebay_account()
                if (self.myhttpcl.check_ebay_account(dataArray[0]["username"]!, password: dataArray[0]["password"]!)){
                    
                }
            }
        }
    }
    
    
    @IBAction func websiteButtonAction(sender: AnyObject) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "http://gastonx.net")!)
    }
    
    
    @IBAction func sourcecodeAction(sender: AnyObject) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "https://github.com/gastonx/AnzeigenChef-Mac")!)
    }
    
    
    //MARK:CatPopUp actions
    @IBAction func addFolderAction(sender: AnyObject) {

        self.catlastclickrow = self.catlist.clickedRow
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
        
        self.catlastclickrow = self.catlist.clickedRow
        
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
        
        if currentitem.get_parent().get_catid() == "-5" {
            self.mydb.executesql("DELETE FROM searchquery WHERE id="+currentitem.get_catid())
            self.mydb.executesql("DELETE FROM searchqueryurls WHERE searchquery_id="+currentitem.get_catid())
            currentitem.get_parent().removeChild(currentitem)
            self.catlist.reloadItem(self.searchCat, reloadChildren: true)
            return
        }
        
        
        if (!currentitem.get_parent().isEqual(currentitem)){
            self.mydb.executesql("DELETE FROM folders WHERE id="+currentitem.get_catid())
            self.catdelete(currentitem.get_catid())
            currentitem.get_parent().removeChild(currentitem)
            self.catlist.reloadItem(self.templateCatItem, reloadChildren: true)
        }
    }
    
    
    
    @IBAction func editSearch(sender: AnyObject) {
        self.my_new_edit_search = nil
        self.my_new_edit_search = new_edit_search(windowNibName: "new_edit_search");
        
        let currentitem = self.catlist.itemAtRow(self.catlastclickrow) as! catitem
        
        self.my_new_edit_search.currentEditId = currentitem.get_catid()
        
        self.window!.beginSheet(self.my_new_edit_search.window!, completionHandler: {(returnCode) -> Void in
            if (returnCode == NSModalResponseOK){
                currentitem.set_catname(self.my_new_edit_search.menuname.stringValue) 
                self.catlist.reloadItem(self.searchCat, reloadChildren: true)
            }
        });
    }
    
    
    
    //MARK:DB CAT
    func loadCats(){
        
        let ldata = mydb.sql_read_select("select * from folders WHERE folderparentid='-10' ORDER BY foldername ASC")
        for var i=0; i<ldata.count; ++i{
            
            let newcat = self.addcat(ldata[i]["foldername"]!, myid: ldata[i]["id"]!, myimg: "NSFolder", cparent: templateCatItem, is_template: true)

            if (ldata[i]["expand"] as String! == "1"){
                // self.catlist.expandItem(newcat)
                cat_start_expandlist.addObject(newcat)
            }
            
            loadChilds(newcat)
            
        }
        // AB jetzt Schleife, bis nix mehr kommt
        
        
    }
    
    func updateCatCount(){
        var countArray : [[String : String]] = self.mydb.sql_read_select("SELECT folder,count(id) AS M FROM searchqueryurls WHERE messageunread=1 GROUP BY folder")
        for var i = 0; i < countArray.count; ++i {
            for var o = 0; o < self.searchCat.getChildCount(); ++o {
                if self.searchCat.childAtIndex(o).get_catid() == countArray[i]["folder"] {
                    let newCount : String = countArray[i]["M"]!
                    self.searchCat.childAtIndex(o).set_cat_count(newCount.toInt()!)
                    break
                }
            }
        }
    }
    
    func loadSearch(){
        let ldata = mydb.sql_read_select("select * from searchquery ORDER BY sort ASC")
        for var i=0; i<ldata.count; ++i{
            let newcat = self.addcat(ldata[i]["desc"]!, myid: ldata[i]["id"]!, myimg: "Tag - Blue_48x48", cparent: searchCat, is_template: false)
        }
    }
    
    func loadChilds(fromCat : catitem){
        let ldata = mydb.sql_read_select("select * from folders WHERE folderparentid='"+fromCat.get_catid()+"' ORDER BY foldername ASC")
        for var i=0; i<ldata.count; ++i{
            let newcat = self.addcat(ldata[i]["foldername"]!, myid: ldata[i]["id"]!, myimg: "NSFolder", cparent: fromCat, is_template: true)
            if (ldata[i]["expand"] as String! == "1"){
                cat_start_expandlist.addObject(newcat)
            }
            self.loadChilds(newcat)
        }
    }
    
    func catdelete(which : String){
        let ldata = mydb.sql_read_select("select * from folders WHERE folderparentid='"+which+"' ORDER BY foldername ASC")
        for var i=0; i<ldata.count; ++i{
            self.mydb.executesql("DELETE FROM folders WHERE id="+ldata[i]["id"]!)
            self.catdelete(ldata[i]["id"]!)
        }
    }
    
    //MARK:DB Items
    func load_data(filterStr : String){
        
        // Save old select
        let oldSelect = self.itemstableview.selectedRowIndexes.toArray()
        var idList : NSMutableArray = []
        for var i = 0; i < oldSelect.count; ++i {
            let tItem : [String : String] = self.tableDataArray.objectAtIndex(oldSelect[i]) as! [String : String]
            idList.addObject(tItem["id"]!)
        }
        
        self.currentFilter = filterStr
        var currentTable = "items"
        
        if self.currentFolderParentID == -5 {
            currentTable = "searchqueryurls"
        }
        
        var newFilter = "SELECT * FROM " + currentTable
        if (filterStr != "") {
            newFilter += " WHERE " + filterStr
        }
        
        if self.currentFolderParentID == -5 && newFilter.contains("ORDER BY") == false{
            newFilter += " ORDER BY id DESC"
        }
        
        let tempArray = self.mydb.sql_read_select(newFilter)
        tableDataArray = NSMutableArray.new()
        for var i = 0; i < tempArray.count; ++i {
            tableDataArray.addObject(tempArray[i])
        }
        
        itemstableview.reloadData()
        
        // After reload, check old selects...
        var newIndexSet : NSMutableIndexSet = NSMutableIndexSet.new()
        for var i = 0; i < idList.count; ++i {
            for var ii = 0; ii < self.tableDataArray.count; ++ii {
                let tItem : [String : String] = self.tableDataArray.objectAtIndex(ii) as! [String : String]
                let check1 : String = tItem["id"]!
                let check2 : String = idList[i] as! String
                if (check1 == check2){
                    newIndexSet.addIndex(ii)
                    break
                }
            }
        }
        if tableDataArray.count > 0 && newIndexSet.count == 0 {
            newIndexSet.addIndex(0)
        }
        
        
        let itemtext : String = NSLocalizedString("Items", comment: "Quantity of items in current view")
        var newWinTitle = NSBundle.mainBundle().infoDictionary!["CFBundleName"] as! String + " "
        newWinTitle += NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String
        newWinTitle += " (" + String(tableDataArray.count) + " " + itemtext + ")"
        self.window.title = newWinTitle
        if (tableDataArray.count>0){
            self.itemstableview.allowsEmptySelection = true
            itemstableview.selectRowIndexes(NSIndexSet.new(), byExtendingSelection: false)
            itemstableview.selectRowIndexes(newIndexSet, byExtendingSelection: true)
            self.tableView(itemstableview, selectionIndexesForProposedSelection: newIndexSet)
            self.itemstableview.allowsEmptySelection = false
        } else {
            self.messControl.resetAll()
        }
    }


}

