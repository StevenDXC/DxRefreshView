//
//  RefreshLayer.swift
//  DxRefreshView
//
//  Created by Miutrip on 2016/9/12.
//  Copyright © 2016年 dxc. All rights reserved.
//

import UIKit

enum LayerState : Int{
    case PULL_TO_TRANSITION = 0, PULL_TO_ARC, RELEASED,LOADING
}

class DxRefreshLayer: CALayer {

    public var state:LayerState!;
    public var color:UIColor!;
    public var _progress:CGFloat!;
    
    private let lineWidth:CGFloat = 1.3;
    private let defaultRadius:CGFloat = 6.0;
    private var lineLength:CGFloat!,angle:CGFloat!;
    private var centerX:CGFloat!,centerY:CGFloat!;
    private var left:CGFloat!,right:CGFloat!,top:CGFloat!;
    private var moveDistance:CGFloat!;
    
    internal var progress:CGFloat{
        get {
            return _progress;
        }
        set {
            _progress = newValue;
            if(state == LayerState.PULL_TO_TRANSITION && _progress > 0.5){
                state = LayerState.PULL_TO_ARC;
            }
            
            if(state == LayerState.PULL_TO_ARC && _progress <= 0.5){
                state = LayerState.PULL_TO_TRANSITION;
            }
            
            if(state == LayerState.PULL_TO_ARC){
                angle = (_progress-0.5)*2*150;
                if(angle >= 150){
                    angle = 150;
                    state = LayerState.RELEASED;
                }
            }
            setNeedsDisplay();
        }
    }
  
    override static func needsDisplay(forKey key:String) -> Bool {
        if ("progress" == key) {
            return true;
        }
        
        if ("color" == key) {
            return true;
        }
        return super.needsDisplay(forKey: key);
    }

    
    override public func draw(in ctx: CGContext) {
        objc_sync_enter(self)
        ctx.saveGState()
        ctx.setShouldAntialias(true)
        ctx.setAllowsAntialiasing(true)
        ctx.setFillColor(UIColor.clear.cgColor)
        ctx.setStrokeColor(self.color.cgColor)
        ctx.setLineWidth(self.lineWidth)
        
        if(state == LayerState.PULL_TO_TRANSITION){
            drawPullStateWithContext(ctx:ctx);
        }
        
        if(state == LayerState.PULL_TO_ARC){
            drawPullState2WithContext(ctx: ctx);
        }
        
        if(state == LayerState.RELEASED || state == LayerState.LOADING){
            drawReleaseStateWithContext(ctx: ctx);
        }

        
        ctx.drawPath(using: CGPathDrawingMode.stroke)
        ctx.restoreGState()
        objc_sync_exit(self)
    }
    
    private func initData(){
        if(lineLength == nil){
            let width:CGFloat  = self.bounds.width;
            let height:CGFloat = self.bounds.height;
    
            centerX = self.bounds.size.width/2;
            centerY = self.bounds.size.height/2;
            
            lineLength = defaultRadius*2;
    
            left = (width - defaultRadius*2)/2.0;
            top = (height - defaultRadius*2)/2.0;
            right = left + defaultRadius*2;
            moveDistance = lineLength/2+top+2;
        }
    }

    private func playRotateAnimation(){
        let rotateAnimation:CABasicAnimation = CABasicAnimation();
        rotateAnimation.keyPath = "transform.rotation.z";
        rotateAnimation.isRemovedOnCompletion = false;
        rotateAnimation.duration = 0.8;
            rotateAnimation.repeatCount = .infinity;
        rotateAnimation.fillMode = kCAFillModeRemoved;
        rotateAnimation.fromValue = NSNumber.init(value: 0.0);
        rotateAnimation.toValue = NSNumber.init(value:2*Float(M_PI));
        self.add(rotateAnimation, forKey: nil);
    }
    
    private func drawPullStateWithContext(ctx:CGContext){
        
        initData();
        let leftLineY:CGFloat = self.bounds.size.height+2.0-moveDistance*_progress*2;
        let rightLineY:CGFloat = -lineLength-2+moveDistance*_progress*2;
    
        ctx.move(to: CGPoint(x:left,y:leftLineY));
        ctx.addLine(to: CGPoint(x:left,y:leftLineY+lineLength));
    
        ctx.move(to: CGPoint(x:right,y:rightLineY));
        ctx.addLine(to: CGPoint(x:right,y:rightLineY+lineLength));
    
        ctx.move(to: CGPoint(x:left-2,y:leftLineY+2));
        ctx.addLine(to: CGPoint(x:left,y:leftLineY));
    
        ctx.move(to: CGPoint(x:right+2,y:rightLineY+lineLength-2));
        ctx.addLine(to: CGPoint(x:right,y:rightLineY+lineLength));
    
    }
    
