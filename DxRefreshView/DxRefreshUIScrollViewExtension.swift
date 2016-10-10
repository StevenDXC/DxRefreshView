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
    }
    
    internal var refreshHeader: DxRefreshView? {
        get {
            return objc_getAssociatedObject(self, &dx_associatedKeys.refreshHeader) as? DxRefreshView;
        }
        
        set {
            objc_setAssociatedObject(self, &dx_associatedKeys.refreshHeader, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    internal func setRefreshHeader(refreshHeader:DxRefreshView){
        self.insertSubview(refreshHeader, at: 0);
        self.refreshHeader = refreshHeader;
        self.addObserver(refreshHeader, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.new, context: nil);
        self.addObserver(refreshHeader, forKeyPath: "contentInset", options: NSKeyValueObservingOptions.new,context: nil);
    }
    
    public func removeScrollObserver(){
        self.removeObserver(self.refreshHeader!, forKeyPath:"contentOffset");
        self.removeObserver(self.refreshHeader!, forKeyPath: "contentInset");
    }

}
