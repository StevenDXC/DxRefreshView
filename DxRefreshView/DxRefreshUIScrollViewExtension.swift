//
//  RefreshUIScrollViewExtension.swift
//  DxRefreshView
//
//  Created by Miutrip on 2016/9/12.
//  Copyright © 2016年 dxc. All rights reserved.
//

import UIKit

public extension UIScrollView {
    
    private struct dx_associatedKeys {
        static var refreshHeader = "refreshHeader"
        static var observer = "observer"
    }
    
    private var refreshHeader: DxRefreshView? {
        get {
            return objc_getAssociatedObject(self, &dx_associatedKeys.refreshHeader) as? DxRefreshView;
        }
        
        set {
            objc_setAssociatedObject(self, &dx_associatedKeys.refreshHeader, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var observer: NSObject? {
        get {
            return objc_getAssociatedObject(self, &dx_associatedKeys.observer) as? NSObject;
        }
        
        set {
            objc_setAssociatedObject(self, &dx_associatedKeys.observer, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func addRefreshHeader(color:UIColor,action:(()->Void)){
        let refreshHeader:DxRefreshView = DxRefreshView();
        refreshHeader.color = color;
        refreshHeader.actionHandler = action;
        self.insertSubview(refreshHeader, at: 0);
        self.refreshHeader = refreshHeader;
        self.addObserver(refreshHeader, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.new, context: nil);
    }
    
    public func beginRefreshing(){
        self.refreshHeader?.beginRefreshing();
    }
    
    public func endRefreshing(){
        self.refreshHeader?.endRefreshing();
    }
    
    public func removeScrollObserver(){
        self.removeObserver(self.refreshHeader!, forKeyPath:"contentOffset");
    }

}
