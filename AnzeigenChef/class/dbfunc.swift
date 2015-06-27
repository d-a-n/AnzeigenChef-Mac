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
        let path = documents.stringByAppendingPathComponent("anzeigenchef.sqlite")
        if sqlite3_open(path, &db) != SQLITE_OK {
            println("error opening database")
        } else {
            // sqlite3_exec(db, "DROP TABLE searchqueryurls", nil, nil, nil)
            if sqlite3_exec(db, "create table if not exists accounts (id integer primary key autoincrement, username text, password text, platform text)", nil, nil, nil) != SQLITE_OK {
                let errmsg = String.fromCString(sqlite3_errmsg(db))
                println("error creating table: \(errmsg)")
            }
            
            
            
            if sqlite3_exec(db, "create table if not exists folders (id integer primary key autoincrement, foldername text, folderparentid integer, expand integer NOT NULL DEFAULT 0)", nil, nil, nil) != SQLITE_OK {
                let errmsg = String.fromCString(sqlite3_errmsg(db))
                println("error creating table: \(errmsg)")
            }
            if (self.sql_column_exists("folders", columnName: "expand") == false){
                if sqlite3_exec(db,"ALTER TABLE folders ADD COLUMN expand integer NOT NULL DEFAULT 0", nil, nil, nil) != SQLITE_OK{
                    let errmsg = String.fromCString(sqlite3_errmsg(db))
                    println("error add column table: \(errmsg)")
                }
            }
            
            
            
            if sqlite3_exec(db, "create table if not exists items (id integer primary key autoincrement, account integer DEFAULT 0, itemid text, price int DEFAULT 0, title text, category text, categoryId text, enddate date, viewcount int DEFAULT 0, watchcount int DEFAULT 0, image text,image2 text,image3 text,image4 text,image5 text,image6 text,image7 text,image8 text,image9 text,image10 text,image11 text,image12 text,image13 text,image14 text,image15 text,image16 text,image17 text,image18 text,image19 text,image20 text, state text,seourl text, shippingprovided text, folder int, adtype integer DEFAULT 0, attribute text, pricetype integer DEFAULT 0, postalcode text, street text, myname text, myphone text, desc text, messagecount integer DEFAULT 0, messageunread integer DEFAULT 0, parentad integer DEFAULT 0)", nil, nil, nil) != SQLITE_OK {
                let errmsg = String.fromCString(sqlite3_errmsg(db))
                println("error creating table: \(errmsg)")
            } else {
                if sqlite3_exec(db, "CREATE UNIQUE INDEX IF NOT EXISTS items_id on items (itemid,account)", nil, nil, nil) != SQLITE_OK {
                    let errmsg = String.fromCString(sqlite3_errmsg(db))
                    println("error creating table: \(errmsg)")
                }
                sqlite3_exec(db, "CREATE INDEX IF NOT EXISTS items_folder on items (folder)", nil, nil, nil)
            }
            
            if sqlite3_exec(db, "create table if not exists items_dup (id integer, account integer DEFAULT 0, itemid text, price int DEFAULT 0, title text, category text, categoryId text, enddate date, viewcount int DEFAULT 0, watchcount int DEFAULT 0, image text,image2 text,image3 text,image4 text,image5 text,image6 text,image7 text,image8 text,image9 text,image10 text,image11 text,image12 text,image13 text,image14 text,image15 text,image16 text,image17 text,image18 text,image19 text,image20 text, state text,seourl text, shippingprovided text, folder int, adtype integer DEFAULT 0, attribute text, pricetype integer DEFAULT 0, postalcode text, street text, myname text, myphone text, desc text, messagecount integer DEFAULT 0, messageunread integer DEFAULT 0, parentad integer DEFAULT 0)", nil, nil, nil) != SQLITE_OK {
                let errmsg = String.fromCString(sqlite3_errmsg(db))
                println("error creating table: \(errmsg)")
            }
            
            if sqlite3_exec(db, "create table if not exists conversations (id integer primary key autoincrement, account integer, adtitle text, adstatus text, adimage text,email text, cid text, buyername text, sellername text, adid text, role text, unread INTEGER, textshort text,boundness text, receiveddate datetime, negotiationenabled text)", nil, nil, nil) != SQLITE_OK {
                let errmsg = String.fromCString(sqlite3_errmsg(db))
                println("error creating table: \(errmsg)")
            } else {
                sqlite3_exec(db, "CREATE UNIQUE INDEX IF NOT EXISTS conversations_idx on conversations (account,cid)", nil, nil, nil)
            }
            
            if sqlite3_exec(db, "create table if not exists conversations_text (id integer primary key autoincrement, account integer, textshort text, textshorttrimmed text, boundness text, type text, receiveddate datetime, attachments text, cid text, unread INTEGER)", nil, nil, nil) != SQLITE_OK {
                let errmsg = String.fromCString(sqlite3_errmsg(db))
                println("error creating table: \(errmsg)")
            } else {
                sqlite3_exec(db, "CREATE UNIQUE INDEX IF NOT EXISTS conversations_text_idx on conversations_text (account,cid,receiveddate)", nil, nil, nil)
            }
            
            
            if sqlite3_exec(db, "create table if not exists searchquery (id integer primary key autoincrement, active integer NOT NULL DEFAULT 1, category text, category_text text, desc text, sort integer NOT NULL DEFAULT 0, query text, ziporcity text, distance integer NOT NULL DEFAULT 0, created datetime, modified datetime, ownurl text, fromprice integer NOT NULL DEFAULT 0, toprice integer NOT NULL DEFAULT 0)", nil, nil, nil) != SQLITE_OK {
                let errmsg = String.fromCString(sqlite3_errmsg(db))
                println("error creating table: \(errmsg)")
            }
            
            if (self.sql_column_exists("searchquery", columnName: "fromprice") == false){
                if sqlite3_exec(db,"ALTER TABLE searchquery ADD COLUMN fromprice integer NOT NULL DEFAULT 0", nil, nil, nil) != SQLITE_OK{
                    let errmsg = String.fromCString(sqlite3_errmsg(db))
                    println("error add column table: \(errmsg)")
                }
            }
            if (self.sql_column_exists("searchquery", columnName: "toprice") == false){
                if sqlite3_exec(db,"ALTER TABLE searchquery ADD COLUMN toprice integer NOT NULL DEFAULT 0", nil, nil, nil) != SQLITE_OK{
                    let errmsg = String.fromCString(sqlite3_errmsg(db))
                    println("error add column table: \(errmsg)")
                }
            }
            
            if sqlite3_exec(db, "create table if not exists searchqueryurls (id integer primary key autoincrement, price int DEFAULT 0, title text, enddate date, viewcount int DEFAULT 0, watchcount int DEFAULT 0, image text,state text,seourl text, folder int, adtype integer DEFAULT 0, pricetype integer DEFAULT 0, postalcode text, desc text, messagecount integer DEFAULT 0, messageunread integer DEFAULT 0, parentad integer DEFAULT 0, searchquery_id integer, itemid text)", nil, nil, nil) != SQLITE_OK {
                let errmsg = String.fromCString(sqlite3_errmsg(db))
                println("error creating table: \(errmsg)")
            } else {
                sqlite3_exec(db, "CREATE UNIQUE INDEX IF NOT EXISTS searchqueryurls_idx on searchqueryurls (seourl)", nil, nil, nil)
                sqlite3_exec(db, "CREATE INDEX IF NOT EXISTS searchqueryurls_idx1 on searchqueryurls (folder,searchquery_id)", nil, nil, nil)
                sqlite3_exec(db, "CREATE INDEX IF NOT EXISTS searchqueryurls_idx2 on searchqueryurls (folder,messageunread)", nil, nil, nil)
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
            println("sql error: \(errmsg)\nSQL: "+sqlStr)
            return false
        }
         
        return true
    }
    
    func makedup(id : String, fid : Int) -> Bool{
        var statement: COpaquePointer = nil
        
        self.executesql("DELETE FROM items_dup")
        
        if sqlite3_prepare_v2(db, "INSERT INTO items_dup SELECT * FROM items WHERE id="+id, -1, &statement,nil) != SQLITE_OK {
            let errmsg = String.fromCString(sqlite3_errmsg(db))
            println("error preparing select: \(errmsg)")
            return false
        } else {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
        }
  
        if fid < 0 && fid != -10 {
            sqlite3_exec(db, "UPDATE items_dup SET id = NULL, itemid = NULL, folder=-10, watchcount=0, viewcount=0, messageunread=0, messagecount=0",nil,nil,nil)
        } else {
            sqlite3_exec(db, "UPDATE items_dup SET id = NULL, itemid = NULL, watchcount=0, viewcount=0, messageunread=0, messagecount=0",nil,nil,nil)
        }
        
        
        
        if sqlite3_prepare_v2(db, "INSERT INTO items SELECT * FROM items_dup", -1, &statement,nil) != SQLITE_OK {
            let errmsg = String.fromCString(sqlite3_errmsg(db))
            println("error preparing INSERT: \(errmsg)")
            return false
        } else {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
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
            sText = sText + " WHERE " + sqlFilter + " ORDER BY foldername ASC"
        }
        if sqlite3_prepare_v2(db, sText, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String.fromCString(sqlite3_errmsg(db))
            println("error preparing select: \(errmsg)")
        }
        
        var sqldata : [[String : String]] = [] // array for dicts..
        
        while sqlite3_step(statement) == SQLITE_ROW {
            
            let cnum = Int(sqlite3_column_count(statement))
            var dataItem = [String : String]()
            for var i=0; i<cnum; ++i{
                let cname = String.fromCString(sqlite3_column_name(statement,Int32(i)))
                dataItem[cname!] = self.textAt(i,statementx: statement)
            }
            sqldata.append(dataItem);
        }
        
        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String.fromCString(sqlite3_errmsg(db))
            println("error finalizing prepared statement: \(errmsg)")
        }
        
        statement = nil
        return sqldata
    }
    
     
    
    func sql_read_conv(sqlFilter : String, sqlFields : String) -> [[String : String]]{
        var statement: COpaquePointer = nil
        var sText = "select " + sqlFields + " FROM conversations";
        if (sqlFilter != ""){
            sText = sText + " WHERE " + sqlFilter
        }
        if sqlite3_prepare_v2(db, sText, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String.fromCString(sqlite3_errmsg(db))
            println("error preparing select: \(errmsg)")
        }
        
        var sqldata : [[String : String]] = [] // array for dicts..
        
        while sqlite3_step(statement) == SQLITE_ROW {
            let cnum = Int(sqlite3_column_count(statement))
            var dataItem = [String : String]()
            for var i=0; i<cnum; ++i{
                let cname = String.fromCString(sqlite3_column_name(statement,Int32(i)))
                dataItem[cname!] = self.textAt(i,statementx: statement)
            }
            sqldata.append(dataItem);
        }
        
        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String.fromCString(sqlite3_errmsg(db))
            println("error finalizing prepared statement: \(errmsg)")
        }
        
        statement = nil
        return sqldata
    }
    
    func sql_read_select(sqlStr : String) -> [[String : String]]{
        var statement: COpaquePointer = nil
        if sqlite3_prepare_v2(db, sqlStr, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String.fromCString(sqlite3_errmsg(db))
            println("error preparing select: \(errmsg)")
        }
        
        var sqldata : [[String : String]] = [] // array for dicts..
        
        while sqlite3_step(statement) == SQLITE_ROW {
            let cnum = Int(sqlite3_column_count(statement))
            var dataItem = [String : String]()
            for var i=0; i<cnum; ++i{
                let cname = String.fromCString(sqlite3_column_name(statement,Int32(i)))
                dataItem[cname!] = self.textAt(i,statementx: statement)
            }
            sqldata.append(dataItem);
        }
        
        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String.fromCString(sqlite3_errmsg(db))
            println("error finalizing prepared statement: \(errmsg)")
        }
        
        statement = nil
        return sqldata
    }
    
    func sql_column_exists(tableName : String, columnName : String) -> Bool{
        var statement: COpaquePointer = nil
        if sqlite3_prepare_v2(db, "PRAGMA table_info(\(tableName)) ", -1, &statement, nil) != SQLITE_OK {
            let errmsg = String.fromCString(sqlite3_errmsg(db))
            println("error preparing select: \(errmsg)")
            return false
        } else {
            while sqlite3_step(statement) == SQLITE_ROW {
                let cname = sqlite3_column_text(statement,Int32(1))
                let buf_cname = String.fromCString(UnsafePointer<Int8>(cname))!
                if (buf_cname == "\(columnName)"){
                    return true
                }
            }
        }
        statement = nil
        return false
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
    
    func quotedstring(identifier : AnyObject?) -> String{
        if (identifier === nil) { return "''" } 
        
        var escapedString = (identifier as! String).stringByReplacingOccurrencesOfString("'",
            withString: "''",
            options:    .LiteralSearch,
            range:      nil)
        return "'\(escapedString)\'"
    }
}