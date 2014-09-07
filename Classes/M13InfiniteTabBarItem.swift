//
//  M13InfiniteTabBarItem.swift
//  M13InfiniteTabBar
//
//  Created by Brandon McQuilkin on 8/27/14.
//  Copyright (c) 2014 BrandonMcQuilkin. All rights reserved.
//

import UIKit

/**The infinite tab bar equilivent to UITabBarItem*/
class M13InfiniteTabBarItem: UIView, Equatable {
    
    //---------------------------------------
    /**@name Initializing an Item*/
    //---------------------------------------
    
    /**Creates and returns a new item with the specified title, unselected image, and selected image.
    @note If no selectedImage is provided, image is used as both the unselected and selected image. By default, the actual unselected and selected images are automatically created from the alpha values in the source images. To prevent system coloring, provide images with UIImageRenderingModeAlwaysOriginal.
    @param title The item’s title. If nil, a title is not displayed.
    @param image The item’s unselected image. If nil, an image is not displayed.
    @param selectedImage The item’s selected image. If nil, uses the value of image.
    @return Newly initialized item with the specified title, unselected image, and selected image.
    */
    init(title: String!, image: UIImage!, selectedImage: UIImage!) {
        self.title = title
        self.image = image
        self.selectedImage = selectedImage
        //Initalize with approximate size.
        super.init(frame: CGRectMake(0, 0, 70, 48))
        self.setup()
    }
    
    /**Duplicate a `M13InfiniteTabBarItem`.*/
    override func copy() -> AnyObject {
        //Create a new instance
        let newItem = M13InfiniteTabBarItem(title: title, image: image, selectedImage: selectedImage)
        //Set its properties
        newItem.backgroundImage = backgroundImage
        newItem.titleFont = titleFont
        newItem.selectedImageOverlay = selectedImageOverlay
        newItem.selectedImageTintColor = selectedImageTintColor
        newItem.selectedTitleColor = selectedTitleColor
        newItem.unselectedImageOverlay = unselectedImageOverlay
        newItem.unselectedImageTintColor = unselectedImageTintColor
        newItem.unselectedTitleColor = unselectedTitleColor
        newItem.attentionImageOverlay = attentionImageOverlay
        newItem.attentionImageTintColor = attentionImageTintColor
        newItem.attentionTitleColor = attentionTitleColor
        newItem.selected = selected
        newItem.requiresUserAttention = requiresUserAttention
        newItem.containerView.transform = containerView.transform
        return newItem
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        //Setup the container view.
        containerView.frame = self.bounds
        containerView.backgroundColor = UIColor.clearColor()
        self.addSubview(containerView)
        
        //Setup the icon.
        imageView.contentMode = UIViewContentMode.Center
        imageView.image = self.iconForCurrentState()
        containerView.addSubview(self.imageView)
        
        //Setup the title
        titleLabel.text = self.title
        titleLabel.backgroundColor = UIColor.clearColor()
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.font = self.titleFont
        titleLabel.textColor = self.labelColorForCurrentState() 
        containerView.addSubview(self.titleLabel)
        
        //Force layout and draw
        self.setNeedsLayout()
    }
    
    //---------------------------------------
    /**@name Badge*/
    //---------------------------------------
    
    /**Text that is displayed in the corner of the item with a oval. Use this to set the badge's string so that the badge will automatically be shown and hidden.*/
    var badgeValue: String! = "" {
        didSet {
            if badgeValue == "" {
                //Remove the badgeview if necessary.
                if badgeView.superview == self {
                    UIView.animateWithDuration(0.2, animations: { () -> Void in
                            self.badgeView.alpha = 0.0
                        }, completion: { (complete) -> Void in
                            if complete {
                                self.badgeView.removeFromSuperview()
                                self.badgeView.text = self.badgeValue
                            }
                    })
                }
            } else {
                //Show the view if necessary
                if self.badgeView.superview != self {
                    badgeView.alpha = 0.0
                    imageView.addSubview(badgeView)
                    badgeView.text = self.badgeValue
                    UIView.animateWithDuration(0.2, animations: { () -> Void in
                        self.badgeView.alpha = 1.0
                    }, completion: { (complete) -> Void in
                        
                    })
                }
            }
        }
    }
    
