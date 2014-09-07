//
//  M13InfiniteTabBar.swift
//  M13InfiniteTabBar
//
//  Created by Brandon McQuilkin on 8/29/14.
//  Copyright (c) 2014 BrandonMcQuilkin. All rights reserved.
//

import UIKit

/**The delegate that reponds to tab bar customization.*/
protocol M13InfiniteTabBarCustomizationDelegate {
    
    /**Sent to the delegate before the customizing modal view is displayed.
    @param tabBar The tab bar that is being customized.
    @param items The items on the customizing modal view.*/
    func infiniteTabBar(tabBar: M13InfiniteTabBar!, willBeginCustomizingItems items: [AnyObject]!)
    /**Sent to the delegate after the customizing modal view is displayed.
    @param tabBar The tab bar that is being customized.
    @param items The items on the customizing modal view.*/
    func infiniteTabBar(tabBar: M13InfiniteTabBar!, didBeginCustomizingItems items: [AnyObject]!)
    /**Sent to the delegate before the customizing modal view is dismissed.
    @param tabBar The tab bar that is being customized.
    @param items The items on the customizing modal view.
    @param changed true if the visible set of items on the tab bar changed; otherwise, false.*/
    func infiniteTabBar(tabBar: M13InfiniteTabBar!, willEndCustomizingItems items: [AnyObject]!, changed: Bool)
    /**Sent to the delegate after the customizing modal view is dismissed.
    @param tabBar The tab bar that is being customized.
    @param items The items on the customizing modal view.
    @param changed true if the visible set of items on the tab bar changed; otherwise, false.*/
    func infiniteTabBar(tabBar: M13InfiniteTabBar!, didEndCustomizingItems items: [AnyObject]!, changed: Bool)
}

/**The delegate that responds to changes in the tab bar's selection.*/
protocol M13InfiniteTabBarSelectionDelegate {
    /**Asks the selection delegate if an item should be selected.
    @param tabBar The tab bar that wants to select the given item.
    @param item The item that the tab bar is asking to select.
    @return Wether or not the item should be selected.*/
    func infiniteTabBar(tabBar:M13InfiniteTabBar!, shouldSelectItem item: M13InfiniteTabBarItem!) -> Bool
    /**Notifies the selection delegate that an item will be selected.
    @param tabBar The tab bar that will select the given item.
    @param item The item that the tab bar is selecting.*/
    func infiniteTabBar(tabBar:M13InfiniteTabBar!, willSelectItem item: M13InfiniteTabBarItem!)
    /**The delegate method run inside the animation block that performs animates the tab selection. Any animations run in this block will be run concurrently with the selection animation.
    @param tabBar The tab bar that performing an animation.
    @param item The item that the tab bar is animating the selection for.*/
    func infiniteTabBar(tabBar:M13InfiniteTabBar!, concurrentAnimationsForSelectingItem item: M13InfiniteTabBarItem!)
    /**Notifies the selection delegate that an item was selected.
    @param tabBar The tab bar that did select the given item.
    @param item The item that the tab bar selected.*/
    func infiniteTabBar(tabBar:M13InfiniteTabBar!, didSelectItem item: M13InfiniteTabBarItem!)
}

enum M13InfiniteTabBarLayout {
    case Infinite
    case Scrolling
    case Static
}

