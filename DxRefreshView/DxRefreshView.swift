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

    internal var actionHandler:ActionHandler?;
    
    private var _color:UIColor = UIColor.darkGray;
    private var refreshLayer:DxRefreshLayer!;
    private var textLabel:UILabel!;
    private let defaultHeaderHeight:CGFloat = 60.0;
    private var originInsertTop:CGFloat = -1;
    
    private var pullText = "下拉刷新数据...";
    private var releaseText = "释放刷新数据...";
    private var refreshingText = "正在刷新数据...";
    
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
        textLabel.frame = CGRect(origin:CGPoint(x:left+26,y:0),size: CGSize(width:textWidth, height:14))
    }
    
    private func setPullStateText(){
        if textLabel.text != pullText {
            textLabel.text = pullText;
        }
    }
    
    private func setRefreshingStateText(){
        textLabel.text = refreshingText;
    }
    
    private func setReleaseStateText(){
        if textLabel.text != releaseText {
            textLabel.text = releaseText;
        };
    }
    
    private func startLoadingAniamtion(){
        if refreshLayer.state == LayerState.LOADING {
            return;
        }
        refreshLayer.startLoaingAnimation();
        setRefreshingStateText();
        if actionHandler != nil {
            actionHandler!();
        }
    }
    
    private func didScroll(scrollView:UIScrollView){
        
        if refreshLayer.state == LayerState.LOADING || originInsertTop == -1 {
            return;
        }
        
        if -scrollView.contentOffset.y >= originInsertTop + defaultHeaderHeight && !scrollView.isDragging {
            setScrollViewContentInsetForLoading(scrollView:scrollView);
            startLoadingAniamtion();
            return;
        }
        
        if scrollView.isDragging {
            var contentOffsetY = -scrollView.contentOffset.y - originInsertTop;
            refreshLayer.offsetY = contentOffsetY;
            if contentOffsetY < defaultHeaderHeight {
                setPullStateText();
            }else{
                setReleaseStateText();
            }
            if contentOffsetY > defaultHeaderHeight {
                contentOffsetY = defaultHeaderHeight;
            }
            self.frame = CGRect(origin:CGPoint(x:0,y:-contentOffsetY),size: CGSize(width:UIScreen.main.bounds.width, height:-scrollView.contentOffset.y-scrollView.contentInset.top));
            textLabel.frame = CGRect(origin:CGPoint(x:textLabel.frame.origin.x, y:contentOffsetY/2-7), size: CGSize(width:textLabel.frame.size.width, height:textLabel.frame.size.height));
            refreshLayer.frame = CGRect(origin:CGPoint(x:refreshLayer.frame.origin.x, y:contentOffsetY/2-defaultHeaderHeight/2),size: CGSize(width:refreshLayer.frame.size.width,height:refreshLayer.frame.size.height));
            textLabel.layer.opacity = Float(contentOffsetY/defaultHeaderHeight);
        }
    }


    private func setScrollViewContentInsetForLoading(scrollView:UIScrollView) {
        var currentInsets:UIEdgeInsets = scrollView.contentInset;
        currentInsets.top = originInsertTop + defaultHeaderHeight;
        UIView.animate(withDuration: 0.3, delay: 0, options:[.allowUserInteraction,.beginFromCurrentState], animations:{
                scrollView.contentInset = currentInsets;
            }, completion: nil);
    }

    
    public func beginRefreshing() {
        refreshLayer.beginRefreshing();
        setRefreshingStateText();
        setScrollViewContentInsetForLoading(scrollView: (self.superview as? UIScrollView)!);
        self.frame = CGRect(origin:CGPoint(x:0,y:-defaultHeaderHeight), size:CGSize(width:self.frame.size.width, height:defaultHeaderHeight));
        textLabel.frame = CGRect(origin:CGPoint(x:textLabel.frame.origin.x,y:(defaultHeaderHeight-14)/2), size:CGSize(width:textLabel.frame.size.width, height:14));
        self.textLabel.layer.opacity = 1.0;
        if actionHandler != nil {
            actionHandler!();
        }
    }
    
    public func endRefreshing(){
   
        if(refreshLayer.state != LayerState.LOADING){
            return;
        }
        let scrollView:UIScrollView = self.superview as! UIScrollView;
        UIView.animate(withDuration:0.3 , animations: {
            self.frame = CGRect(origin:CGPoint(x:0,y:-self.defaultHeaderHeight), size:CGSize(width:self.frame.size.width, height:self.defaultHeaderHeight));
            self.textLabel.layer.opacity = 0.0;
            var inset:UIEdgeInsets = scrollView.contentInset;
            inset.top = self.originInsertTop;
            scrollView.contentInset = inset;
        }) { (finished:Bool) in
            self.refreshLayer.removeAllAnimations();
            self.refreshLayer.reset();
            self.setPullStateText();
        }
    }

    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentOffset" {
            didScroll(scrollView: object as! UIScrollView)
        }
        
        if "contentInset" == keyPath {
            let newTop = (change?[NSKeyValueChangeKey.newKey] as! NSValue).uiEdgeInsetsValue.top;
            if (originInsertTop == -1){
                originInsertTop = newTop;
            }
        }
    }
}
