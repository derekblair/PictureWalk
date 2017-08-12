//
//  AppDelegate.swift
//  PictureWalk
//
//  Created by Derek Blair on 2017-07-01.
//  Copyright © 2017 Derek Blair. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var table = Table<UITableViewController>()
    private var coordinator: Coordinator?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds).then {
            $0.rootViewController = UINavigationController(rootViewController: self.table.view)
            self.table.view.navigationItem.setRightBarButton(
                UIBarButtonItem(title: "Start", style: .done,target:self, action: #selector(toggle))
            , animated: false)
            $0.makeKeyAndVisible()
        }


        coordinator = Coordinator(photoService:FlickrService(),picturesDidChange: {[weak self] model in
            self?.table.model = model
        })
        return true
    }

    @objc private func toggle(_ sender:UIBarButtonItem) {
        sender.title = (sender.title == "Start" ? "Stop" : "Start")
        coordinator?.toggle()
    }

}