    /**The storage to hold the badge view.*/
    private var badgeViewStorage: M13BadgeView?
    /**The badge that is displayed around tab bar item.*/
    var badgeView: M13BadgeView {
        get {
            if let temp = badgeViewStorage {
                return temp
            } else {
                //We need to setup a badge
                badgeViewStorage = M13BadgeView()
                badgeViewStorage!.horizontalAlignment = M13BadgeViewHorizontalAlignmentNone
                badgeViewStorage!.verticalAlignment = M13BadgeViewVerticalAlignmentNone
                badgeViewStorage!.frame.size.height = 18.0
                badgeViewStorage!.font = UIFont.systemFontOfSize(12.0)
                return badgeViewStorage!
            }
        }
    }
    
    //---------------------------------------
    /**@name Customizing Appearance*/
    //---------------------------------------
    
    /*The image used to represent the item.
    
    This image can be used to create other images to represent this item on the bar—for example, a selected and unselected image may be derived from this image. You should set this property before adding the item to a bar. The default value is nil.*/
    let image: UIImage!
    
    /**The image displayed when the tab bar item is selected.
    
    If nil, the value from the image property on the superclass, UIBarItem, is used as both the unselected and selected image.
    
    By default, the actual selected image is automatically created from the alpha values in the source image. To prevent system coloring, provide images with UIImageRenderingModeAlwaysOriginal.*/
    let selectedImage: UIImage!
    
    /**The image that is overlayed onto the icon when it is selected. This should be the same size as the icon.*/
    var selectedImageOverlay: UIImage? {
        didSet {
            if selected {
                imageView.image = self.iconForCurrentState()
            }
        }
    }
    
    /**The tint color that is overlayed onto the icon when it is selected. This will show if the `selectedImageOverlay` is not set.*/
    var selectedImageTintColor: UIColor = UIColor(red: 0.02, green: 0.47, blue: 1.0, alpha: 1.0) {
        didSet {
            if selected {
                imageView.image = self.iconForCurrentState()
            }
        }
    }
    
    /**The image that is overlayed onto the icon when it is unselected. This should be the same size as the icon.*/
    var unselectedImageOverlay: UIImage? {
        didSet {
            if !selected && !requiresUserAttention {
                imageView.image = self.iconForCurrentState()
            }
        }
    }
    
    /**The tint color that is overlayed onto the icon when it is unselected. This will show if the `unselectedImageOverlay` is not set. */
    var unselectedImageTintColor: UIColor = UIColor(red: 0.56, green: 0.56, blue: 0.56, alpha: 1.0) {
        didSet {
            if !selected && !requiresUserAttention {
                imageView.image = self.iconForCurrentState()
            }
        }
    }
    
    /**The image that is overlayed onto the icon when the tab requires user attention.*/
    var attentionImageOverlay: UIImage? {
        didSet {
            if requiresUserAttention {
                imageView.image = self.iconForCurrentState()
            }
        }
    }
    
    /**The tint color that is overlayed onto the icon the tab requires user attention.*/
    var attentionImageTintColor: UIColor = UIColor(red: 0.98, green: 0.24, blue: 0.15, alpha: 1.0) {
        didSet {
            if requiresUserAttention {
                imageView.image = self.iconForCurrentState()
            }
        }
    }
    
    private var imageInsetsStorage: UIEdgeInsets = UIEdgeInsetsMake(4.0, 4.0, 18.0, 4.0)
    /**The image inset for each edge.
    @return The insets to use to adjust the image position.*/
    func imageInsets() -> UIEdgeInsets! {
        return imageInsetsStorage
    }
    
    /**Sets the offset to use to adjust the image position.
    @param inset The new insets for the image.*/
    func setImageInsets(inset: UIEdgeInsets) {
        imageInsetsStorage = inset
        self.layoutSubviews()
    }
    
    /** The image that will show as the tab bar item's background.
    
    The background Image moves with the tabs. The default is no background, the image would show instead of the tab bar's background.*/
    var backgroundImage: UIImage? {
        didSet {
            if let newBackground = backgroundImage {
                //Display the new background, and create the image view if need be
                if let view = backgroundImageView {
                    view.image = newBackground
                } else {
                    backgroundImageView = UIImageView(frame: self.bounds)
                    backgroundImageView!.contentMode = UIViewContentMode.ScaleAspectFill
                    backgroundImageView!.image = backgroundImage
                    self.addSubview(backgroundImageView!)
                }
            } else {
                //Remove the background image view if need be
                if let view = backgroundImageView {
                    view.removeFromSuperview()
                    backgroundImageView = nil
                }
            }
        }
    }
    
