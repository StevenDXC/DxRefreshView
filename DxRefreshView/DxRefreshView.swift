//
//  DxRefreshView.swift
//  DxRefreshView
//
//  Created by Miutrip on 2016/9/12.
//  Copyright © 2016年 dxc. All rights reserved.
//

import UIKit

typealias ActionHandler = ()->Void;

class DxRefreshView: UIView {

    public var actionHandler:ActionHandler?;
    
    private var _color:UIColor = UIColor.darkGray;
    private var refreshLayer:DxRefreshLayer!;
    private var textLabel:UILabel!;
    private let defaultHeaderHeight:CGFloat = 48;
    
    internal var color:UIColor{
        get{
            return _color;
        }
        set{
            _color = newValue;
            refreshLayer.color = _color;
            textLabel.textColor = _color;
            setNeedsDisplay();
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame:frame);
        self.frame = CGRect(origin:CGPoint(x:0,y:0),size:CGSize(width:UIScreen.main.bounds.width,height:0));
        initSubViews();
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initSubViews(){
        
        refreshLayer = DxRefreshLayer();
        refreshLayer.contentsScale = UIScreen.main.scale;
        refreshLayer.color = _color;
        self.layer.addSublayer(refreshLayer);
        
        
        textLabel = UILabel();
        textLabel.textColor = _color;
        textLabel.font = UIFont.systemFont(ofSize: 13);
        textLabel.textAlignment = NSTextAlignment.center;
        textLabel.layer.opacity = 0.0;
        self.addSubview(textLabel)
        
        setPullStateText();
        
        let text:NSString = NSString.init(string:textLabel.text!);
        let textWidth:CGFloat = text.boundingRect(with: CGSize(width:0,height:defaultHeaderHeight), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes:[NSFontAttributeName: textLabel.font], context: nil).width;
        let left:CGFloat = (self.bounds.width-textWidth-26)/2;
        
        refreshLayer.frame = CGRect(origin:CGPoint(x:left,y:0),size: CGSize(width:24, height:defaultHeaderHeight));
        textLabel.frame = CGRect(origin:CGPoint(x:left+26,y:0),size: CGSize(width:textWidth, height:defaultHeaderHeight))
    }
    
    private func setPullStateText(){
        textLabel.text = "下拉刷新数据...";
    }
    
    private func setRefreshingStateText(){
        textLabel.text = "正在刷新数据...";
    }
    
    private func setReleaseStateText(){
        textLabel.text = "释放刷新数据...";
    }
    
    private func startLoadingAniamtion(){
        refreshLayer.startLoaingAnimation();
        setRefreshingStateText();
        if actionHandler != nil {
            actionHandler!();
        }
    }
    
    private func didScroll(scollView:UIScrollView){
        if refreshLayer.state == LayerState.LOADING {
            return;
        }
        
        if scollView.contentOffset.y < 0{
            var progress:CGFloat = -scollView.contentOffset.y/48.0;
            if self.frame.height < 48 {
                self.frame = CGRect(origin:CGPoint(x:0,y:0),size: CGSize(width:UIScreen.main.bounds.width, height:-scollView.contentOffset.y));
                textLabel.layer.opacity = Float(progress);
            }
            
            if progress > 1 {
                progress = 1;
                textLabel.layer.opacity = 1;
                self.frame = CGRect(origin:CGPoint(x:0,y:0),size: CGSize(width:UIScreen.main.bounds.width, height:48));
                setReleaseStateText();
            }
            refreshLayer.progress = progress;
        }
        
    
        if scollView.contentOffset.y == 0 {
            startLoadingAniamtion();
        }
    }

    
    public func beginRefreshing() {
        refreshLayer.beginRefreshing();
        setRefreshingStateText();
        UIView.animate(withDuration: 0.3) { 
            self.frame = CGRect(origin:CGPoint(x:0,y:0),size:CGSize(width:UIScreen.main.bounds.width,height:48));
            self.textLabel.layer.opacity = 1.0;
        }
        if actionHandler != nil {
            actionHandler!();
        }
    }
    
    public func endRefreshing(){
   
        if(refreshLayer.state != LayerState.LOADING){
            return;
        }
        
        UIView.animate(withDuration:0.3 , animations: {
            self.textLabel.layer.opacity = 0.0;
            self.transform = CGAffineTransform(translationX: 0, y: -48);
        }) { (finished:Bool) in
            self.refreshLayer.removeAllAnimations();
            self.refreshLayer.reset();
            self.setPullStateText();
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3, execute: {
                self.transform = CGAffineTransform(translationX: 0,  y:0);
                self.frame = CGRect(origin:CGPoint(x:0,y:0),size:CGSize(width:UIScreen.main.bounds.width,height:0));
            })
        }
    }

    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentOffset" {
            didScroll(scollView: object as! UIScrollView)
        }
    }
}
