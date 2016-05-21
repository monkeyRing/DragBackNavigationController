//
//  HLNaviViewController.swift
//  Navi
//
//  Created by 黄海龙 on 16/5/12.
//  Copyright © 2016年 jsvest. All rights reserved.
//

import UIKit

func T_Window() -> UIWindow {return UIApplication.sharedApplication().keyWindow!}

func T_WindowView() -> UIView {
    
    if let windowView = UIApplication.sharedApplication().keyWindow?.rootViewController?.view {
        return windowView
    }else {
        return UIView()  //
    }
}

func width() -> CGFloat { return UIScreen.mainScreen().bounds.size.width}
func height() -> CGFloat { return UIScreen.mainScreen().bounds.size.height}
let TOUCH_DISTANCE: CGFloat = 80

enum PopAnimationType {
    case PopAnimationTypeFromeBehind , PopAnimationTypeliner
}

class HLNaviViewController: UINavigationController, UINavigationControllerDelegate,UIGestureRecognizerDelegate{
    
    internal var popAnimationType:PopAnimationType? // 拖拽返回的动画效果 3D效果/类似美团外卖 平移效果/雪球
    internal var canDragBack:Bool?   // 是否能拖拽
    
    var snapArray: NSMutableArray?
    var startPoint: CGPoint?
    var backgroundView: UIView?
    var blackMask: UIView?
    var lastScreenShotImageView: UIImageView?
    var isMoving: Bool?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        snapArray = NSMutableArray()
        canDragBack = true
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
         snapArray = NSMutableArray()
         canDragBack = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        snapArray = NSMutableArray()
        canDragBack = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.interactivePopGestureRecognizer?.enabled = false
        let panRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(didPanGestureRecognizer(_:)))
        panRecognizer.delegate = self
        self.view.addGestureRecognizer(panRecognizer)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        if snapArray?.count == 0 {
            if let captureImage = capture() {
                self.snapArray?.addObject(captureImage)
            }
        }
    }
    
    override func pushViewController(viewController: UIViewController, animated: Bool) {
        
        if let captureImage = capture() {
            self.snapArray?.addObject(captureImage)
        }
        
        if self.viewControllers.count == 1{
                viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: animated)
    }
    
    override func popViewControllerAnimated(animated: Bool) -> UIViewController? {
        self.snapArray?.removeLastObject()
        return super.popViewControllerAnimated(animated)
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if (self.viewControllers.count <= 1 || self.canDragBack == false) {
            return false
        }
        return true
    }
    
    
    func didPanGestureRecognizer(pan: UIPanGestureRecognizer) {
        
        if (self.viewControllers.count <= 1 || self.canDragBack == false){
            return
        }
        
        let touchPoint = pan.locationInView(T_Window())
        if pan.state == .Began {
            self.startPoint = touchPoint
            self.isMoving = true
            addSnapView()
        } else if(pan.state == .Ended){
            if (CGFloat(touchPoint.x - self.startPoint!.x) > TOUCH_DISTANCE) {
                UIView.animateWithDuration(0.3, animations: { 
                        self.doMoveViewWithX(width())
                    }, completion: { finished in
                        self.isMoving = false
                        self.popViewControllerAnimated(false)
                        var frame = T_WindowView().frame
                        frame.origin.x = 0
                        T_WindowView().frame = frame
                })
            }else{
                UIView.animateWithDuration(0.3, animations: { 
                        self.doMoveViewWithX(0)
                    }, completion: { finished in
                        self.isMoving = false
                        self.backgroundView?.hidden = true
                })
            }
            return
        }else if(pan.state == .Cancelled){
            UIView.animateWithDuration(0.3, animations: { 
                    self.doMoveViewWithX(0)
                }, completion: { finished in
                    self.isMoving = false
                    self.backgroundView?.hidden = true
            })
            return
        }
        
        
        if self.isMoving == true {
            self.doMoveViewWithX(CGFloat(touchPoint.x - self.startPoint!.x))
        }
    }
    
    func addSnapView(){
        if self.backgroundView == nil {
            self.backgroundView = UIView.init(frame: self.view.bounds)
            self.backgroundView?.backgroundColor = UIColor.blackColor()
            T_WindowView().superview?.insertSubview(self.backgroundView!, belowSubview: T_WindowView())
            self.blackMask = UIView.init(frame: CGRectMake(0, 0, width() , height()))
            self.blackMask?.backgroundColor = UIColor.blackColor()
            self.backgroundView?.addSubview(self.blackMask!)
        }
        
        self.backgroundView?.hidden = false
        if self.lastScreenShotImageView != nil {
            self.lastScreenShotImageView?.removeFromSuperview()
        }
        
        let lastScreenShot = self.snapArray?.lastObject as? UIImage
        self.lastScreenShotImageView = UIImageView(image: lastScreenShot)
        self.lastScreenShotImageView?.frame = CGRectMake(0, 0, width(),height())
        self.backgroundView?.insertSubview(self.lastScreenShotImageView!, belowSubview: self.blackMask!)
    }
    
    
    func doMoveViewWithX(var x:CGFloat){
        x = x > width() ? width():x
        x = x < 0 ? 0 : x
        var frame = T_WindowView().frame
        frame.origin.x = x
        T_WindowView().frame = frame
        
        animationFromBehind(x) // 3D
//        animationLiner(x)  // 线性
    }
    
    func animationFromBehind(x: CGFloat){
        let coeffiient = width() * 25
        let scale = (x/coeffiient) + 0.96
        let alpha = 0.4 - (x/800)
        self.lastScreenShotImageView?.transform = CGAffineTransformMakeScale(scale, scale)
        self.blackMask?.alpha = alpha
    }
    
    func animationLiner(x: CGFloat){
        let coefficient = x / 2
        var screenShotImageViewFrame = self.lastScreenShotImageView?.frame
        screenShotImageViewFrame?.origin.x = -width()/2 + coefficient
        self.lastScreenShotImageView?.frame = screenShotImageViewFrame!
        self.blackMask?.alpha = 0.3
    }
    
    /**
     截屏
     
     - returns: 截屏图片
     */
    func capture() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(T_WindowView().frame.width, T_WindowView().frame.height), T_WindowView().opaque, 0.0)
        
        if let currentCtx = UIGraphicsGetCurrentContext() {
            T_WindowView().layer.renderInContext(currentCtx)
        }
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
    
    deinit {
        self.snapArray = nil
        self.backgroundView?.removeFromSuperview()
        self.backgroundView = nil
    }
    
}
