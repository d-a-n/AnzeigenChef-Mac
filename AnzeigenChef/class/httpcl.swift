//
//  httpcl.swift
//  AnzeigenChef
//
//  Created by DerDaHinten on 06.05.15.
//  Copyright (c) 2015 Anon. All rights reserved.
//

import Foundation



class httpcl{
    
    
    func check_ebay_account(username : String, password : String)->Bool {
        
        var reponseError: NSError?
        var response: NSURLResponse?
        
        var ebayUrl = NSURL(string: "https://kleinanzeigen.ebay.de/anzeigen/m-einloggen.html")
        
        var request = NSMutableURLRequest(URL: ebayUrl! )
        
        var urlData2: NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&reponseError)
        if ( urlData2 != nil ) {
            let res = response as! NSHTTPURLResponse!;
            if (res.statusCode >= 200 && res.statusCode < 300)
            {
                var responseData:NSString  = NSString(data:urlData2!, encoding:NSUTF8StringEncoding)!
            } else {
                return false
            }
        }
        
        
        var targetURI = NSString(string: "/m-meine-anzeigen.html?vl=6066").stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
        
        var stringPost="targetUrl="+targetURI!
        stringPost+="&loginMail="+username
        stringPost+="&password="+password
        let data = stringPost.dataUsingEncoding(NSASCIIStringEncoding)
        
        request.HTTPMethod = "POST"
        request.timeoutInterval = 60
        request.HTTPBody=data
        request.HTTPShouldHandleCookies=true
        
