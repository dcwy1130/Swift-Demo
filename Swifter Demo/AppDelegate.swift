//
//  AppDelegate.swift
//  Swifter Demo
//
//  Created by Mac on 16/7/12.
//  Copyright (c) 2016年 GroupFly. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        UINavigationBar.appearance().barTintColor = UIColor(white: 0.1, alpha: 1.0)         // 背景颜色
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()       // 返回字体颜色
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor() , NSFontAttributeName : UIFont.boldSystemFontOfSize(18)]    // title标题颜色和字体
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        let APView = ZDXAdvertisementPageView(frame: self.window!.frame, SkipControlAlignment: .RightTop, SkipControlStyle: .Annular, Duration: 5, ImageURL: NSURL(string: "http://huidiantong.groupfly.cn/ImgUpload/Main/2016_08/201608170325397.png")!, addToView: self.window!.rootViewController!.view)
        // 设置点击广告图片代理
        APView.delegate = {
            let msg = $0 == 0 ? "跳过" : "广告页"
            print("点击了\(msg)")
        }
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}


extension UIViewController {
//    viewDidLoad
    
    // App启动时调用的方法
    class func ZDX_swizzleViewDidLoad() {
        struct ZDX_swizzleToken {
            static var onceToken: dispatch_once_t = 0
        }
        dispatch_once(&ZDX_swizzleToken.onceToken) {
            // 用于获取该类型的方法实现
            let cls: AnyClass! = UIViewController.self
            
            let originalSelector = #selector(UIViewController.viewDidLoad)
            let swizzledSelector = #selector(UIViewController.ZDX_viewDidLoad)
            
            let originalMethod = class_getInstanceMethod(cls, originalSelector)
            let swizzledMethod = class_getInstanceMethod(cls, swizzledSelector)
            
            method_exchangeImplementations(originalMethod, swizzledMethod)
            
        }
    }
    
    override public class func initialize() {
        // +initialize 会在当前类以及它的子类被初始化时调用，保证安全性
        UIViewController.ZDX_swizzleViewDidLoad()
    }    
    
    public func ZDX_viewDidLoad() {
        print("Swizzle Come in ...")
        let returnButtonItem = UIBarButtonItem()
        returnButtonItem.title = "返回";
        returnButtonItem.setTitleTextAttributes([ NSFontAttributeName : UIFont.systemFontOfSize(15)], forState: UIControlState.Normal)
        self.navigationItem.backBarButtonItem = returnButtonItem;
        ZDX_viewDidLoad()
    }
}


//// 钩子方法
//extension UIControl {
//    // App启动时调用此方法
//    class func ZDX_swizzleSendAction() {
//        struct ZDX_swizzleToken {
//            static var onceToken: dispatch_once_t = 0
//        }
//        dispatch_once(&ZDX_swizzleToken.onceToken) {
//            let cls: AnyClass! = UIControl.self
//            
//            let originalSelector = Selector("sendAction(_:to:forEvent:)")
//            let swizzledSelector = Selector("ZDX_sendAction(_:to:forEvent:)")
//            
//            let originalMethod = class_getInstanceMethod(cls, originalSelector)
//            let swizzledMethod = class_getInstanceMethod(cls, swizzledSelector)
//            // 交换方法的具体实现
//            method_exchangeImplementations(originalMethod, swizzledMethod)
//        }
//    }
//    
//    // 需要替换的方法
//    public func ZDX_sendAction(action: Selector, to: AnyObject!, forEvent: UIEvent!) {
//        
//        // 全局计数器
//        struct ZDX_buttonTapCounter {
//            static var count: Int = 0
//        }
//        
//        ZDX_buttonTapCounter.count += 1
//        println("您点击了\(ZDX_buttonTapCounter.count)次")
//        ZDX_sendAction(action, to: to, forEvent: forEvent)
//    }
//    
//    override public class func initialize() {
//        // +initialize 会在当前类以及它的子类被初始化时调用，保证安全性
//        
//        UIControl.ZDX_swizzleSendAction()
//    }
//}


