//
//  dbfunc.swift
//  AnzeigenChef
//
//  Created by DerDaHinten on 03.05.15.
//  Copyright (c) 2015 Anon. All rights reserved.
//

import Foundation

class dbfunc{
    func opendb(){
        let documents = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        let path = documents.stringByAppendingPathComponent("test.sqlite")
        if sqlite3_open(path, &db) != SQLITE_OK {
            println("error opening database")
        } else {
            /// sqlite3_exec(db,"DROP TABLE items", nil, nil, nil)
            if sqlite3_exec(db, "create table if not exists accounts (id integer primary key autoincrement, username text, password text, platform text)", nil, nil, nil) != SQLITE_OK {
                let errmsg = String.fromCString(sqlite3_errmsg(db))
                println("error creating table: \(errmsg)")
            }
            if sqlite3_exec(db, "create table if not exists folders (id integer primary key autoincrement, foldername text, folderparentid integer)", nil, nil, nil) != SQLITE_OK {
                let errmsg = String.fromCString(sqlite3_errmsg(db))
                println("error creating table: \(errmsg)")
            }
            if sqlite3_exec(db, "create table if not exists items (id integer primary key autoincrement, account integer, itemid text, price text, title text, category text, enddate text, viewcount int, watchcount int, image text, state text,seourl text, shippingprovided text, folder int)", nil, nil, nil) != SQLITE_OK {
                let errmsg = String.fromCString(sqlite3_errmsg(db))
                println("error creating table: \(errmsg)")
            } else {
                if sqlite3_exec(db, "CREATE UNIQUE INDEX IF NOT EXISTS items_id on items (itemid,account)", nil, nil, nil) != SQLITE_OK {
                    let errmsg = String.fromCString(sqlite3_errmsg(db))
                    println("error creating table: \(errmsg)")
                }
                sqlite3_exec(db, "CREATE INDEX IF NOT EXISTS items_folder on items (folder)", nil, nil, nil)
            }
        }
    }
    
    func closedb(){
        if sqlite3_close(db) != SQLITE_OK {
            println("error closing database")
        }
        db = nil
    }
    
    func executesql(sqlStr : String) -> Bool{
        if sqlite3_exec(db, sqlStr, nil, nil, nil) != SQLITE_OK {
            let errmsg = String.fromCString(sqlite3_errmsg(db))
            println("sql error: \(errmsg)")
            return false
        }
        return true
    }
    
    func sql_read_accounts(sqlFilter : String) -> [[String : String]]{
        var statement: COpaquePointer = nil
        var sText = "select id, username, password, platform from accounts";
        if (sqlFilter != ""){
            sText = sText + " WHERE " + sqlFilter
        }
        if sqlite3_prepare_v2(db, sText, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String.fromCString(sqlite3_errmsg(db))
            println("error preparing select: \(errmsg)")
        }
        
        var sqldata : [[String : String]] = [] // array for dicts..
        
        while sqlite3_step(statement) == SQLITE_ROW {
            
            let row_id = self.textAt(0,statementx: statement)
            let row_username = self.textAt(1,statementx: statement)
            let row_password = self.textAt(2,statementx: statement)
            let row_platform = self.textAt(3,statementx: statement)
            
            var dataItem = [String : String]()
            dataItem = ["id" : row_id, "username": row_username, "password" : row_password, "platform" : row_platform]
            sqldata.append(dataItem);
        }
        
        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String.fromCString(sqlite3_errmsg(db))
            println("error finalizing prepared statement: \(errmsg)")
        }
        
        statement = nil
        return sqldata
    }
    
    func sql_read_folders(sqlFilter : String) -> [[String : String]]{
        var statement: COpaquePointer = nil
        var sText = "select id, foldername, folderparentid from folders";
        if (sqlFilter != ""){
            sText = sText + " WHERE " + sqlFilter
        }
        if sqlite3_prepare_v2(db, sText, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String.fromCString(sqlite3_errmsg(db))
            println("error preparing select: \(errmsg)")
        }
        
        var sqldata : [[String : String]] = [] // array for dicts..
        
        while sqlite3_step(statement) == SQLITE_ROW {
            
            let row_id = self.textAt(0,statementx: statement)
            let row_foldername = self.textAt(1,statementx: statement)
            let row_folderparentid = self.textAt(2,statementx: statement)
            
            var dataItem = [String : String]()
            dataItem = ["id" : row_id, "foldername": row_foldername, "folderparentid" : row_folderparentid]
            sqldata.append(dataItem);
        }
        
        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String.fromCString(sqlite3_errmsg(db))
            println("error finalizing prepared statement: \(errmsg)")
        }
        
        statement = nil
        return sqldata
    }
    
    func sql_read_items(sqlFilter : String) -> [[String : String]]{
        var statement: COpaquePointer = nil
        var sText = "select items.id, items.account, items.itemid, items.price, items.title, items.category, items.enddate, items.viewcount, items.watchcount, items.image, items.state, items.seourl, items.shippingprovided, accounts.username AS AUsername from items INNER JOIN accounts ON items.account=accounts.id";
        if (sqlFilter != ""){
            sText = sText + " WHERE " + sqlFilter
        }
        if sqlite3_prepare_v2(db, sText, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String.fromCString(sqlite3_errmsg(db))
            println("error preparing select: \(errmsg)")
        }
        
        var sqldata : [[String : String]] = [] // array for dicts..
        
        while sqlite3_step(statement) == SQLITE_ROW {
            
            let row_id = self.textAt(0,statementx: statement)
            let row_account = self.textAt(13,statementx: statement)
            let row_itemid = self.textAt(2,statementx: statement)
            let row_price = self.textAt(3,statementx: statement)
            let row_title = self.textAt(4,statementx: statement)
            let row_category = self.textAt(5,statementx: statement)
            let row_enddate = self.textAt(6,statementx: statement)
            let row_viewcount = self.textAt(7,statementx: statement)
            let row_watchcount = self.textAt(8,statementx: statement)
            let row_image = self.textAt(9,statementx: statement)
            let row_state = self.textAt(10,statementx: statement)
            let row_seourl = self.textAt(11,statementx: statement)
            let row_shippingprovided = self.textAt(12,statementx: statement)
            
            var dataItem = [String : String]()
            dataItem = ["id" : row_id, "account": row_account, "itemid" : row_itemid, "price" : row_price, "title" : row_title, "category" : row_category, "enddate" : row_enddate, "viewcount" : row_viewcount, "watchcount" : row_watchcount, "image" : row_image, "state" : row_state, "seourl" : row_seourl, "shippingprovided" : row_shippingprovided]
            sqldata.append(dataItem);
        }
        
        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String.fromCString(sqlite3_errmsg(db))
            println("error finalizing prepared statement: \(errmsg)")
        }
        
        statement = nil
        return sqldata
    }
    
    func textAt(col:Int, statementx: COpaquePointer) -> String {
        let name = sqlite3_column_text(statementx, Int32(col))
        if name != nil {
            return String.fromCString(UnsafePointer<Int8>(name))!
        }
        return ""
    }
    
    func intAt(col:Int, statementx: COpaquePointer) -> Int {
        return Int(sqlite3_column_int64(statementx, Int32(col)))
    }
    
    func lastId() -> Int {
        return Int(sqlite3_last_insert_rowid(db))
    }
    
    func quotedstring(identifier : String) -> String{
        var escapedString = identifier.stringByReplacingOccurrencesOfString("'",
            withString: "''",
            options:    .LiteralSearch,
            range:      nil)
        return "'\(escapedString)\'"
    }
}