//
//  AppDelegate.swift
//  DID-Demo
//
//  Created by Luke on 2022-01-25.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    static var current: AppDelegate!
    var window: UIWindow?

    
//    let issuer = IssuerService()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AppDelegate.current = self

        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return true
    }
}