    private func drawPullState2WithContext(ctx:CGContext){
        
        let radian:CGFloat = CGFloat(CGFloat(M_PI))/180.0*(180+angle);
        let rx:CGFloat = cos(radian)*defaultRadius;
        let ry:CGFloat = sin(radian)*defaultRadius;
    
        let lx:CGFloat = centerX + rx - 3*sin((angle+30)/180.0 * CGFloat(CGFloat(M_PI)));
        let ty:CGFloat = centerY + ry + 3*cos((angle+30)/180.0 * CGFloat(CGFloat(M_PI)));
    
        let radian2:CGFloat = CGFloat(CGFloat(M_PI))/180.0*angle;
        let rx2:CGFloat = cos(radian2)*defaultRadius;
        let ry2:CGFloat = sin(radian2)*defaultRadius;
    
        let ra2x:CGFloat = centerX + rx2 + 3*cos((angle-60)/180.0 * CGFloat(CGFloat(M_PI)));
        let ra2y:CGFloat = centerY + ry2 + 3*sin((angle-60)/180.0 * CGFloat(CGFloat(M_PI)));
    
        //left line
        let bottom:CGFloat = self.bounds.size.height-top+defaultRadius;
        ctx.move(to: CGPoint(x:left,y:bottom-(angle/150.0*lineLength)));
        ctx.addLine(to: CGPoint(x:left,y:bottom-lineLength));
    
            //right line
        ctx.move(to: CGPoint(x:right,y:top-defaultRadius+(angle/150.0*lineLength)));
        ctx.addLine(to: CGPoint(x:right,y:top-defaultRadius+lineLength));
    
            //lef arrow
        ctx.move(to: CGPoint(x:lx,y:ty));
        ctx.addLine(to: CGPoint(x:centerX + rx,y:centerY + ry));
    
            //right arrow
        ctx.move(to: CGPoint(x:ra2x,y:ra2y));
        ctx.addLine(to: CGPoint(x:centerX + rx2,y:centerY+ry2));
    
            //bottom arc
        ctx.move(to: CGPoint(x:centerX+defaultRadius,y:centerY));
        ctx.addArc(center: CGPoint(x:centerX,y:centerY), radius: defaultRadius, startAngle: 0, endAngle:angle/180.0*CGFloat(CGFloat(M_PI)), clockwise: false);
            //top arc
        ctx.move(to: CGPoint(x:left,y:centerY));
        ctx.addArc(center: CGPoint(x:centerX,y:centerY), radius: defaultRadius, startAngle: CGFloat(CGFloat(M_PI)), endAngle:angle/180.0*CGFloat(CGFloat(M_PI))-CGFloat(CGFloat(M_PI)), clockwise: false);
    }
    
    private func drawReleaseStateWithContext(ctx:CGContext)
    {
        let radian:CGFloat = CGFloat(M_PI)/180.0*330.0;
        let rx:CGFloat = cos(radian)*defaultRadius;
        let ry:CGFloat = sin(radian)*defaultRadius;
    
        let radian2:CGFloat = CGFloat(M_PI)/180.0*150.0;
        let rx2:CGFloat = cos(radian2)*defaultRadius;
        let ry2:CGFloat = sin(radian2)*defaultRadius;
    
        let ra2x:CGFloat = centerX + rx2 + 3*cos(90/180.0 * CGFloat(M_PI));
        let ra2y:CGFloat = centerY + ry2 + 3*sin(90/180.0 * CGFloat(M_PI));
    
        ctx.move(to: CGPoint(x:centerX + rx - 3*sin(CGFloat(M_PI)),y:centerY + ry + 3*cos(CGFloat(M_PI))));
        ctx.addLine(to: CGPoint(x:centerX + rx,y:centerY + ry));
    
        ctx.move(to: CGPoint(x:ra2x,y:ra2y));
        ctx.addLine(to: CGPoint(x:centerX + rx2,y:centerY+ry2));
    
        ctx.move(to: CGPoint(x:left,y:centerY));
        ctx.addArc(center: CGPoint(x:centerX,y:centerY), radius: defaultRadius, startAngle: CGFloat(M_PI), endAngle: 150.0/180.0*CGFloat(M_PI)-CGFloat(M_PI), clockwise: false);
    
        ctx.move(to: CGPoint(x:centerX+defaultRadius,y:centerY));
        ctx.addArc(center: CGPoint(x:centerX,y:centerY), radius: defaultRadius, startAngle: 0, endAngle: 150.0/180.0*CGFloat(M_PI), clockwise: false);
    }
    
    
    public func startLoaingAnimation(){
        if(state != LayerState.RELEASED || state == LayerState.LOADING){
            return;
        }
        playRotateAnimation();
        state = LayerState.LOADING;
    }
    
    public func beginRefreshing(){
        initData();
        state = LayerState.LOADING;
        setNeedsDisplay();
        playRotateAnimation();
    }
    
    public func reset(){
        _progress = 0;
        angle = 0;
        state = LayerState.PULL_TO_TRANSITION;
        setNeedsDisplay();
    }
    
}