/**The tab bar. Works like `UITabBar`, but way cooler.*/
class M13InfiniteTabBar: UIView, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    //---------------------------------------
    /**@name Initalization*/
    //---------------------------------------
    
    /**Initalize the tab bar with the given frame.
    @return A new tab bar.*/
    override init() {
        super.init()
        self.setup()
    }
    
    /**Initalize the tab bar with the given frame.
    @param frame The frame to initalize the tab bar with.
    @return A new tab bar.*/
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    /**Initalize the tab bar with the given frame and items.
    @param frame The frame to initalize the tab bar with.
    @param items The items to initalize the tab bar with.
    @return A new tab bar.*/
    init(frame: CGRect, items: [M13InfiniteTabBarItem]) {
        super.init(frame: frame)
        self.items = items
        self.setup()
    }
    
    /**Initalize the tab bar with the given items.
    @param items The items to initalize the tab bar with.
    @return A new tab bar.*/
    init(items: [M13InfiniteTabBarItem]) {
        super.init()
        self.items = items
        self.setup()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        //Force Defaults
        self.translucent = true
        
        //Setup scroll view
        tabScrollView.frame = self.bounds
        tabScrollView.backgroundColor = UIColor.clearColor()
        tabScrollView.showsHorizontalScrollIndicator = false
        tabScrollView.showsVerticalScrollIndicator = false
        tabScrollView.userInteractionEnabled = true
        self.addSubview(tabScrollView)
        
        //Setup content view
        tabContainerView.frame = self.bounds
        tabScrollView.addSubview(tabContainerView)
        
        //Setup tap gesture for tab selection
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("singleTapCaptured:"))
        tapGestureRecognizer.cancelsTouchesInView = false
        tapGestureRecognizer.delegate = self
        tapGestureRecognizer.delaysTouchesBegan = false
        tapGestureRecognizer.delaysTouchesEnded = false
        tabScrollView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    //---------------------------------------
    /**@name Delegates*/
    //---------------------------------------

    /**The tab bar's customization delegate object.*/
    var customizationDelegate: M13InfiniteTabBarCustomizationDelegate?
    
    /**The tab bar's selection delegate object.*/
    var selectionDelegate: M13InfiniteTabBarSelectionDelegate?

    //---------------------------------------
    /**@name Configuring Tab Bar Items*/
    //---------------------------------------
    
    /**The items displayed on the tab bar.
    @note The items, instances of UITabBarItem, that are visible on the tab bar in the order they appear in this array. Any changes to this property are not animated. Use the setItems:animated: method to animate changes.*/
    var items: [M13InfiniteTabBarItem]! {
        get {
            return itemsStorage
        }
        set(newValue) {
            itemsStorage = newValue
            //Set indicies
            for i: Int in 0..<countElements(itemsStorage) {
                (itemsStorage[i] as M13InfiniteTabBarItem).index = i
            }
            if countElements(itemsStorage) > 0 {
                (itemsStorage[0] as M13InfiniteTabBarItem).selected = true
                selectedItem = itemsStorage[0]
            }
            itemsChangedSinceLastLayout = true
            self.updateTabLayout(false)
        }
    }
    
    /**The storage for the items property. This allows us to set the items internally with setItems(item:,animated:) without calling layout. by setting the items.*/
    var itemsStorage: [M13InfiniteTabBarItem]! = []

    /**The currently selected item on the tab bar. 
    @note Changing this property’s value provides visual feedback in the user interface, including the running of any associated animations. The selected item displays the tab bar item’s selectedImage image, using the tab bar’s selectedImageTintColor value. To prevent system coloring of an item, provide images using the UIImageRenderingModeAlwaysOriginal rendering mode.*/
    var selectedItem: M13InfiniteTabBarItem! {
        didSet {
            for i in 0..<countElements(items) {
                var item: M13InfiniteTabBarItem = items[i]
                if item == selectedItem {
                    if layoutType == M13InfiniteTabBarLayout.Static {
                        self.selectItem(item)
                    }
                    break
                }
            }
        }
    }
    
    /**Sets the items on the tab bar, with or without animation.
    @note If animated is true, the changes are dissolved or the reordering is animated—for example, removed items fade out and new items fade in. This method also adjusts the spacing between items.
    @param items: The items to display on the tab bar.
    @param animated: If true, animates the transition to the items; otherwise, does not.*/
    func setItems(items: [M13InfiniteTabBarItem]!, animated: Bool) {
        itemsStorage = items
        //Set indicies
        for i: Int in 0..<countElements(itemsStorage) {
            (itemsStorage[i] as M13InfiniteTabBarItem).index = i
        }
        if countElements(itemsStorage) > 0 {
            (itemsStorage[0] as M13InfiniteTabBarItem).selected = true
            selectedItem = itemsStorage[0]
        }
        itemsChangedSinceLastLayout = true
        self.updateTabLayout(animated)
    }
    
    /**Tab bar items that require user attention.
    @note Only tab bar items that are in the items array can be added to this array.*/
    var itemsRequiringAttention: [M13InfiniteTabBarItem]! = []
    
    /**Rotate all the tab bar items in the tab bar to the given angle.*/
    func rotateItemsToAngle(angle: CGFloat) {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            //Rotate the offscreen items:
            for item: M13InfiniteTabBarItem in self.items {
                item.rotateToAngle(angle)
            }
            //Rotate onscreen items
            for item: M13InfiniteTabBarItem in self.visibleItems {
                item.rotateToAngle(angle)
            }
        })
    }
    
    private var tabBarItemInsetsStorage: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
    /**The image inset for each edge.
    @return The insets to use to adjust the image position.*/
    func tabBarItemInsets() -> UIEdgeInsets! {
        return tabBarItemInsetsStorage
    }
    
    /**Sets the offset to use to adjust the image position.
    @param inset The new insets for the image.*/
    func setTabBarItemInsets(inset: UIEdgeInsets) {
        tabBarItemInsetsStorage = inset
        self.layoutSubviews()
    }
    
    //---------------------------------------
    /**@name Supporting User Customization of Tab Bars*/
    //---------------------------------------
    
    /**Presents a modal view allowing the user to customize the tab bar by adding, removing, and rearranging items on the tab bar.
    @note  Use this method to start customizing a tab bar. For example, create an Edit button that invokes this method when tapped. A modal view appears displaying all the items in items with a Done button at the top. Tapping the Done button dismisses the modal view. If the selected item is removed from the tab bar, the selectedItem property is set to nil. Set the delegate property to an object conforming to the UITabBarDelegate protocol to further modify this behavior.
    @param items The items to display on the modal view that can be rearranged. The items parameter should contain all items that can be added to the tab bar. Visible items not in items are fixed in place—they can not be removed or replaced by the user.*/
    func beginCustomizingItems(items: [AnyObject]!) {
        
    }
    
    /**Dismisses the modal view used to modify items on the tab bar.
    @note Typically, you do not need to use this method because the user dismisses the modal view by tapping the Done button.
    @param animated If true, animates the transition; otherwise, does not.
    @return true if items on the tab bar changed; otherwise, false.*/
    func endCustomizingAnimated(animated: Bool) -> Bool {
        return false
    }
    
    /**Returns a Boolean value indicating whether the user is customizing the tab bar.
    @return true if the user is currently customizing the items on the tab bar; otherwise, false. For example, by tapping an Edit button, a modal view appears allowing users to change the items on a tab bar. This method returns true if this modal view is visible.*/
    func isCustomizing() -> Bool {
        return false
    }
    
    //---------------------------------------
    /**@name Customizing Tab Bar Appearance*/
    //---------------------------------------
    
    /**Wether or not infinite scrolling is enabled.
    @note If there are more tabs than what can fit in the bar, then scrolling will still be enabled. This property just determines if it is infinite or not.*/
    var infiniteScrollingEnabled: Bool! = true
    
    /**The tint color to apply to the tab bar background.
    @note This color is applied to the visual effect view unless you set the translucent property to false. Then is is set to the background color property.*/
    var barTintColor: UIColor! = UIColor.clearColor() {
        didSet {
            if translucent {
                backgroundVisualEffectView!.contentView.backgroundColor = barTintColor
            } else {
                self.backgroundColor = barTintColor
            }
        }
    }
    
    /**The custom item width for tab bar items, in points. 
    @note To specify a custom width for tab bar items, set this property to a positive value, which the tab bar then uses directly. To specify system-defined tab bar item width, use a 0 value, which is the default value for this property. (If you specify a negative value, a tab bar interprets it as 0 and employs a system-defined width.)*/
    var itemWidth: CGFloat = 0.0
    
    /**A Boolean value that indicates whether the tab bar is translucent (true) or not (false).
    @note If the tab bar does not have a custom background image, the default value is true.
    If the tab bar does have a custom background image for which any pixel has an alpha value of less than 1.0, the default value is also true. The default value is false if the custom background image is entirely opaque.
    If you set this property to true on a tab bar with an opaque custom background image, the tab bar applies translucency to the image.
    If you set this property to false on a tab bar with a translucent custom background image, the tab bar provides an opaque background for your image and applies a blurring backdrop. The provided opaque background is black if the tab bar has UIBarStyleBlack style, white if the tab bar has UIBarStyleDefault, or the tab bar’s tint color (barTintColor) if you have defined one. The situation is identical if you set this property to false for a tab bar without a custom background image, except the tab bar does not apply a blurring backdrop.*/
    var translucent: Bool = true {
        didSet {
            if translucent {
                //Add the translucent view if not already added
                if let visualEffectView = backgroundVisualEffectView {
                    //Do nothing
                } else {
                    backgroundVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.ExtraLight))
                    backgroundVisualEffectView!.frame = self.bounds
                    self.addSubview(backgroundVisualEffectView!)
                }
            } else {
                //Remove the visual effect view if necessary
                if let visualEffectView = backgroundVisualEffectView {
                    visualEffectView.removeFromSuperview()
                    backgroundVisualEffectView = nil
                } else {
                    //Do nothing
                }
            }
        }
    }
    
    /**The background image for the tab bar.
    @note A stretchable background image is stretched; a non-stretchable background image is tiled (refer to the UIImageResizingMode enum in UIImage Class Reference). This image does not move when the tab bar is scrolled.
    A tab bar with a custom background image, even when translucent, does not draw a blur behind itself.*/
    var backgroundImage: UIImage! {
        didSet {
            if let imageView = backgroundImageView {
                if backgroundImage == nil {
                    imageView.removeFromSuperview()
                    backgroundImageView = nil
                } else {
                    imageView.image = nil
                    //Follow resizing mode
                    if backgroundImage.resizingMode == UIImageResizingMode.Tile {
                        imageView.backgroundColor = UIColor(patternImage: backgroundImage)
                    } else {
                        imageView.image = backgroundImage
                    }
                }
            } else {
                if backgroundImage != nil {
                    backgroundImageView = UIImageView(frame: self.bounds)
                    //Follow resizing mode
                    if backgroundImage.resizingMode == UIImageResizingMode.Tile {
                        backgroundImageView!.backgroundColor = UIColor(patternImage: backgroundImage)
                    } else {
                        backgroundImageView!.image = backgroundImage
                    }
                    //Add it in the proper location.
                    if let visualEffectView = backgroundVisualEffectView {
                        self.insertSubview(backgroundImageView!, aboveSubview: visualEffectView)
                    } else {
                        self.addSubview(backgroundImageView!)
                        self.sendSubviewToBack(backgroundImageView!)
                    }
                }
            }
        }
    }
    
    //---------------------------------------
    /**@name Subviews*/
    //---------------------------------------

    /**The scroll view that is the core of the tab bar.*/
    private let tabScrollView: UIScrollView = UIScrollView()
    
    /**The view that is the main container in the scroll view. It holds all of the tabs.*/
    private let tabContainerView: UIView = UIView()
    
    /**The background image view, if the background image is set. If we are also translucent, this will appear over the visual effect view.*/
    private var backgroundImageView: UIImageView?
    
    /**The background visual effect view if we are translucent.*/
    var backgroundVisualEffectView: UIVisualEffectView? {
        didSet(oldValue) {
            //Remove old view from tab bar
            if let oldView = oldValue {
                oldView.removeFromSuperview()
            }
            //Add the new one to the tab bar
            if let newView = backgroundVisualEffectView {
                newView.frame = self.bounds
                self.addSubview(newView)
                self.sendSubviewToBack(newView)
            }
        }
    }
    
    //---------------------------------------
    /**@name Interaction*/
    //---------------------------------------
    
    /**The previously selected tab.*/
    var previouslySelectedItem: M13InfiniteTabBarItem?
    
    /**The tap gesture recognizer*/
    private var tapGestureRecognizer: UITapGestureRecognizer!
    
    /**Called when a single tap is captured on the tab scroll view.*/
    internal func singleTapCaptured(recognizer: UITapGestureRecognizer) {
        //Calculate the touch location in the tabContainerView coordiates. We have to do this manually, as there seems to be a bug with UIScrollView where the content offset isn't taken into account.
        var location: CGPoint = recognizer.locationInView(nil)
        location.x += (tabScrollView.contentOffset.x - tabContainerView.frame.origin.x)
        
        //Have we selected the current item?
        if let item = self.itemAtLocation(location) {
            if layoutType == M13InfiniteTabBarLayout.Static {
                self.selectItem(item)
            } else {
                self.setSelectedItem(item)
            }
        }
        
    }
    
    /**Handles the animations for setting the selected item.*/
    private func setSelectedItem(item: M13InfiniteTabBarItem) {
        
    }
    
    /**Handles selection of an item at the given index.*/
    private func selectItemAtIndex(index: Int) {
        //Invalid index
        if index >= countElements(items) || index < 0 {
            return
        }
        
        //Are we selecting the selected item?
        if selectedItem.index == index {
            self.setSelectedItem(self.selectedItem)
        }
        
        //What is the shortest distance between the selected distance and the new index.
        let indexDistance: Int = shortestDistanceBetweenItemsAtIndicies(selectedItem.index, b: index)
        //What is the width of an item.
    }
    
    /**Handles all the animation of selecting an item.*/
    private func selectItem(item: M13InfiniteTabBarItem) {
        //Should we allow the selection?
        var shouldUpdate: Bool = true
        if let delegate = self.selectionDelegate {
            shouldUpdate = delegate.infiniteTabBar(self, shouldSelectItem: item)
        }
        
        if shouldUpdate {
            //Notify the delegate that we will be selecting an item.
            if let delegate = self.selectionDelegate {
                delegate.infiniteTabBar(self, willSelectItem: item)
            }
            
            //Start animations
            UIView.beginAnimations("TabChangedAnimation", context: nil)
            UIView.setAnimationDuration(0.5)
            UIView.setAnimationDelegate(self)
            UIView.setAnimationDidStopSelector("didSelectItem")
            
            //Perform the concurrent animations
            if let delegate = self.selectionDelegate {
                delegate.infiniteTabBar(self, concurrentAnimationsForSelectingItem: item)
            }
            
            //Animate the tab change, we need to deselect the prevoiusly selected tab, and select the current tab.
            for anItem: M13InfiniteTabBarItem in items {
                if anItem == item {
                    anItem.selected = true
                } else {
                    anItem.selected = false
                }
            }
            
            for anItem: M13InfiniteTabBarItem in visibleItems  {
                if anItem == item {
                    anItem.selected = true
                } else {
                    anItem.selected = false
                }
            }
            
            previouslySelectedItem = item
            
            UIView.commitAnimations()
        } else {
            //If we are a static layout do nothing, no need to bring the old tab back into view.
        }
    }
    
    private func didSelectItem() {
        //Notify the delegate
        if let delegate = self.selectionDelegate {
            delegate.infiniteTabBar(self, didSelectItem: selectedItem)
        }
    }
    
    //---------------------------------------
    /**@name Calculations*/
    //---------------------------------------
    
    private func itemAtLocation(location: CGPoint) -> M13InfiniteTabBarItem? {
        //First try to find the subview at the given location.
        for item: M13InfiniteTabBarItem in tabContainerView.subviews as [M13InfiniteTabBarItem] {
            if CGRectContainsPoint(item.frame, location) {
                return item
            }
        }
        //No item, find the nearest item to the point.
        var distance: CGFloat = CGFloat.max
        var closest: M13InfiniteTabBarItem?
        for item: M13InfiniteTabBarItem in tabContainerView.subviews as [M13InfiniteTabBarItem] {
            let newDistance: CGFloat = self.distanceBetweenRect(item.frame, andPoint: location)
            if distance > newDistance {
                distance = newDistance
                closest = item
            }
        }
        return closest
    }
    
    private func distanceBetweenRect(rect: CGRect, andPoint point: CGPoint) -> CGFloat {
        //Is the point inside the rect? If so the distance is zero
        if CGRectContainsPoint(rect, point) {
            return 0.0
        }
        
        //Which point in the rect is closest to the point?
        var closestPoint: CGPoint = rect.origin
        if rect.origin.x + rect.size.width < point.x {
            closestPoint.x += rect.size.width //The point is to the far right
        } else if point.x > rect.origin.x {
            closestPoint.x = point.x //Above or below
        }
        if rect.origin.y + rect.size.height < point.y {
            closestPoint.y += rect.size.height; //The point is below
        } else if point.y > rect.origin.y {
            closestPoint.y = point.y; //The point is straight left or right
        }
        
        // we've got a closest point; now pythagorean theorem
        // distance^2 = [closest.x,y - closest.x,point.y]^2 + [closest.x,point.y - point.x,y]^2
        // i.e. [closest.y-point.y]^2 + [closest.x-point.x]^2
        let a: CGFloat = pow(closestPoint.y - point.y, 2.0);
        let b: CGFloat = pow(closestPoint.x - point.x, 2.0);
        return sqrt(a + b);
    }
    
    /**What is the shortest distance between two items in the tab bar? With direction?*/
    private func shortestDistanceBetweenItemsAtIndicies(a: Int, b: Int) -> Int {
        return min(modulo(a - b, m: countElements(items)), modulo(b - a, m: countElements(items)))
    }
    
    private func modulo(x: Int, m: Int) -> Int {
        var n = m
        if n < 0 {
            n = -n;
        }
        var r: Int = x % n;
        return r < 0 ? r + n : r;
    }
    
    //---------------------------------------
    /**@name Layout*/
    //---------------------------------------
    
    /**The type of layout that the infinite tab bar currently is.*/
    private var layoutType: M13InfiniteTabBarLayout = M13InfiniteTabBarLayout.Infinite
    
    /**The items that are subviews of the tab bar item container.*/
    private var visibleItems: [M13InfiniteTabBarItem] = []
    
    /**Wether or not the tab bar items changed after the last layout.*/
    private var itemsChangedSinceLastLayout: Bool = false
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //Visual effect view
        if let visualEffectView = backgroundVisualEffectView {
            visualEffectView.frame = self.bounds
        }
        
        //Background image view
        if let imageView = backgroundImageView {
            imageView.frame = self.bounds
        }
        
        //Scroll view
        tabScrollView.frame = CGRectMake(self.tabBarItemInsets().left, self.tabBarItemInsets().top, self.bounds.size.width - self.tabBarItemInsets().left - self.tabBarItemInsets().right, self.frame.size.height - self.tabBarItemInsets().top - self.tabBarItemInsets().bottom)
        
        //Update the tab layout. Default is animated.
        self.updateTabLayout(true)
    }
    
    private func updateTabLayout(animated: Bool) {
        //Lets calculate the total width of all the tabs.
        var simulatedItemWidth: CGFloat = 0.0
        if itemWidth != 0.0 {
            simulatedItemWidth = itemWidth
        } else {
            simulatedItemWidth = 64.0
        }
        
        let totalWidth: CGFloat = simulatedItemWidth * CGFloat(countElements(items))
        
        //What kind of tab bar do we use
        if totalWidth <= tabScrollView.frame.size.width {
            //Static layout
            layoutType = M13InfiniteTabBarLayout.Static
            self.layoutTabsStatically(animated)
        } else if !infiniteScrollingEnabled {
            //Non infinite scrolling
            layoutType = M13InfiniteTabBarLayout.Scrolling
            self.layoutTabsForNonInfiniteScrolling(animated)
        } else {
            //Infinite scrolling
            layoutType = M13InfiniteTabBarLayout.Infinite
        }
    }
    
    
    //---------------------------------------
    /**@name Infinite*/
    //---------------------------------------
    
    
    
    //---------------------------------------
    /**@name Non-Infinite*/
    //---------------------------------------
    
    private func layoutTabsForNonInfiniteScrolling(animated: Bool) {
        
    }
    
    private func layoutTabsStatically(animated: Bool) {
        //Disable scrolling
        tabScrollView.scrollEnabled = false
        tabScrollView.contentSize = tabScrollView.frame.size
        tabContainerView.frame = CGRectMake(0.0, 0.0, tabScrollView.contentSize.width, tabScrollView.contentSize.height)
        
        if itemsChangedSinceLastLayout {
            if animated {
                //We are infinite, and need to redo all the items
                UIView.animateWithDuration(0.15, animations: { () -> Void in
                    //First hide all the currently visible items
                    self.tabContainerView.alpha = 0.0
                    }, completion: { (completed) -> Void in
                        if completed {
                            //Then remove all the items from the superview
                            for item: M13InfiniteTabBarItem in self.visibleItems {
                                item.removeFromSuperview()
                            }
                            //Add each item to the container view
                            var newVisibleItems: [M13InfiniteTabBarItem] = []
                            for item in self.items {
                                var newItem: M13InfiniteTabBarItem = item.copy() as M13InfiniteTabBarItem
                                newVisibleItems.append(newItem)
                                self.tabContainerView.addSubview(newItem)
                            }
                            self.visibleItems = newVisibleItems
                            //Layout each item
                            self.layoutTabsStaticallyLayoutHelper()
                            //Show each item
                            UIView.animateWithDuration(0.15, animations: { () -> Void in
                                self.tabContainerView.alpha = 1.0
                                }, completion: { (completed) -> Void in
                                    //All done
                            })
                        }
                        
                })
            } else {
                //Hide everything.
                self.tabContainerView.alpha = 1.0
                //Then remove all the items from the superview
                for item: M13InfiniteTabBarItem in self.visibleItems {
                    item.removeFromSuperview()
                }
                //Add each item to the container view
                var newVisibleItems: [M13InfiniteTabBarItem] = []
                for item in self.items {
                    var newItem: M13InfiniteTabBarItem = item.copy() as M13InfiniteTabBarItem
                    newVisibleItems.append(newItem)
                    self.tabContainerView.addSubview(newItem)
                }
                self.visibleItems = newVisibleItems
                //Layout each item
                self.layoutTabsStaticallyLayoutHelper()
                //Show everything
                self.tabContainerView.alpha = 1.0
            }
            //We reset all the tabs
            itemsChangedSinceLastLayout = false
        } else {
            //We just need to move the tabs around.
            if animated {
                UIView.animateWithDuration(0.15, animations: { () -> Void in
                    self.layoutTabsStaticallyLayoutHelper()
                }, completion: { (completed) -> Void in
                    //Do nothing
                })
            } else {
                self.layoutTabsStaticallyLayoutHelper()
            }
        }
    }
    
    private func layoutTabsStaticallyLayoutHelper() {
        
        //Get the item width
        var calculatedItemWidth: CGFloat = 0.0
        if itemWidth != 0.0 {
            calculatedItemWidth = itemWidth
        } else {
            //Tab bar style based on interface idom:
            if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
                //Stretched
                calculatedItemWidth = tabContainerView.frame.size.width / CGFloat(countElements(items))
            } else {
                //Centered
                calculatedItemWidth = 64.0
            }
        }
        
        //Determine starting x value
        var x: CGFloat = (tabContainerView.frame.size.width - (calculatedItemWidth * CGFloat(countElements(visibleItems)))) / 2.0
        //Layout the items
        for item: M13InfiniteTabBarItem in self.visibleItems {
            item.frame = CGRectMake(x, 0, calculatedItemWidth, tabContainerView.frame.size.height)
            x += calculatedItemWidth
        }
    }
    
}
