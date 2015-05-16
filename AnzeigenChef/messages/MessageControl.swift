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
    @IBOutlet weak var answerButton : NSButton!
    var messageAnsw : MessageAnswer!
    var messDataArray : NSArray = []
    var mydb = dbfunc()
    
    
    
    
    //MARK: Buttons
    @IBAction func answerMessageAction(sender: AnyObject) {
        if (self.messageAnsw == nil) {
            self.messageAnsw = MessageAnswer(windowNibName: "MessageAnswer");
        }
        
        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        
        appDelegate.window!.beginSheet(self.messageAnsw.window!, completionHandler: {(returnCode) -> Void in
            if (returnCode == NSModalResponseOK){
                
                let selx = self.messTable.selectedRowIndexes.toArray()
                for var i=0; i<selx.count; ++i{
                    let nsdic : [String : String] = self.messDataArray.objectAtIndex(selx[i]) as! [String : String]
                    let current_account : String = nsdic["account"]!
                    let current_id: String = nsdic["id"]!
                    let current_cid: String = nsdic["cid"]!
                    
                    var dataArray : [[String : String]] = self.mydb.sql_read_accounts("id=" + current_account)
                    if (dataArray.count>0){
                        var myhttpcl = httpcl()
                        myhttpcl.logout_ebay_account()
                        if (myhttpcl.check_ebay_account(dataArray[0]["username"]!, password: dataArray[0]["password"]!)){

                            if (myhttpcl.message_ebay(current_cid, messageText: self.messageAnsw.messageField.string!, images: nil)){
                                var date = NSDate.new()
                                var dateFormatter = NSDateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                var currentDate = dateFormatter.stringFromDate( date )
                                
                                var sqlstr : String = "INSERT OR IGNORE INTO conversations_text (account, textshort, textshorttrimmed, boundness, type, receiveddate, attachments, cid, unread) VALUES ("
                                sqlstr += dataArray[i]["id"]! + "," + self.mydb.quotedstring(self.messageAnsw.messageField.string!) + ",'','OUTBOUND','MESSAGE','"+currentDate+"','','"+current_cid+"',0)"
                                if (self.mydb.executesql(sqlstr)){
                                    self.mydb.executesql("UPDATE conversations SET unread=0 WHERE id='"+current_id+"'")
                                }
                            } else {
                                println("not okay :(")
                            }
                            
                        }
                    }
                }
                self.gethtmlview(self.messTable.selectedRow)
            }
        });
        
        
    }
    
    
    //MARK: Data
    func loadData(filterStr : String){
        self.messDataArray = mydb.sql_read_conv(filterStr, sqlFields: "id, account, cid, buyername, receiveddate, textshort, unread")
        self.messTable.reloadData()
        if (self.messDataArray.count>0){
            self.messTable.selectRowIndexes(NSIndexSet(index: 0), byExtendingSelection: true)
            self.tableView(messTable, selectionIndexesForProposedSelection: NSIndexSet(index: 0))
        } else {
            self.resetAll()
        }
    }
    
    func resetAll(){
        messDataArray = []
        self.messTable.reloadData()
        let htmlstring = "<html><body></body></html>"
        myWeb.mainFrame.loadHTMLString(htmlstring, baseURL: nil)
        self.answerButton.enabled=false
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
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let date = dateFormatter.dateFromString(nsdic["receiveddate"]!)
            dateFormatter.dateFormat = "dd.MM.yy HH:mm"
            var receivedDate = dateFormatter.stringFromDate(date!)
            
            cellView.l1_right?.stringValue = receivedDate
            cellView.l2?.stringValue = nsdic["textshort"]!
            
            cellView.l1.textColor = NSColor.whiteColor()
            
            if (nsdic["unread"]! == "0") {
                cellView.rbimage.hidden = true
            } else {
                cellView.rbimage.hidden = false
                // cellView.rbimage.image = NSImage(named: "NSStatusPartiallyAvailable")
            }
        }
        return cellView
    }
    
    func tableView(tableView: NSTableView, selectionIndexesForProposedSelection proposedSelectionIndexes: NSIndexSet) -> NSIndexSet{
        if (proposedSelectionIndexes.count>0){
            self.gethtmlview(proposedSelectionIndexes.firstIndex)
        } else {
            self.answerButton.enabled=false
        }
        return proposedSelectionIndexes
    }
    
    func gethtmlview(fromRow : Int){
        self.answerButton.enabled=true
        let nsdic : [String : String] = messDataArray.objectAtIndex(fromRow) as! [String : String]
        let current_cid : String = nsdic["cid"]!
        let current_account : String = nsdic["account"]!
        let current_buyername : String = nsdic["buyername"]!
        
        let MessageArray = self.mydb.sql_read_select("SELECT * FROM conversations_text WHERE cid='" + current_cid + "' AND account='" + current_account + "' ORDER BY receiveddate ASC")
        
        var htmlstring : String = "<html>\n<head>\n<style>\n"
        htmlstring += "body{ background-color: #F0F0F0; }\n"
        htmlstring += ".div1{ font-family: Arial, Helvetica, sans-serif; font-size: 12px; -webkit-font-smoothing: antialiased; -moz-osx-font-smoothing: grayscale; background-color: #87b919; padding: 5; color: #FFFFFF; width: 90%; border-radius: 3px; box-sizing: border-box; -moz-box-sizing: border-box; -webkit-box-sizing: border-box; margin-left: 30px}\n"
        htmlstring += ".div2{ font-family: Arial, Helvetica, sans-serif; font-size: 12px; -webkit-font-smoothing: antialiased; -moz-osx-font-smoothing: grayscale; background-color: #FFFFFF; padding: 5; color: #000000; width: 90%; border-radius: 3px; box-sizing: border-box; -moz-box-sizing: border-box; -webkit-box-sizing: border-box;}\n"
        htmlstring += "</style>\n</head>\n"
        htmlstring += "<body>"
        
        var currentcolor = ""
        for var i=0; i<MessageArray.count; ++i{
            let boundnessStr : String = MessageArray[i]["boundness"]!
            let textShortStr : String = MessageArray[i]["textshort"]!
            let receiveddateStr : String = MessageArray[i]["receiveddate"]!
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let date = dateFormatter.dateFromString(receiveddateStr)
            dateFormatter.dateFormat = "dd.MM.yy HH:mm"
            var receivedDate = dateFormatter.stringFromDate(date!)
            
            if (boundnessStr == "OUTBOUND"){
                htmlstring += "<div class=\"div1\"><div style=\"float: right; text-align: right; width: 120px\">" + receivedDate + "</div><div style=\"margin-right: 150px;\"><u>" + NSLocalizedString("You wrote", comment:"you wrote a message") + ":</u></div>"
            } else {
                htmlstring += "<div class=\"div2\"><div style=\"float: right; text-align: right; width: 120px\">" + receivedDate + "</div><div style=\"margin-right: 150px;\"><b>" + current_buyername + " " + NSLocalizedString("wrote", comment:"other wrote a message") + ":</b></div>"
            }
            
            htmlstring += "<br/><br/>"
            
            
            htmlstring += textShortStr.stringByReplacingOccurrencesOfString("\n", withString: "<br/>", options: nil, range: nil)
            htmlstring += MessageArray[i]["attachments"]!
            htmlstring += "</div><div style=\"height: 15px; clear:both\"></div>"
        }
        
        htmlstring += "<script>window.scrollTo(0,document.body.scrollHeight);</script>"
        htmlstring += "</body>"
        htmlstring += "</html>"
        
        myWeb.mainFrame.loadHTMLString(htmlstring, baseURL: nil)
    }
    
 

}
