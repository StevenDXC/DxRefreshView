//
//  ViewController.swift
//  DxRefreshView
//
//  Created by Miutrip on 2016/9/12.
//  Copyright © 2016年 dxc. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDataSource{

    private var tableView:UITableView!;
    private var dataSource:NSMutableArray = ["1","2","3"];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white;
        
        tableView = UITableView();
        tableView.frame = self.view.bounds;
        tableView.dataSource = self;
        self.view.addSubview(tableView);

        
        let refreshHeader:DxRefreshView = DxRefreshView();
        refreshHeader.color = UIColor.blue;
        refreshHeader.actionHandler = {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.0, execute: {
                self.dataSource.add(String(self.dataSource.count+1));
                self.tableView.reloadData();
                self.tableView.refreshHeader?.endRefreshing();
            })
        };
        tableView.setRefreshHeader(refreshHeader: refreshHeader);
        tableView.refreshHeader?.beginRefreshing();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell");
        if cell == nil{
            cell = UITableViewCell(style:UITableViewCellStyle.default,reuseIdentifier:"cell");
        }
        cell?.textLabel?.text = dataSource.object(at: indexPath.row) as? String;
        return cell!;
    }

}