    /**The title displayed on the item.
    You should set this property before adding the item to a bar. The default value is nil.*/
    let title: String!
    
    /**The color of the title text when the item is selected.*/
    var selectedTitleColor: UIColor = UIColor(red: 0.02, green: 0.47, blue: 1.0, alpha: 1.0) {
        didSet {
            if selected {
                titleLabel.textColor = self.labelColorForCurrentState()
            }
        }
    }
    
    /**The color of the title text when the item is unselected.*/
    var unselectedTitleColor: UIColor = UIColor(red: 0.56, green: 0.56, blue: 0.56, alpha: 1.0) {
        didSet {
            if !selected && !requiresUserAttention {
                titleLabel.textColor = self.labelColorForCurrentState()
            }
        }
    }
    
    /** The color of the icon text when the tab requires user attention.*/
    var attentionTitleColor: UIColor = UIColor(red: 0.98, green: 0.24, blue: 0.15, alpha: 1.0) {
        didSet {
            if requiresUserAttention {
                titleLabel.textColor = self.labelColorForCurrentState()
            }
        }
    }
    
    /**The font of the title. When changing the font, it is suggested to keep the default font point size.*/
    var titleFont: UIFont = UIFont.systemFontOfSize(9.0) {
        didSet {
            self.titleLabel.font = titleFont
        }
    }
    
    private var titleInsetStorage: UIEdgeInsets = UIEdgeInsetsMake(36.0, 2.0, 5.0, 2.0)
    /**Returns the insets to use to adjust the title position.
    @return The insets to use to adjust the title position.*/
    func titleInsets() -> UIEdgeInsets {
        return titleInsetStorage
    }
    
    /**Sets the offset to use to adjust the title position.
    @param inset The new insets for the title.*/
    func setTitleInsets(inset: UIEdgeInsets) {
        titleInsetStorage = inset
        self.layoutSubviews()
    }
    
    //---------------------------------------
    /**@name Getting and Setting Properties*/
    //---------------------------------------
    
    /**A Boolean value indicating whether the item is enabled.
    If false, the item is drawn partially dimmed to indicate it is disabled. The default value is true.*/
    var enabled: Bool = true {
        didSet {
            imageView.image = self.iconForCurrentState()
            titleLabel.textColor = self.labelColorForCurrentState()
        }
    }
    
    /**Used to determine if the item is selected or not.
    @warning This should only be set by `M13InfiniteTabBar`, setting this property will result in unexpected behavior. If you want to select a tab, go through `M13InfinteTabBar`.*/
    var selected: Bool = false {
        didSet {
            imageView.image = self.iconForCurrentState()
            titleLabel.textColor = self.labelColorForCurrentState()
        }
    }
    
    /**Used to determine wether the view controller the tab represents requires user attention.
    @warning This should only be set by `M13InfiniteTabBar`, setting this property will result in unexpected behavior. If you want a tab to ask for user attention, go through `M13InfinteTabBar`.*/
    var requiresUserAttention: Bool = false {
        didSet {
            imageView.image = self.iconForCurrentState()
            titleLabel.textColor = self.labelColorForCurrentState()
        }
    }
    
    /**The index of the infinite tab bar item in a tab bar. Use this instead of tag, since that can be modified outside of M13InfiniteTabBar.*/
    internal var index: Int = NSNotFound
    
    
    //---------------------------------------
    /**@name Subviews*/
    //---------------------------------------
    
    /**The image view that shows the icon. By default it's content mode is set to UIViewContentModeCenter.*/
    private var imageView: UIImageView! = UIImageView()
    
    /**The label that shows the title.*/
    private var titleLabel: UILabel! = UILabel()
    
    /**The view that contains the badge, title, and icon. This allows for easy rotation of contents.*/
    private let containerView: UIView! = UIView()
    
    /**The background image view. this background view does not rotate with the tab bar item if it rotates on device rotation.*/
    private var backgroundImageView: UIImageView?
    
