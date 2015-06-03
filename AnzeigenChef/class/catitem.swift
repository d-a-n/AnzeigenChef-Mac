//
//  catitem.swift
//  AnzeigenChef
//
//  Created by DerDaHinten on 03.05.15.
//  Copyright (c) 2015 Anon. All rights reserved.
//

import Foundation

class catitem : NSObject{
    var catname = ""
    var catid = ""
    var catimg = ""
    var istemplateitem = false
    var catisgroup = false
    var catparent : [catitem] = []
    var catcount = 0
    
    var catchilds : [catitem] = []
    
    init(cname: String, cid : String, cimg : String, istemplate : Bool, cparent : AnyObject?, cgroup : Bool) {
        self.catname = cname
        self.catisgroup = cgroup
        self.catid = cid;
        self.catimg = cimg;
        self.istemplateitem = istemplate;
        if (cparent is catitem) {
           self.catparent.append(cparent as! catitem)
        }
    }
    
    func isgroup() -> Bool {
        return self.catisgroup
    }
    
    func set_cat_count(newCount : Int){
        self.catcount = newCount
    }
    
    func reducecatcount(){
        --self.catcount
    }
    
    func get_parent() -> catitem{
        if (self.catparent.count>0){
            return self.catparent[0]
        }
        return self as catitem
    }
    
    func set_parent(newParent : catitem){
        self.catparent.removeAll(keepCapacity: false)
        self.catparent.append(newParent)
    }
    
    func set_catname(newName : String){
        self.catname = newName;
    }
    
    func get_catname() -> String {
        if self.catcount > 0 {
            return "\(self.catname) (\(self.catcount))"
        } else {
            return self.catname;
        }
    }
    
    func set_catid(newId : String){
        self.catid = newId;
    }
    
    func get_catid() -> String {
        return self.catid;
    }
    
    func childAtIndex(i : Int) -> catitem{
        return self.catchilds[i];
    }
    
    func getChildCount() -> Int {
        return self.catchilds.count;
    }
    
    func addChild(c: catitem){
        catchilds.append(c)
    }
    
    func setCatImage(iname : String){
        self.catimg = iname;
    }
    
    func getCatImage() -> String{
        return self.catimg;
    }
    
    func istemplate() -> Bool{
        return self.istemplateitem;
    }
    
    func removeChild(c : catitem){
        for var i=0; i<self.catchilds.count; ++i{
            if (self.catchilds[i] == c){
                self.catchilds.removeAtIndex(i)
                break
            }
        }
    }
    
}