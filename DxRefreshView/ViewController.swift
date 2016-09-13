//
//  ViewController.swift
//  DxRefreshView
//
//  Created by Miutrip on 2016/9/12.
//  Copyright © 2016年 dxc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private var scrollView:UIScrollView!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView = UIScrollView();
        scrollView.frame = self.view.bounds;
        scrollView.addRefreshHeader(color: UIColor.blue) { 
            print("refreshing...");
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.0, execute: {
                self.scrollView.refreshHeader?.endRefreshing();
            })

        };
        scrollView.contentSize = CGSize(width:self.view.bounds.width,height:1000);
        self.view.addSubview(scrollView);
        self.scrollView.refreshHeader?.beginRefreshing();
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        scrollView.removeScrollObserver();
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

