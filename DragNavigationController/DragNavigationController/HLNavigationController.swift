//
//  HLNaviViewController.swift
//  Navi
//
//  Created by 黄海龙 on 16/5/12.
//  Copyright © 2016年 jsvest. All rights reserved.
//

import UIKit

func T_Window() -> UIWindow { return UIApplication.shared.keyWindow! }

func T_WindowView() -> UIView {
    
    if var windowView = UIApplication.shared.keyWindow?.rootViewController?.view {
        
        let ctrl = UIApplication.shared.keyWindow?.rootViewController;
        
        while (true) {
        
            if ((ctrl?.presentedViewController) != nil) {
                windowView = (ctrl?.presentedViewController?.view)!; break
            } else {
                break
            }
        }
        
        return windowView
    }else {
        
        return UIView()
    }
}

func width() -> CGFloat { return UIScreen.main.bounds.size.width}
func height() -> CGFloat { return UIScreen.main.bounds.size.height}
let TOUCH_DISTANCE: CGFloat = 80

// 拖拽返回的效果 3D效果/类似美团外卖 平移效果/雪球
enum PopAnimationType {
    case popAnimationTypeFromeBehind , popAnimationTypeliner
}

class HLNavigationController: UINavigationController, UINavigationControllerDelegate,UIGestureRecognizerDelegate{
    
    internal var popAnimationType:PopAnimationType?
    internal var canDragBack:Bool?   // 是否能拖拽
    
    var snapArray: NSMutableArray?
    var startPoint: CGPoint?
    var backgroundView: UIView?
    var blackMask: UIView?
    var lastScreenShotImageView: UIImageView?
    var isMoving: Bool?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
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
        
        self.interactivePopGestureRecognizer?.isEnabled = false
        let panRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(didPanGestureRecognizer(_:)))
        panRecognizer.delegate = self
        self.view.addGestureRecognizer(panRecognizer)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if snapArray?.count == 0 {
            if let captureImage = capture() {
                self.snapArray?.add(captureImage)
            }
        }
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        
        if let captureImage = capture() {
            self.snapArray?.add(captureImage)
        }
        
        if self.viewControllers.count == 1{
                viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: animated)
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        self.snapArray?.removeLastObject()
        return super.popViewController(animated: animated)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (self.viewControllers.count <= 1 || self.canDragBack == false) {
            return false
        }
        return true
    }
    
    
    func didPanGestureRecognizer(_ pan: UIPanGestureRecognizer) {
        
        if (self.viewControllers.count <= 1 || self.canDragBack == false){
            return
        }
        
        let touchPoint = pan.location(in: T_Window())
        if pan.state == .began {
            self.startPoint = touchPoint
            self.isMoving = true
            addSnapView()
        } else if(pan.state == .ended){
            if (CGFloat(touchPoint.x - self.startPoint!.x) > TOUCH_DISTANCE) {
                UIView.animate(withDuration: 0.3, animations: { 
                        self.doMoveViewWithX(width())
                    }, completion: { finished in
                        self.isMoving = false
                        _ = self.popViewController(animated: false)
                        var frame = T_WindowView().frame
                        frame.origin.x = 0
                        T_WindowView().frame = frame
                })
            }else{
                UIView.animate(withDuration: 0.3, animations: { 
                        self.doMoveViewWithX(0)
                    }, completion: { finished in
                        self.isMoving = false
                        self.backgroundView?.isHidden = true
                })
            }
            return
        }else if(pan.state == .cancelled){
            
            UIView.animate(withDuration: 0.3, animations: { 
                    self.doMoveViewWithX(0)
                }, completion: { finished in
                    self.isMoving = false
                    self.backgroundView?.isHidden = true
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
            self.backgroundView?.backgroundColor = UIColor.black
            T_WindowView().superview?.insertSubview(self.backgroundView!, belowSubview: T_WindowView())
            self.blackMask = UIView.init(frame: CGRect(x: 0, y: 0, width: width() , height: height()))
            self.blackMask?.backgroundColor = UIColor.black
            self.backgroundView?.addSubview(self.blackMask!)
        }
        
        self.backgroundView?.isHidden = false
        if self.lastScreenShotImageView != nil {
            self.lastScreenShotImageView?.removeFromSuperview()
        }
        
        let lastScreenShot = self.snapArray?.lastObject as? UIImage
        self.lastScreenShotImageView = UIImageView(image: lastScreenShot)
        self.lastScreenShotImageView?.frame = CGRect(x: 0, y: 0, width: width(),height: height())
        self.backgroundView?.insertSubview(self.lastScreenShotImageView!, belowSubview: self.blackMask!)
    }
    
    func doMoveViewWithX(_ x:CGFloat){
        var x = x
        x = x > width() ? width():x
        x = x < 0 ? 0 : x
        var frame = T_WindowView().frame
        frame.origin.x = x
        T_WindowView().frame = frame
        
        animationFromBehind(x) // 3D
//        animationLiner(x)  // 线性
    }
    
    func animationFromBehind(_ x: CGFloat){
        let coeffiient = width() * 25
        let scale = (x/coeffiient) + 0.96
        let alpha = 0.4 - (x/800)
        self.lastScreenShotImageView?.transform = CGAffineTransform(scaleX: scale, y: scale)
        self.blackMask?.alpha = alpha
    }
    
    func animationLiner(_ x: CGFloat){
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
        UIGraphicsBeginImageContextWithOptions(CGSize(width: T_WindowView().frame.width, height: T_WindowView().frame.height), T_WindowView().isOpaque, 0.0)
        
        if let currentCtx = UIGraphicsGetCurrentContext() {
            T_WindowView().layer.render(in: currentCtx)
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
