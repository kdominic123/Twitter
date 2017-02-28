//
//  TwitterClient.swift
//  TweetBot
//
//  Created by Kenan Dominic on 2/27/17.
//  Copyright © 2017 Kenan Dominic. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class TwitterClient: BDBOAuth1SessionManager {
    
    static let sharedInstance = TwitterClient(baseURL: URL(string: "https://api.twitter.com"), consumerKey: "icrQ5nGUt7iEDmyzJl7zYtB7y", consumerSecret: "4980ApZnkIJ89gJL0YAEDDDhVN25kvS65oxQ5UjY2VHEBcMXxW")
    
    var loginSuccess: (() -> ())?
    var loginFailure: ((NSError) -> ())?
    
    func login(success: @escaping () -> (), failure: @escaping (NSError) -> ()) {
        
        loginSuccess = success
        loginFailure = failure
        
        deauthorize()
        
        fetchRequestToken(withPath: "oauth/request_token", method: "GET", callbackURL: URL(string: "tweetbot://oauth"), scope: nil, success: { (requestToken: BDBOAuth1Credential?) in
            
            let token = requestToken!.token as! String
            
            let url = URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(token)")!
            UIApplication.shared.openURL(url)
            
        }, failure: { (error: Error?) in
            self.loginFailure?(error as! NSError)
        })
    }
    
    func handleOpenURL(url: URL) {
        
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        TwitterClient.sharedInstance?.fetchAccessToken(withPath: "oauth/access_token", method: "POST", requestToken: requestToken, success: { (accessToken: BDBOAuth1Credential?) in
            
            self.currentAccount(success: { (user: User) in
                
                User.currentUser = user
                self.loginSuccess?()
            }, failure: { (error: NSError) in
                
                self.loginFailure?(error)
            })
        }, failure: { (error: Error?) in
            
            self.loginFailure?(error as! NSError)
        })

    }
    
    func homeTimeline(success: @escaping ([Tweet]) -> (), failure: @escaping (NSError) -> ()) {
        
        get("1.1/statuses/home_timeline.json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            
            let dictionaries = response as! [NSDictionary]
            let tweets = Tweet.tweetsWithArray(dictionaries: dictionaries)
            
            success(tweets)
            
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            
            failure(error as NSError)
        })
    }
    
    func currentAccount(success: @escaping (User) -> (), failure: @escaping (NSError) -> ()) {
        
        get("1.1/account/verify_credentials.json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            
            let userDictionary = response as! NSDictionary
            let user = User(dictionary: userDictionary)
            
            success(user)
            
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            
            failure(error as NSError)
        })
    }
    
    func logout() {
        
        User.currentUser = nil
        deauthorize()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UserDidLogout"), object: nil)
    }
}