    //---------------------------------------
    /**@name Layout*/
    //---------------------------------------
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //Container
        containerView.bounds.size = self.bounds.size
        containerView.center = CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height / 2.0)
        
        //Image View
        imageView.frame = CGRectMake(imageInsets().left, imageInsets().top, self.frame.size.width - imageInsets().left - imageInsets().right, self.frame.size.height - imageInsets().top - imageInsets().bottom)
        
        //Label
        var labelRatio: CGFloat = 19.0 / 96.0 //Ratio accounts for insets. (measured from UITabBar)
        titleLabel.frame = CGRectMake(titleInsets().left, titleInsets().top, self.frame.size.width - titleInsets().left - titleInsets().right, self.frame.size.height - titleInsets().top - titleInsets().bottom)
        
        //Badge View
        if let badge = badgeViewStorage {
            var xCenter: CGFloat = ceil((self.frame.size.width / 2.0) + (image.size.width / 2.0) + (badge.frame.size.width / 8.0))
            var yCenter: CGFloat = ceil(imageView.frame.origin.y - ((imageView.frame.size.height - image.size.height) / 2.0) - (badgeView.frame.size.height / 4.0))
            //We need to keep the badge below the top of the item.
            if yCenter - (badge.frame.size.height / 2.0) < 0 {
                yCenter = ceil(badgeView.bounds.size.height / 2.0)
            }
            
            badge.center = CGPointMake(xCenter, yCenter)
        }
    }
    
    /**Rotate the item to the given angle.
    @warning This should only be used by `M13InfiniteTabBar`, using this method will result in unexpected behavior. Rotation of the items is handled by `M13InfiniteTabBar`.
    @param angle The angle to rotate the item to. */
    func rotateToAngle(angle: CGFloat) {
        containerView.transform = CGAffineTransformMakeRotation(angle)
    }
    
    //---------------------------------------
    /**@name Drawing*/
    //---------------------------------------
    private func iconForCurrentState() -> UIImage {
        
        var icon: UIImage = UIImage()
        //Get the proper image
        if selected {
            icon = selectedImage
        } else {
            icon = image
        }
        
        //Selected the background that will be masked if the rendering mode allows tint
        if icon.renderingMode == UIImageRenderingMode.AlwaysOriginal {
            return icon
        }
        
        //Prep to draw
        var drawImage: UIImage?
        var tintColor: UIColor = UIColor.clearColor()
        
        if !enabled {
            tintColor = UIColor.lightGrayColor()
        } else if requiresUserAttention {
            drawImage = attentionImageOverlay
            tintColor = attentionImageTintColor
        } else if selected {
            drawImage = selectedImageOverlay
            tintColor = selectedImageTintColor
        } else {
            drawImage = unselectedImageOverlay
            tintColor = unselectedImageTintColor
        }
        
        UIGraphicsBeginImageContextWithOptions(icon.size, false, icon.scale)
        
        //Draw the background
        if let anImage = drawImage {
            //Draw the image centered
            anImage.drawInRect(CGRectMake((icon.size.width - anImage.size.width) / 2.0, (icon.size.height - anImage.size.height) / 2.0, anImage.size.width, anImage.size.height))
        } else {
            //Fill
            tintColor.setFill()
            UIRectFill(CGRectMake(0, 0, icon.size.width, icon.size.height))
        }
        
        let iconBackground: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //Create the mask
        
        var context = CGBitmapContextCreate(nil, CGImageGetWidth(icon.CGImage), CGImageGetHeight(icon.CGImage), 8, 0, nil, CGBitmapInfo.fromRaw(CGImageAlphaInfo.Only.toRaw())!)
        CGContextDrawImage(context, CGRectMake(0, 0, icon.size.width * icon.scale, icon.size.height * icon.scale), icon.CGImage)
        let mask: CGImageRef = CGBitmapContextCreateImage(context)
        
        //Create the image
        let finalIcon: UIImage = UIImage(CGImage: CGImageCreateWithMask(iconBackground.CGImage, mask), scale: icon.scale, orientation: icon.imageOrientation)
        
        //Releaseing mask and context not needed as CoreFoundation objects are now managed by ARC.
        
        return finalIcon
    }
    
    private func labelColorForCurrentState() -> UIColor! {
        //Color
        if !enabled {
            return UIColor.lightGrayColor()
        } else if requiresUserAttention {
            return attentionTitleColor
        } else if selected {
            return selectedTitleColor
        } else {
            return unselectedTitleColor
        }
    }
}

 func == (lhs: M13InfiniteTabBarItem, rhs: M13InfiniteTabBarItem) -> Bool {
    //Can we determine if the images are equal? I feel like we need more than the title.
    if lhs.title == rhs.title{
        return true
    }
    return false
}