        var urlData: NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&reponseError)
        if ( urlData != nil ) {
            let res = response as! NSHTTPURLResponse!;
            if (res.statusCode >= 200 && res.statusCode < 300)
            {
                var responseData:NSString  = NSString(data:urlData!, encoding:NSUTF8StringEncoding)!
                if responseData.containsString("m-abmelden.html"){
                    return true
                }
            }
        }
        
        return false
    }
    
    func getcats_ebay()->NSDictionary{
        var reponseError: NSError?
        var response: NSURLResponse?
        var ebayUrl = NSURL(string: "http://kleinanzeigen.ebay.de/anzeigen/p-anzeige-aufgeben.html")
        let emptyarray : NSDictionary = ["name" : "nix", "identifier" : "-1", "children" : []]
        
        var request = NSMutableURLRequest(URL: ebayUrl! )
        
        request.HTTPMethod = "GET"
        request.timeoutInterval = 60
        request.HTTPShouldHandleCookies=true
        
        var urlData: NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&reponseError)
        if ( urlData != nil ) {
            let res = response as! NSHTTPURLResponse!;
            if (res.statusCode >= 200 && res.statusCode < 300)
            {
                var responseData:NSString  = NSString(data:urlData!, encoding:NSUTF8StringEncoding)!
                responseData = "{\"categoryTree\": {" + (responseData as! String).getstring("categoryTree: {", endStr: "});") + "}"
                
                var xdata: NSData = responseData.dataUsingEncoding(NSUTF8StringEncoding)!
                var err: NSError?
                if let jsonobj : AnyObject = NSJSONSerialization.JSONObjectWithData(xdata, options: .MutableLeaves, error: &err) {
                    if let json : NSDictionary = jsonobj as? NSDictionary {
                        
                        if ((json["categoryTree"]) != nil){
                            let jscategoryTree = json["categoryTree"] as! NSDictionary
                            return jscategoryTree
                            //if (jscategoryTree["children"] != nil){
                            //    let jsKids = jscategoryTree["children"] as! NSArray
                                /*
                                for var i=0; i<jsKids.count; ++i{
                                    if (jsKids[i]["name"] != nil){
                                        println(jsKids[i]["name"])
                                        println(jsKids[i]["identifier"])
                                    }
                                }
                                */
                            //    return jsKids
                            //} else {
                            //    println(responseData)
                            //}
                        } else {
                            println(responseData)
                        }
                    }
                } else {
                    println("Could not parse JSON: \(err!)" + "<br/><br/>" + (responseData as String))
                    return emptyarray
                }
                
            } else {
                println("StatusCode: "+String(res.statusCode)+" -> ")
            }

        }
        return emptyarray
    }
    
    
    
    func pause_ad_ebay(adId : String, whatDo : String)->Bool {
        
        var reponseError: NSError?
        var response: NSURLResponse?
        
        var ebayUrl = NSURL(string: "http://kleinanzeigen.ebay.de/anzeigen/m-anzeige-pausieren.json")
        if (whatDo == "active"){
            ebayUrl = NSURL(string: "http://kleinanzeigen.ebay.de/anzeigen/m-anzeige-fortsetzen.json")
        }
        
        var request = NSMutableURLRequest(URL: ebayUrl! )
        var stringPost="adId="+adId
        let data = stringPost.dataUsingEncoding(NSASCIIStringEncoding)
        
        request.HTTPMethod = "POST"
        request.timeoutInterval = 60
        request.HTTPBody=data
        request.HTTPShouldHandleCookies=true
        
        var urlData: NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&reponseError)
        if ( urlData != nil ) {
            let res = response as! NSHTTPURLResponse!;
            if (res.statusCode >= 200 && res.statusCode < 300)
            {
                var responseData:NSString  = NSString(data:urlData!, encoding:NSUTF8StringEncoding)!
                
                var xdata: NSData = responseData.dataUsingEncoding(NSUTF8StringEncoding)!
                var err: NSError?
                if let jsonobj : AnyObject = NSJSONSerialization.JSONObjectWithData(xdata, options: .MutableLeaves, error: &err) {
                    if let json : NSDictionary = jsonobj as? NSDictionary {
                        
                        if ((json["status"]) != nil){
                            if (json["status"] as! String == "OK"){
                                return true
                            } else {
                                println(responseData)
                            }
                        } else {
                            println(responseData)
                        }
                    }
                } else {
                    println("Could not parse JSON: \(err!)" + "<br/><br/>" + (responseData as String))
                    return false
                }
                
            }
        }
        return false
    }
    
    
    
    func stop_ad_ebay(adId : String)->Bool {
        var reponseError: NSError?
        var response: NSURLResponse?
        var ebayUrl = NSURL(string: "http://kleinanzeigen.ebay.de/anzeigen/m-anzeigen-loeschen.json?ids="+adId+"&pageNum=1")
        
        var request = NSMutableURLRequest(URL: ebayUrl! )
        var stringPost="ids="+adId
        let data = stringPost.dataUsingEncoding(NSASCIIStringEncoding)
        
        request.HTTPMethod = "GET"
        request.timeoutInterval = 60
        // request.HTTPBody=data
        request.HTTPShouldHandleCookies=true
        
        var urlData: NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&reponseError)
        if ( urlData != nil ) {
            let res = response as! NSHTTPURLResponse!;
            if (res.statusCode >= 200 && res.statusCode < 300)
            {
                var responseData:NSString  = NSString(data:urlData!, encoding:NSUTF8StringEncoding)!
                println(responseData)
                var xdata: NSData = responseData.dataUsingEncoding(NSUTF8StringEncoding)!
                var err: NSError?
                if let jsonobj : AnyObject = NSJSONSerialization.JSONObjectWithData(xdata, options: .MutableLeaves, error: &err) {
                    if let json : NSDictionary = jsonobj as? NSDictionary {
                        
                        if ((json["success"]) != nil){
                            if (json["success"] as! NSArray).count>0{
                                return true
                            } else {
                                println(responseData)
                            }
                        } else {
                            println(responseData)
                        }
                    }
                } else {
                    println("Could not parse JSON: \(err!)" + "<br/><br/>" + (responseData as String))
                    return false
                }
                
            } else {
                println("StatusCode: "+String(res.statusCode)+" -> "+stringPost)
            }
        }
        return false
    }
    
    
    func message_ebay(messageId : String, messageText : String, images : NSArray?)->Bool {
        var reponseError: NSError?
        var err: NSError?
        var response: NSURLResponse?
        var ebayUrl = NSURL(string: "http://kleinanzeigen.ebay.de/anzeigen/m-nachricht-schreiben.json")
        
        var request = NSMutableURLRequest(URL: ebayUrl! )
        
        let jobj  = ["id" : messageId, "message" : messageText]
        
        request.HTTPMethod = "POST"
        request.timeoutInterval = 60
        request.HTTPShouldHandleCookies=true
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jobj, options: NSJSONWritingOptions.allZeros, error: &err)
        
        var urlData: NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&reponseError)
        if ( urlData != nil ) {
            let res = response as! NSHTTPURLResponse!;
            if (res.statusCode >= 200 && res.statusCode < 300)
            {
                var responseData:NSString  = NSString(data:urlData!, encoding:NSUTF8StringEncoding)!
                println(responseData)
                var xdata: NSData = responseData.dataUsingEncoding(NSUTF8StringEncoding)!
                var err: NSError?
                if let jsonobj : AnyObject = NSJSONSerialization.JSONObjectWithData(xdata, options: .MutableLeaves, error: &err) {
                    if let json : NSDictionary = jsonobj as? NSDictionary {
                        
                        if ((json["success"]) != nil){
                            if (json["success"] as? Bool == true){
                                return true
                            } else {
                                println(responseData)
                            }
                        } else {
                            println(responseData)
                        }
                    }
                } else {
                    println("Could not parse JSON: \(err!)" + "<br/><br/>" + (responseData as String))
                    return false
                }
                
            } else {
                println("StatusCode: "+String(res.statusCode))
            }
        }
        return false
    }
    
    
    func shortlist_ebay_account(username : String, password : String)->NSArray {
        var reponseError: NSError?
        var response: NSURLResponse?
        var emptyarray : NSArray = []
        
        var ebayUrl = NSURL(string: "http://kleinanzeigen.ebay.de/anzeigen/m-meine-anzeigen-verwalten.json")
        var request = NSMutableURLRequest(URL: ebayUrl! )
        
        var urlData2: NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&reponseError)
        if ( urlData2 != nil ) {
            let res = response as! NSHTTPURLResponse!;
            if (res.statusCode >= 200 && res.statusCode < 300)
            {
                var responseData:NSString  = NSString(data:urlData2!, encoding:NSUTF8StringEncoding)!
                var xdata: NSData = responseData.dataUsingEncoding(NSUTF8StringEncoding)!
                var err: NSError?
                if let jsonobj : AnyObject = NSJSONSerialization.JSONObjectWithData(xdata, options: .MutableLeaves, error: &err) {
                    if let json : NSDictionary = jsonobj as? NSDictionary {
                        
                        if ((json["ads"]) != nil){
                            let ads : NSArray = json["ads"] as! NSArray
                            return ads
                        }
                    }
                } else {
                    println("Could not parse JSON: \(err!)" + "<br/><br/>" + (responseData as String))
                    return emptyarray
                }
                
            } else {
                return emptyarray
            }
        }
        return emptyarray
    }
    
    func conversation_ebay(username : String, password : String) ->NSArray{
        var reponseError: NSError?
        var response: NSURLResponse?
        var emptyarray : NSArray = []
       
        var ebayUrl = NSURL(string: "http://kleinanzeigen.ebay.de/anzeigen/m-konversationen-uebersicht.json?vl=9526")
        var request = NSMutableURLRequest(URL: ebayUrl! )
 
        var urlData: NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&reponseError)
        if ( urlData != nil ) {
            let res = response as! NSHTTPURLResponse!;
            if (res.statusCode >= 200 && res.statusCode < 300)
            {
                var responseData:NSString  = NSString(data:urlData!, encoding:NSUTF8StringEncoding)!
                var xdata: NSData = responseData.dataUsingEncoding(NSUTF8StringEncoding)!
                var err: NSError?
                
                if let jsonobj : AnyObject = NSJSONSerialization.JSONObjectWithData(xdata, options: .MutableLeaves, error: &err) {
                    if let json : NSDictionary = jsonobj as? NSDictionary {
                        if ((json["conversations"]) != nil){
                            let messages : NSArray = json["conversations"] as! NSArray
                            return messages
                        }
                    }
                } else {
                    println("Could not parse JSON: \(err!)" + "<br/><br/>" + (responseData as String))
                    return emptyarray
                }
            }
        }
        return emptyarray
    }
    
    
    
    func conversation_detail_ebay(username : String, password : String, cid : String) ->NSArray{
        var reponseError: NSError?
        var response: NSURLResponse?
        var emptyarray : NSArray = []
        
        var ebayUrl = NSURL(string: "http://kleinanzeigen.ebay.de/anzeigen/m-konversation.json?id=" + cid)
        var request = NSMutableURLRequest(URL: ebayUrl! )

        var urlData: NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&reponseError)
        if ( urlData != nil ) {
            let res = response as! NSHTTPURLResponse!;
            if (res.statusCode >= 200 && res.statusCode < 300)
            {
                var responseData:NSString  = NSString(data:urlData!, encoding:NSUTF8StringEncoding)!
                var xdata: NSData = responseData.dataUsingEncoding(NSUTF8StringEncoding)!
                var err: NSError?
                if let jsonobj : AnyObject = NSJSONSerialization.JSONObjectWithData(xdata, options: .MutableLeaves, error: &err) {
                    if let json : NSDictionary = jsonobj as? NSDictionary {
                        
                        if ((json["messages"]) != nil){
                            let messages : NSArray = json["messages"] as! NSArray
                            return messages
                        }
                    }
                } else {
                    println("Could not parse JSON: \(err!)" + "<br/><br/>" + (responseData as String))
                    return emptyarray
                }
            }
        }
        return emptyarray
    }
    
 
    
    func logout_ebay_account() -> Bool{
        var reponseError: NSError?
        var response: NSURLResponse?
        var ebayUrl = NSURL(string: "https://kleinanzeigen.ebay.de/anzeigen/m-abmelden.html")
        var request = NSMutableURLRequest(URL: ebayUrl! )
        
        var urlData2: NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&reponseError)
        if ( urlData2 != nil ) {
            let res = response as! NSHTTPURLResponse!;
            if (res.statusCode >= 200 && res.statusCode < 300)
            {
                var responseData:NSString  = NSString(data:urlData2!, encoding:NSUTF8StringEncoding)!
            } else {
                return false
            }
        }
        
        return true
    }
}