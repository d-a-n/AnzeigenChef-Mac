//
//  MessageControl.swift
//  AnzeigenChef
//
//  Created by DerDaHinten on 12.05.15.
//  Copyright (c) 2015 Anon. All rights reserved.
//

import Cocoa
import WebKit

class MessageControl: NSObject,NSTableViewDataSource,NSTableViewDelegate {
    
    @IBOutlet weak var messTable: NSTableView!
    @IBOutlet weak var myWeb: WebView!
    
    var messDataArray : NSArray = []
    var mydb = dbfunc()
    
    //MARK: Data
    func loadData(filterStr : String){
        self.messDataArray = mydb.sql_read_conv(filterStr, sqlFields: "id, account, cid, buyername, receiveddate, textshort")
        self.messTable.reloadData()
    }
    
    //MARK: TableView
    func numberOfRowsInTableView(tableView: NSTableView) -> Int{
        return messDataArray.count
    }
    
 
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var cellView: MessageControlCell = tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: self) as! MessageControlCell
        if (messDataArray.count-1>=row){
            let nsdic : [String : String] = messDataArray.objectAtIndex(row) as! [String : String]
            cellView.l1?.stringValue = nsdic["buyername"]!
            cellView.l1_right?.stringValue = nsdic["receiveddate"]!
            cellView.l2?.stringValue = nsdic["textshort"]!
            
            cellView.l1.textColor = NSColor.whiteColor()
        }
        return cellView
    }
    
    func tableView(tableView: NSTableView, selectionIndexesForProposedSelection proposedSelectionIndexes: NSIndexSet) -> NSIndexSet{
        if (proposedSelectionIndexes.count>0){
            let nsdic : [String : String] = messDataArray.objectAtIndex(proposedSelectionIndexes.firstIndex) as! [String : String]
            let current_cid : String = nsdic["cid"]!
            let current_account : String = nsdic["account"]!
            let dataArray = mydb.sql_read_accounts("id="+current_account)
            if (dataArray.count>0){
                var my_httpcl = httpcl()
                let htmlstring = my_httpcl.conversation_detail_ebay_html(dataArray[0]["username"]!, password: dataArray[0]["password"]!, cid: current_cid)
                myWeb.mainFrame.loadHTMLString(htmlstring, baseURL: nil)
            }
            
        }
        return proposedSelectionIndexes
    }

}
