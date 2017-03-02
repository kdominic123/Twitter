//
//  Tweet.swift
//  TweetBot
//
//  Created by Kenan Dominic on 2/27/17.
//  Copyright © 2017 Kenan Dominic. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    
    var text: String?
    var time: Date?
    var favouritesCount: Int = 0
    var imageProfile: String?
    var name: String?
    var screenname: String?
    var retweetCount: Int = 0
    var favoritesCount: Int = 0
    var favorited: Bool?
    var retweeted: Bool?
    var id_str: String?
    
    init(dictionary: NSDictionary) {
        
        text = dictionary["text"] as? String
        retweetCount = (dictionary["retweet_count"] as? Int) ?? 0
        favouritesCount = (dictionary["favourites_count"] as? Int) ?? 0
        
        let dict = (dictionary["user"] as! NSDictionary?)!
        imageProfile = (dict["profile_image_url_https"] as? String)
        name = dict["name"] as! String?
        screenname = dict["screen_name"] as! String?
        favorited = dictionary["favorited"] as? Bool
        retweeted = dictionary["retweeted"] as? Bool
        retweetCount = (dictionary["retweet_count"] as? Int) ?? 0
        favoritesCount = (dictionary["favorite_count"] as? Int) ?? 0
        id_str = dictionary["id_str"] as? String
        
        let timeString = dictionary["created_at"] as? String
        
        if let timeString = timeString {
            
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
            
            time = formatter.date(from: timeString)
        }
    }
    
    class func tweetsWithArray(dictionaries: [NSDictionary]) -> [Tweet] {
        
        var tweets = [Tweet]()
        
        for dictionary in dictionaries {
            
            let tweet = Tweet(dictionary: dictionary)
            tweets.append(tweet)
        }
        
        return tweets
    }
}
