//
//  User.swift
//  TweetBot
//
//  Created by Kenan Dominic on 2/27/17.
//  Copyright © 2017 Kenan Dominic. All rights reserved.
//

import UIKit

class User: NSObject {

    var name: String?
    var screenname: String?
    var profileURL: URL?
    var tagline: String?
    var dictionary: NSDictionary?
    static var _currentUser: User?
    
    init(dictionary: NSDictionary) {
        
        self.dictionary = dictionary
        
        name = dictionary["name"] as? String
        screenname = dictionary["screenname"] as? String
        
        let profileURLString = dictionary["profile_image_url_https"] as? String
        
        if let profileURLString = profileURLString {
            
            profileURL = URL(string: profileURLString)
        }
        
        tagline = dictionary["description"] as? String
    }
    
    class var currentUser: User? {
        
        get {
            
            if _currentUser == nil {
            
                let defaults = UserDefaults.standard
                let userData = defaults.object(forKey: "currentUserData") as? NSData
            
                if let userData = userData {
            
                    let dictionary = try? JSONSerialization.jsonObject(with: userData as Data, options: []) as! NSDictionary
                    
                    if dictionary != nil {
                        _currentUser = User(dictionary: dictionary!)
                    }
                }
            }   
            
            return _currentUser
        }
        
        set(user) {
            
            _currentUser = user
            let defaults = UserDefaults.standard
            
            if let user = user {
                let data = try! JSONSerialization.data(withJSONObject: user.dictionary!, options: [])
             
                defaults.set(data, forKey: "currentUserData")
            } else {
                
                defaults.set(nil, forKey: "currentUserData")
            }
            
            defaults.synchronize()
        }
    }
}
