//
//  AppDelegate.swift
//  MovieDatabase24i
//
//  Created by chytilek on 04/05/2020.
//  Copyright © 2020 lukaschytilek. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var apiKey: String = "?api_key=d1c44524b1120b658fd2de3bbdcd9a9f"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    /**
        Showing network error dialog
        - Parameters:
            - view: UIViewController
            - alertAction: Custom UIAlertAction for specific behaviour after click
            - secondAlertAction: Second custom UIAlertAction for specific behaviour after click
    */
    func showNetworkErrorDialog(view: UIViewController,
                                alertAction: UIAlertAction,
                                secondAlertAction: UIAlertAction?){
        let errorDialog = UIAlertController(title: "Error", message: "No network connection", preferredStyle: .alert)
        errorDialog.addAction(alertAction)
        
        if secondAlertAction != nil{
            errorDialog.addAction(secondAlertAction!)
        }
        
        view.present(errorDialog, animated: true, completion: nil)
    }
}

