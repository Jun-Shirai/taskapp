//
//  AppDelegate.swift
//  taskapp
//
//  Created by 白井淳 on 2021/01/30.
//

import UIKit
import UserNotifications //追加。フォアグラウンドでも通知するために

@main
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate {
//↑プロトコルを一つ追加。


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //ユーザーに通知の許可を求める　ーーここからーー
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert,.sound]) {
            (granted, error) in
        }　//ーーここまでーー
        center.delegate = self //追加
        
        return true
    }
    
    //アプリがフォアグラウンド時に通知を受けとるときに呼ばれるメソッドーーここからーー
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner,.list,.sound])
    } //ーーここまでーー

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

