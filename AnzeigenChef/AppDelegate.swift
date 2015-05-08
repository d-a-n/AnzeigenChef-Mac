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
class AppDelegate: NSObject, NSApplicationDelegate, NSOutlineViewDataSource, NSOutlineViewDelegate,NSMenuDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var catlist: NSOutlineView!
    @IBOutlet weak var catpopup: NSMenu!
    
    var mydb = dbfunc()
    var myhttpcl = httpcl()
    var setupControl : setup!
    var folderControl : foldercontroller!
    var katDataArray : [[String : String]] = []
    var catlastclickrow : Int = -1
    
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
        self.addcat("Activ", myid: "-9", myimg : "NSStatusAvailable", cparent: firstCatItem, is_template:false);
        self.addcat("Stopped", myid: "-8", myimg : "NSStatusUnavailable", cparent: firstCatItem, is_template:false);
        self.templateCatItem = self.addcat("Templates", myid: "-10", myimg: "NSFolder", cparent: firstCatItem, is_template:false);
        self.loadCats()
        self.catlist.reloadData()
        catlist.expandItem(firstCatItem);
        catlist.registerForDraggedTypes([kNodesPBoardType])
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
    
    func addcat(myname : String, myid : String, myimg : String, cparent: catitem, is_template : Bool) -> catitem{
        var child1 : catitem = catitem(cname: myname, cid: myid, cimg : myimg, istemplate:is_template, cparent : cparent, cgroup: false)
        cparent.addChild(child1)
        return child1
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
        // OK Accounts holen
        var dataArray : [[String : String]] = self.mydb.sql_read_accounts("")
        for var i=0; i<dataArray.count; ++i{
            let uname : String = dataArray[i]["username"]!
            let upass : String = dataArray[i]["password"]!
            let thelist : NSArray = myhttpcl.shortlist_ebay_account(uname, password: upass)
            for var ii=0; ii<thelist.count; ++ii{
                if let ditem = thelist[ii] as? NSDictionary{
                    var sqlstr : String = "INSERT INTO items (account,itemid,price,title,category,enddate,viewcount,watchcount,image,state,seourl,shippingprovided) VALUES (";
                    sqlstr += dataArray[i]["id"]! + ","
                    sqlstr += self.mydb.quotedstring( (ditem["id"] as AnyObject?)!.stringValue ) + ","
                    sqlstr += self.mydb.quotedstring(ditem["price"] as! String) + ","
                    sqlstr += self.mydb.quotedstring(ditem["title"] as! String) + ","
                    sqlstr += self.mydb.quotedstring(ditem["category"] as! String) + ","
                    sqlstr += self.mydb.quotedstring(ditem["endDate"] as! String) + ","
                    sqlstr += self.mydb.quotedstring( (ditem["viewCount"] as! NSNumber).stringValue ) + ","
                    sqlstr += self.mydb.quotedstring( (ditem["watchCount"] as! NSNumber).stringValue ) + ","
                    sqlstr += self.mydb.quotedstring(ditem["image"] as! String) + ","
                    sqlstr += self.mydb.quotedstring(ditem["state"] as! String) + ","
                    sqlstr += self.mydb.quotedstring(ditem["seoUrl"] as! String) + ","
                    sqlstr += self.mydb.quotedstring( (ditem["shippingProvided"] as AnyObject?)!.stringValue) + ""
                    sqlstr += ")"
                    self.mydb.executesql(sqlstr);
                }
            }
        }
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
    


}

