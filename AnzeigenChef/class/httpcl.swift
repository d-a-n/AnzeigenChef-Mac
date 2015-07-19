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
    var lastItemId : String = ""
    
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
    
    
    func get_search(sdate : [String : String]) -> [[String : String]] {
        var reponseError: NSError?
        var response: NSURLResponse?
        var stringPost : String = "keywords=" + (sdate["query"]!).encodeURL() + "&locationStr=" + (sdate["ziporcity"]!).encodeURL() + "&radius=" + (sdate["distance"]!).encodeURL()
        if sdate["fromprice"]! != "0" && sdate["fromprice"]! != "" {
            stringPost += "&minPrice=" + sdate["fromprice"]!
        }
        if sdate["toprice"]! != "0" && sdate["toprice"]! != "" {
            stringPost += "&maxPrice=" + sdate["toprice"]!
        }
        
        // Category...
        let catIds : String = sdate["category"]!
        let catArray = catIds.componentsSeparatedByString("|")
        for var i=0; i<catArray.count; ++i{
            let line : String = catArray[i]
            if line.contains("categoryId="){
                stringPost += "&categoryId=" + line.getstring("=", endStr: "")
                break
            }
        }
 
        var ebayUrl = NSURL(string: "http://kleinanzeigen.ebay.de/anzeigen/s-suchanfrage.html?" + stringPost)
        println("http://kleinanzeigen.ebay.de/anzeigen/s-suchanfrage.html?" + stringPost)
        
        if (sdate["ownurl"]! != ""){
            ebayUrl = NSURL(string: sdate["ownurl"]!)
        }
        
        var request = NSMutableURLRequest(URL: ebayUrl! )
        request.HTTPMethod = "GET"
        request.timeoutInterval = 60
        request.HTTPShouldHandleCookies=true
        
        var ergArray : [[String : String]] = []
        
        var urlData: NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&reponseError)
        if ( urlData != nil ) {
            let res = response as! NSHTTPURLResponse!;
            if (res.statusCode >= 200 && res.statusCode < 300)
            {
                var responseData:NSString  = NSString(data:urlData!, encoding:NSUTF8StringEncoding)!
                var tempstr : String = responseData as! String
                
                
                while tempstr.contains("<li class=\"ad-listitem") {
                    let currentline = tempstr.getstring("<li class=\"ad-listitem", endStr: "</li>")
                    
                    let url = currentline.getstring("href=\"", endStr: "\"")
                    
                    var title = currentline.getstring("class=\"ad-title\"", endStr: "</")
                    title = title.getstring(">", endStr: "")
                    
                    var price = currentline.getstring("class=\"ad-listitem-details\"", endStr: "</strong>")
                    price = price.getstring("<strong>", endStr: "")
                    price = price.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                    
                    var adtype = "1"
                    if price.contains("VB") && price.contains("€") {
                        price = price.cleanToInt()
                        adtype = "2"
                    } else if price.contains("€") {
                        price = price.cleanToInt()
                        adtype = "1"
                    } else if price.contains("VB") {
                        price = price.cleanToInt()
                        adtype = "2"
                    } else {
                        price = "0"
                        adtype = "3"
                    }
                    
                    var desc = currentline.getstring("</h2>", endStr: "</section>")
                    desc = desc.stringByReplacingOccurrencesOfString("<p>", withString: "\n", options: NSStringCompareOptions.LiteralSearch, range: nil)
                    desc = desc.stringByReplacingOccurrencesOfString("</p>", withString: "\n", options: NSStringCompareOptions.LiteralSearch, range: nil)
                    desc = desc.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                    
                    var dist = currentline.getstring("ad-listitem-location", endStr: "</h3>")
                    dist = dist.getstring(">", endStr: "")
                    dist = dist.stringByReplacingOccurrencesOfString("<br>", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil)
                    
                    let image = currentline.getstring("data-imgsrc=\"", endStr: "\"")
     
                    var addtime = currentline.getstring("ad-listitem-addon", endStr: "</")
                    addtime = addtime.getstring(">", endStr: "")
                    addtime = addtime.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                    
                    // println(title + "\n" + url + "\n" + price + "\n" + dist + "\n" + image + "\n" + addtime + "\n" + desc + "\n\n")
                    
                    if dist != "" {
                        let res : [String : String] = ["url" : url, "title" : title, "price" : price, "desc" : desc, "dist" : dist, "image" : image, "addtime" : addtime, "pricetype" : adtype]
                        ergArray.append(res)
                    }
                    
                    tempstr = tempstr.getstring("<li class=\"ad-listitem", endStr: "")
                }
            }
        }
        
        return ergArray
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
                
                // NOW IS EDIT, NOT NEW!
                if (listData["itemid"] as! String != ""){ // adId
                    let itemid = listData["itemid"] as! String
                    ebayUrl2 = NSURL(string: "https://kleinanzeigen.ebay.de/anzeigen/p-anzeige-bearbeiten.html?adId=\(itemid)")
                }
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
                            
                            if (listData["itemid"] as! String != ""){ // adId
                                let itemid = listData["itemid"] as! String
                                PostData.addObject("adId=" + itemid)
                            }
                            
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
                            
                            let pricetype = listData["pricetype"] as! String
                            if pricetype == "1" {
                                PostData.addObject("priceType=FIXED")
                            } else if pricetype == "2" {
                                PostData.addObject("priceType=NEGOTIABLE")
                            } else {
                                PostData.addObject("priceType=GIVE_AWAY")
                            }
                            
                            let adtype = listData["adtype"] as! String
                            if (adtype == "0") {
                                PostData.addObject("adType=OFFER")
                            } else {
                                PostData.addObject("adType=WANTED")
                            }
                            
                            if (listData["company"] as! String == "1"){
                                PostData.addObject("posterType=COMMERCIAL")
                                PostData.addObject("imprint=" + (listData["companyimpress"] as! String).encodeURL())
                            } else {
                                PostData.addObject("posterType=PRIVATE")
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
                                    if responseData3.containsString("PostAdSuccess") || responseData3.containsString("PostSuccessView"){
                                        self.lastItemId = (responseData3 as! String).getstring("p-mein-anzeige-status.json?id=", endStr: "\"")
                                        // JUHUUUU!!! gleich sync...
                                        return true
                                    } else {
                                        let flist = self.getfails(responseData3 as String)
                                        // println("\(responseData3)")
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
        let pp = picPath.absoluteString
        if (pp!.contains("ttp:/") || pp!.contains("ttps:/")){
            return pp!
        }
        var reponseError: NSError?
        var response: NSURLResponse?
        var error: NSError?
        let fileName = picPath.path!.lastPathComponent
        var mimeType = "image/png"
        if (picPath.path!.lastPathComponent.lowercaseString.contains(".jpg") || picPath.path!.lastPathComponent.lowercaseString.contains(".jpeg")){
           mimeType = "image/jpeg"
        }
        let boundaryConstant = "moxieboundary"+NSUUID().UUIDString;
        let tempFileName = NSUUID().UUIDString
        
        let url:NSURL? = NSURL(string: "https://kleinanzeigen.ebay.de/anzeigen/p-bild-hochladen.html")
        let cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        var request = NSMutableURLRequest(URL: url!, cachePolicy: cachePolicy, timeoutInterval: 20.0)
        request.setValue("https://kleinanzeigen.ebay.de/anzeigen/p-anzeige-aufgeben-schritt2.html", forHTTPHeaderField: "Referer")
        request.setValue("multipart/form-data; boundary=----"+boundaryConstant, forHTTPHeaderField: "Content-Type")
        request.HTTPMethod = "POST"
        
        let picData = NSData(contentsOfFile: picPath.path!)
 
        
        var dataStringM : NSMutableData = NSMutableData()
        dataStringM.appendData("------\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        dataStringM.appendData("Content-Disposition: form-data; name=\"name\"\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        dataStringM.appendData("\(tempFileName)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        dataStringM.appendData("------\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        dataStringM.appendData("Content-Disposition: form-data; name=\"file\"; filename=\"\(tempFileName)\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
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
                                self.lastError = "Status fail! Response: " + (responseData as String)
                            }
                        } else {
                            println(responseData)
                        }
                    } else {
                        println(err!.description  + (responseData as String))
                    }
                } else {
                    println("Could not parse JSON: \(err!)" + "<br/><br/>" + (responseData as String))
                    return ""
                }
            } else {
                self.lastError = "Response ist " + String(res.statusCode)
                println(self.lastError)
            }
        } else {
            println("URL DATA NIL! \(reponseError)")
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
        
        var ebayUrl = NSURL(string: "http://kleinanzeigen.ebay.de/anzeigen/m-meine-anzeigen-verwalten.json?pageSize=99999")
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
    
 
    func get_ad_details(adId : String) -> NSMutableDictionary {
        var emptyDic : NSMutableDictionary = ["Ack" : "FAIL"]
        var reponseError: NSError?
        var response: NSURLResponse?
        var ebayUrl = NSURL(string: "https://kleinanzeigen.ebay.de/anzeigen/p-anzeige-bearbeiten.html?adId=" + adId)
        var request = NSMutableURLRequest(URL: ebayUrl! )
        
        var urlData2: NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&reponseError)
        if ( urlData2 != nil ) {
            let res = response as! NSHTTPURLResponse!;
            if (res.statusCode >= 200 && res.statusCode < 300)
            {
                var responseData:NSString  = NSString(data:urlData2!, encoding:NSUTF8StringEncoding)!
                
                // title
                var ad_title = (responseData as! String).getstring("name=\"title\"", endStr: "/>")
                ad_title = ad_title.getstring("value=\"", endStr: "\"")
                
                // description
                var ad_description = (responseData as! String).getstring("name=\"description\"", endStr: "</textarea>")
                ad_description = ad_description.getstring(">", endStr: "")
              
                // ad_company_impress
                var ad_company_impress = (responseData as! String).getstring("name=\"imprint\"", endStr: "</textarea>")
                ad_company_impress = ad_company_impress.getstring(">", endStr: "")
                
                // price
                var ad_price = (responseData as! String).getstring("name=\"priceAmount\"", endStr: "/>")
                ad_price = ad_price.getstring("value=\"", endStr: "\"")
                
                // postalcode
                var ad_postalcode = (responseData as! String).getstring("name=\"zipCode\"", endStr: "/>")
                ad_postalcode = ad_postalcode.getstring("value=\"", endStr: "\"")
                
                // street
                var ad_street = (responseData as! String).getstring("name=\"streetName\"", endStr: "/>")
                ad_street = ad_street.getstring("value=\"", endStr: "\"")
                
                // myname
                var ad_myname = (responseData as! String).getstring("name=\"contactName\"", endStr: "/>")
                ad_myname = ad_myname.getstring("value=\"", endStr: "\"")
                
                // myphone
                var ad_myphone = (responseData as! String).getstring("name=\"phoneNumber\"", endStr: "/>")
                ad_myphone = ad_myphone.getstring("value=\"", endStr: "\"")
                
                var imgstr = responseData as! String
                var imglist : NSMutableArray = []
                while imgstr.indexOf("name=\"images\"")>=0 {
                    var imgval = imgstr.getstring("name=\"images\"", endStr: "/>")
                    imgval = imgval.getstring("value=\"", endStr: "\"")
                    imglist.addObject(imgval)
                    imgstr = imgstr.getstring("name=\"images\"", endStr: "")
                }
                
                // pricetype
                var ad_pricetype = "0"
                var pricetypetemp = ""
                pricetypetemp = (responseData as! String).getstring("id=\"priceType1\"", endStr: "/>")
                if (pricetypetemp.contains("checked")){
                    ad_pricetype = "1"
                }
                pricetypetemp = (responseData as! String).getstring("id=\"priceType2\"", endStr: "/>")
                if (pricetypetemp.contains("checked")){
                    ad_pricetype = "2"
                }
                pricetypetemp = (responseData as! String).getstring("id=\"priceType3\"", endStr: "/>")
                if (pricetypetemp.contains("checked")){
                    ad_pricetype = "3"
                }
                
                // adtype
                var ad_type = "0"
                var adtypetemp = ""
                adtypetemp = (responseData as! String).getstring("id=\"adType1\"", endStr: "/>")
                if (adtypetemp.contains("checked")){
                    ad_type = "0"
                }
                adtypetemp = (responseData as! String).getstring("id=\"adType2\"", endStr: "/>")
                if (adtypetemp.contains("checked")){
                    ad_type = "1"
                }
                
                // ad_company
                var ad_company = "0"
                var adcompanytemp = ""
                adtypetemp = (responseData as! String).getstring("id=\"posterType-commercial\"", endStr: "/>")
                if (adtypetemp.contains("checked")){
                    ad_company = "1"
                }
                
                
                // category
                var ad_category = (responseData as! String).getstring("name=\"categoryId\"", endStr: "/>")
                ad_category = ad_category.getstring("value=\"", endStr: "\"")
                
                // Attribute
                var attrString = responseData as! String
                var attrList : NSMutableArray = []
                while attrString.indexOf("<select ")>=0 {
                    var attrStringVal = attrString.getstring("<select ", endStr: "</select>")
                    let attrName = attrStringVal.getstring("name=\"", endStr: "\"")
                    var attrVal = ""
                    let attrOptions : NSArray = attrStringVal.componentsSeparatedByString("</option>")
                    for var p = 0; p < attrOptions.count; ++p {
                        let attrO = attrOptions[p] as! String
                        if (attrO.contains("selected")){
                            attrVal = attrO.getstring("value=\"", endStr: "\"")
                            break
                        }
                    }
                    if (attrVal != "" && attrName != ""){
                        ad_category += "|" + attrName + "=" + attrVal
                    }
                    attrString = attrString.getstring("<select ", endStr: "")
                }
                
                emptyDic["ad_category"] = "categoryId=" + ad_category
                emptyDic["ad_type"] = ad_type
                emptyDic["imglist"] = imglist
                emptyDic["ad_title"] = ad_title.html_decode()
                emptyDic["ad_company"] = ad_company;
                emptyDic["ad_company_impress"] = ad_company_impress;
                
                ad_description = ad_description.stringByReplacingOccurrencesOfString("\r", withString: "[RETURN]", options: NSStringCompareOptions.LiteralSearch, range: nil)
                ad_description = ad_description.stringByReplacingOccurrencesOfString("\n", withString: "[NEWLINE]", options: NSStringCompareOptions.LiteralSearch, range: nil)
                ad_description = ad_description.html_decode()
                ad_description = ad_description.stringByReplacingOccurrencesOfString("[RETURN]", withString: "\r", options: NSStringCompareOptions.LiteralSearch, range: nil)
                ad_description = ad_description.stringByReplacingOccurrencesOfString("[NEWLINE]", withString: "\n", options: NSStringCompareOptions.LiteralSearch, range: nil)
                
                emptyDic["ad_description"] = ad_description
                
                emptyDic["ad_price"] = ad_price
                emptyDic["ad_pricetype"] = ad_pricetype
                emptyDic["ad_postalcode"] = ad_postalcode.html_decode()
                emptyDic["ad_street"] = ad_street.html_decode()
                emptyDic["ad_myname"] = ad_myname.html_decode()
                emptyDic["ad_myphone"] = ad_myphone.html_decode()
                
                return emptyDic
                
                // println(ad_title + "\n" + ad_description + "\n" + ad_price + "\n" + ad_postalcode + "\n" + ad_street + "\n" + ad_myname + "\n" + ad_myphone)
            } else {
                return emptyDic
            }
        }
        
        return emptyDic
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