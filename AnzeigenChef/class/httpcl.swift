//
//  httpcl.swift
//  AnzeigenChef
//
//  Created by DerDaHinten on 06.05.15.
//  Copyright (c) 2015 Anon. All rights reserved.
//

import Foundation



class httpcl{
    
    var lastError: String = ""
    
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
    
    func addItem(listData : NSDictionary)->Bool {
        var reponseError: NSError?
        var response: NSURLResponse?
        
        
        // Step 1: Open
        var ebayUrl = NSURL(string: "http://kleinanzeigen.ebay.de/anzeigen/p-anzeige-aufgeben.html")
        var request = NSMutableURLRequest(URL: ebayUrl! )
        request.timeoutInterval = 60
        request.HTTPShouldHandleCookies=true
        
        var urlData: NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&reponseError)
        if ( urlData != nil ) {
            let res = response as! NSHTTPURLResponse!;
            if (res.statusCode >= 200 && res.statusCode < 300)
            {
                var responseData:NSString  = NSString(data:urlData!, encoding:NSUTF8StringEncoding)!
                
                // Step 2: Send data...
                var ebayUrl2 = NSURL(string: "https://kleinanzeigen.ebay.de/anzeigen/p-anzeige-aufgeben-schritt2.html")
                var request = NSMutableURLRequest(URL: ebayUrl2! )
                request.setValue(ebayUrl?.absoluteString, forHTTPHeaderField: "Referer")
                request.timeoutInterval = 60
                request.HTTPShouldHandleCookies=true
                var stringPost=(listData["categoryId"] as! String).stringByReplacingOccurrencesOfString("|", withString: "&", options: NSStringCompareOptions.LiteralSearch, range: nil)
                let data = stringPost.dataUsingEncoding(NSASCIIStringEncoding)
                request.HTTPBody=data
                request.HTTPMethod = "POST"
                var urlData2: NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&reponseError)
                if ( urlData2 != nil ) {
                    let res = response as! NSHTTPURLResponse!;
                    if (res.statusCode >= 200 && res.statusCode < 300){
                        var responseData2:NSString  = NSString(data:urlData2!, encoding:NSUTF8StringEncoding)!
                        if responseData2.containsString("p-anzeige-abschicken.html"){
                            
                            // Step 3: Send last data...
                            var PostData : NSMutableArray = []
                            PostData.addObject("title=" + (listData["title"] as! String).encodeURL())
                            PostData.addObject("description=" + (listData["desc"] as! String).encodeURL())
                            PostData.addObject("priceAmount=" + (listData["price"] as! String).encodeURL())
                            PostData.addObject("zipCode=" + (listData["postalcode"] as! String).encodeURL())
                            PostData.addObject("streetName=" + (listData["street"] as! String).encodeURL())
                            PostData.addObject("contactName=" + (listData["myname"] as! String).encodeURL())
                            PostData.addObject("phoneNumber=" + (listData["myphone"] as! String).encodeURL())
                            
                            // Step 3.1: Send images
                            for var i = 1; i<20; ++i{
                                var pi=""
                                if (i>1){
                                    pi = String(i)
                                }
                                let pURL = listData["image" + pi] as! String
                                if (pURL != ""){
                                    let newURL = self.sendPicToeBay(NSURL(string: pURL)!)
                                    if (newURL != ""){
                                        PostData.addObject("images=" + newURL.encodeURL())
                                    }
                                }
                            }
                            
                            var ebayUrl3 = NSURL(string: "https://kleinanzeigen.ebay.de/anzeigen/p-anzeige-abschicken.html")
                            var request = NSMutableURLRequest(URL: ebayUrl3! )
                            request.setValue(ebayUrl2?.absoluteString, forHTTPHeaderField: "Referer")
                            request.timeoutInterval = 60
                            request.HTTPShouldHandleCookies=true
                            var stringPost=(listData["categoryId"] as! String).stringByReplacingOccurrencesOfString("|", withString: "&", options: NSStringCompareOptions.LiteralSearch, range: nil) + "&" + PostData.componentsJoinedByString("&")
                            let data = stringPost.dataUsingEncoding(NSASCIIStringEncoding)
                            request.HTTPBody=data
                            request.HTTPMethod = "POST"
                            var urlData3: NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&reponseError)
                            if ( urlData3 != nil ) {
                                let res = response as! NSHTTPURLResponse!;
                                if (res.statusCode >= 200 && res.statusCode < 300){
                                    var responseData3:NSString  = NSString(data:urlData3!, encoding:NSUTF8StringEncoding)!
                                    if responseData3.containsString("PostAdSuccess"){
                                        // JUHUUUU!!! gleich sync...
                                        return true
                                    } else {
                                        let flist = self.getfails(responseData3 as String)
                                        self.lastError = flist.componentsJoinedByString("\n\n")
                                    }
                                } else {
                                    self.lastError = "Response ist " + String(res.statusCode)
                                }
                            } else {
                                self.lastError = "urlData3 ist null"
                            }
                        } else {
                            // p-anzeige-abschicken.html war nicht erfolgreich!
                            self.lastError = NSLocalizedString("Categoryselection fails.", comment: "Categoryselection fails")
                        }
                    }
                }
                
            } else {
                self.lastError = NSLocalizedString("Categoryselection fails.", comment: "Categoryselection fails") + "( " + String(res.statusCode) + ")"
            }
        }
        return false
    }
    
    func sendPicToeBay(picPath : NSURL) -> String{
        var reponseError: NSError?
        var response: NSURLResponse?
        var error: NSError?
        let fileName = picPath.path!.lastPathComponent
        let mimeType = "image/png"
        let boundaryConstant = "moxieboundary"+NSUUID().UUIDString;
        
        let url:NSURL? = NSURL(string: "https://kleinanzeigen.ebay.de/anzeigen/p-bild-hochladen.html")
        let cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        var request = NSMutableURLRequest(URL: url!, cachePolicy: cachePolicy, timeoutInterval: 2.0)
        request.setValue("https://kleinanzeigen.ebay.de/anzeigen/p-anzeige-aufgeben-schritt2.html", forHTTPHeaderField: "Referer")
        request.setValue("multipart/form-data; boundary=----"+boundaryConstant, forHTTPHeaderField: "Content-Type")
        request.HTTPMethod = "POST"
        
        let picData = NSData(contentsOfFile: picPath.path!)
 
        
        var dataStringM : NSMutableData = NSMutableData()
        dataStringM.appendData("------\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        dataStringM.appendData("Content-Disposition: form-data; name=\"name\"\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        dataStringM.appendData("\(fileName)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        dataStringM.appendData("------\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        dataStringM.appendData("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        dataStringM.appendData("Content-Type: \(mimeType)\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        dataStringM.appendData(picData!)
        dataStringM.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        dataStringM.appendData("------\(boundaryConstant)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
 
        
        request.HTTPBody = dataStringM
        
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
                                return json["thumbnailUrl"] as! String
                            } else {
                                println(responseData)
                            }
                        } else {
                            println(responseData)
                        }
                    }
                } else {
                    println("Could not parse JSON: \(err!)" + "<br/><br/>" + (responseData as String))
                    return ""
                }
                
            }
        }
        return ""
        
    }
    
    func getfails(fromStr : String) -> NSMutableArray{
        var result : NSMutableArray = []
        var dostr = fromStr
        while(dostr.indexOf("class=\"formerror\"") >= 0){
            let failstr = dostr.getstring("class=\"formerror\">", endStr: "</")
            result.addObject(failstr)
            dostr = dostr.subString(dostr.indexOf("class=\"formerror\"")+20, length: count(dostr)-dostr.indexOf("class=\"formerror\"")-20)
        }
        return result
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