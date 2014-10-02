//
//  TabBarDebugController.swift
//  M13InfiniteTabBar
//
//  Created by Brandon McQuilkin on 8/30/14.
//  Copyright (c) 2014 BrandonMcQuilkin. All rights reserved.
//

import UIKit

class TabBarDebugController: UIViewController {
    
    var basicTabBar: M13InfiniteTabBar = M13InfiniteTabBar()
    @IBOutlet var animatedSwitch: UISwitch?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Background to test visual effect view
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundPattern.png"))

        // Do any additional setup after loading the view.
        basicTabBar.frame = CGRectMake(0.0, 80.0, self.view.bounds.size.width, 48.0)
        self.view.addSubview(basicTabBar)
        
        //Add tab bar constraints.
        basicTabBar.setTranslatesAutoresizingMaskIntoConstraints(false)
        var constraintsH: [AnyObject] = NSLayoutConstraint.constraintsWithVisualFormat("H:|[tabView]|", options: NSLayoutFormatOptions.AlignAllBaseline, metrics: nil, views: ["tabView": basicTabBar, "superview": self.view])
        var constraintsV: [AnyObject] = NSLayoutConstraint.constraintsWithVisualFormat("V:|-80.0-[tabView(48.0)]", options: NSLayoutFormatOptions.AlignAllLeft, metrics: nil, views: ["tabView": basicTabBar, "superview": self.view])
        
        self.view.addConstraints(constraintsH)
        self.view.addConstraints(constraintsV)
        
        //Set tabs
        var items: [M13InfiniteTabBarItem] = []
        items.append(M13InfiniteTabBarItem(title: "Bookmarks", image: UIImage(named: "Bookmarks.png"), selectedImage: UIImage(named: "BookmarksSelected.png")))
        items.append(M13InfiniteTabBarItem(title: "Contacts", image: UIImage(named: "Contacts.png"), selectedImage: UIImage(named: "ContactsSelected.png")))
        items.append(M13InfiniteTabBarItem(title: "Downloads", image: UIImage(named: "Downloads.png"), selectedImage: UIImage(named: "DownloadsSelected.png")))
        basicTabBar.setItems(items, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func toggleBackground(sender: UISwitch) {
        if sender.on {
            basicTabBar.backgroundImage = UIImage(named: "tabBarPattern.png")
        } else {
            basicTabBar.backgroundImage = nil
        }
    }
    
    @IBAction func numberOfTabs(sender: UISegmentedControl) {
        var items: [M13InfiniteTabBarItem] = []
        items.append(M13InfiniteTabBarItem(title: "Bookmarks", image: UIImage(named: "Bookmarks.png"), selectedImage: UIImage(named: "BookmarksSelected.png")))
        items.append(M13InfiniteTabBarItem(title: "Contacts", image: UIImage(named: "Contacts.png"), selectedImage: UIImage(named: "ContactsSelected.png")))
        items.append(M13InfiniteTabBarItem(title: "Downloads", image: UIImage(named: "Downloads.png"), selectedImage: UIImage(named: "DownloadsSelected.png")))
        if sender.selectedSegmentIndex == 0 {
            if animatedSwitch!.on {
                basicTabBar.setItems(items, animated: true)
            } else {
                basicTabBar.setItems(items, animated: false)
            }
            return
        }
        
        items.append(M13InfiniteTabBarItem(title: "Favorites", image: UIImage(named: "Favorites.png"), selectedImage: UIImage(named: "FavoritesSelected.png")))
        items.append(M13InfiniteTabBarItem(title: "History", image: UIImage(named: "History.png"), selectedImage: UIImage(named: "HistorySelected.png")))
        
        if sender.selectedSegmentIndex == 1 {
            if animatedSwitch!.on {
                basicTabBar.setItems(items, animated: true)
            } else {
                basicTabBar.setItems(items, animated: false)
            }
            return
        }
        
        items.append(M13InfiniteTabBarItem(title: "More", image: UIImage(named: "More.png"), selectedImage: UIImage(named: "MoreSelected.png")))
        items.append(M13InfiniteTabBarItem(title: "Most Viewed", image: UIImage(named: "MostViewed.png"), selectedImage: UIImage(named: "MostViewedSelected.png")))
        
        if sender.selectedSegmentIndex == 2 {
            basicTabBar.infiniteScrollingEnabled = false;
            if animatedSwitch!.on {
                basicTabBar.setItems(items, animated: true)
            } else {
                basicTabBar.setItems(items, animated: false)
            }
            return
        }
        
        if sender.selectedSegmentIndex == 3 {
            basicTabBar.infiniteScrollingEnabled = true;
            if animatedSwitch!.on {
                basicTabBar.setItems(items, animated: true)
            } else {
                basicTabBar.setItems(items, animated: false)
            }
            return
        }
    }

}
