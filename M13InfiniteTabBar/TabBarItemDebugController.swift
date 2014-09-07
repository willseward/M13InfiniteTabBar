//
//  TabBarItemDebugController.swift
//  M13InfiniteTabBar
//
//  Created by Brandon McQuilkin on 8/28/14.
//  Copyright (c) 2014 BrandonMcQuilkin. All rights reserved.
//

import UIKit

class TabBarItemDebugController: UIViewController {

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var standardItem: M13InfiniteTabBarItem = M13InfiniteTabBarItem(title: "Bookmarks", image: UIImage(named: "Bookmarks.png"), selectedImage: UIImage(named: "BookmarksSelected.png"))
    
    var originalItem: M13InfiniteTabBarItem = M13InfiniteTabBarItem(title: "Contacts", image: UIImage(named: "Contacts.png").imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), selectedImage: UIImage(named: "ContactsSelected.png").imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal))
    
    var badgeItem: M13InfiniteTabBarItem = M13InfiniteTabBarItem(title: "Downloads", image: UIImage(named: "Downloads.png"), selectedImage: UIImage(named: "DownloadsSelected.png"))

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        standardItem.frame = CGRectMake(20, 80, 70, 48)
        originalItem.frame = CGRectMake(110, 80, 70, 48)
        badgeItem.frame = CGRectMake(20, 150, 70, 48)
        badgeItem.badgeValue = "13"
        self.view.addSubview(standardItem)
        self.view.addSubview(originalItem)
        self.view.addSubview(badgeItem)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Rotation
    @IBAction func updateRotation(sender: UISegmentedControl) {
        
        //Get angle
        var angle: CGFloat = 0
        if sender.selectedSegmentIndex == 1 {
            angle = CGFloat(M_PI_2)
        } else if sender.selectedSegmentIndex == 2 {
            angle = CGFloat(M_PI)
        } else if sender.selectedSegmentIndex == 3 {
            angle = CGFloat(M_PI + M_PI_2)
        }
        
        //Set angle
        standardItem.rotateToAngle(angle)
        originalItem.rotateToAngle(angle)
        badgeItem.rotateToAngle(angle)
    }
    
    //Color
    @IBAction func state(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            standardItem.selected = false
            standardItem.requiresUserAttention = false
            standardItem.enabled = true
            originalItem.selected = false
            originalItem.requiresUserAttention = false
            originalItem.enabled = true
            badgeItem.selected = false
            badgeItem.requiresUserAttention = false
            badgeItem.enabled = true
        } else if sender.selectedSegmentIndex == 1 {
            standardItem.selected = true
            standardItem.requiresUserAttention = false
            standardItem.enabled = true
            originalItem.selected = true
            originalItem.requiresUserAttention = false
            originalItem.enabled = true
            badgeItem.selected = true
            badgeItem.requiresUserAttention = false
            badgeItem.enabled = true
        } else if sender.selectedSegmentIndex == 2 {
            standardItem.selected = false
            standardItem.requiresUserAttention = true
            standardItem.enabled = true
            originalItem.selected = false
            originalItem.requiresUserAttention = true
            originalItem.enabled = true
            badgeItem.selected = false
            badgeItem.requiresUserAttention = true
            badgeItem.enabled = true
        } else if sender.selectedSegmentIndex == 3 {
            standardItem.selected = false
            standardItem.requiresUserAttention = false
            standardItem.enabled = false
            originalItem.selected = false
            originalItem.requiresUserAttention = false
            originalItem.enabled = false
            badgeItem.selected = false
            badgeItem.requiresUserAttention = false
            badgeItem.enabled = false
        }
    }

}
