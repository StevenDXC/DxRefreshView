//
//  RefreshLayer.swift
//  DxRefreshView
//
//  Created by Miutrip on 2016/9/12.
//  Copyright © 2016年 dxc. All rights reserved.
//

import UIKit

enum LayerState : Int{
    case PULL_TO_TRANSITION = 0, PULL_TO_ARC,PULL_TO_ROTATE,LOADING
}

class DxRefreshLayer: CALayer {

    public var state:LayerState!;       //current state
    public var color:UIColor!;
    public let lineWidth:CGFloat = 1.3;
    public let arcRadius:CGFloat = 6.0;
    public let arrowLenth:CGFloat = 3.0;

    private let endAngle:CGFloat = 150.0;
    
    private var height:CGFloat!;
    private var _offsetY:CGFloat!;      //pull down offset
    private var lineLength:CGFloat!;
    private var angle:CGFloat!,rotateAngle:CGFloat = 0.0;
    private var centerX:CGFloat!,centerY:CGFloat!;
    private var left:CGFloat!,right:CGFloat!,top:CGFloat!;
    private var moveDistance:CGFloat!;                      //line transiton distance
    
    internal var offsetY:CGFloat{
        get {
            return _offsetY;
        }
        set {
            _offsetY = newValue;
            let rate = _offsetY/self.bounds.height;
            if rate < 0.5 {
                state = LayerState.PULL_TO_TRANSITION;
                angle = 0;
            }
            
            if rate >= 0.5 && rate <= 1 {
                state = LayerState.PULL_TO_ARC;
                angle = (rate-0.5)*2*endAngle;
            }
            
            if rate > 1 {
                state = LayerState.PULL_TO_ROTATE;
                angle = endAngle;
                rotateAngle = (rate-1.0)*180;
            }
            
            setNeedsDisplay();
        }
    }
  
    override static func needsDisplay(forKey key:String) -> Bool {
        if "progress" == key || "color" == key || "lineWidth" == key || "arcRadius" == key {
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
            drawPullDownLineWithContext(ctx:ctx);
        }
        
        if(state == LayerState.PULL_TO_ARC){
            drawLineToArcWithContext(ctx: ctx);
        }
        
        if(state == LayerState.PULL_TO_ROTATE || state == LayerState.LOADING){
            drawReleaseStateWithContext(ctx: ctx);
        }
        
        ctx.drawPath(using: CGPathDrawingMode.stroke)
        ctx.restoreGState()
        objc_sync_exit(self)
    }
    
    private func initData(){
        if(lineLength == nil){
            let width:CGFloat = self.bounds.width;
            height = self.bounds.height;
    
            centerX = self.bounds.size.width/2;
            centerY = self.bounds.size.height/2;
            
            lineLength = arcRadius*2;
            
            left = (width - lineLength)/2.0;
            top = (height - lineLength)/2.0;
            right = left + lineLength;
            moveDistance = lineLength/2+top;
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
    
    //draw tow lines and arrow, two arrow silde in
    private func drawPullDownLineWithContext(ctx:CGContext){
        
        initData();
        
        let leftLineY:CGFloat = self.bounds.size.height+2.0-moveDistance*_offsetY/height*2;
        let rightLineY:CGFloat = -lineLength-2+moveDistance*_offsetY/height*2;
        
        ctx.move(to: CGPoint(x:left,y:leftLineY));
        ctx.addLine(to: CGPoint(x:left,y:leftLineY+lineLength));
    
        ctx.move(to: CGPoint(x:right,y:rightLineY));
        ctx.addLine(to: CGPoint(x:right,y:rightLineY+lineLength));
    
        ctx.move(to: CGPoint(x:left-arrowLenth,y:leftLineY+arrowLenth));
        ctx.addLine(to: CGPoint(x:left,y:leftLineY));
    
        ctx.move(to: CGPoint(x:right+arrowLenth,y:rightLineY+lineLength-arrowLenth));
        ctx.addLine(to: CGPoint(x:right,y:rightLineY+lineLength));
    
    }
    
    //draw line to arc
    private func drawLineToArcWithContext(ctx:CGContext){
        
        let radian = angleToRadian(angle: 180+angle);
        let radian2 = angleToRadian(angle: angle);
        
        let lx:CGFloat = getRadianX(radian:radian) - arrowLenth*sin(angleToRadian(angle:angle+30));
        let ty:CGFloat = getRadianY(radian:radian) + arrowLenth*cos(angleToRadian(angle:angle+30));
    
        let ra2x:CGFloat = getRadianX(radian:radian2) + arrowLenth*cos(angleToRadian(angle:angle-60));
        let ra2y:CGFloat = getRadianY(radian:radian2) + arrowLenth*sin(angleToRadian(angle:angle-60));
    
        //left line
        let bottom:CGFloat = self.bounds.size.height-top+arcRadius;
        ctx.move(to: CGPoint(x:left,y:bottom-(angle/endAngle*lineLength)));
        ctx.addLine(to: CGPoint(x:left,y:bottom-lineLength));
    
        //right line
        ctx.move(to: CGPoint(x:right,y:top-arcRadius+(angle/endAngle*lineLength)));
        ctx.addLine(to: CGPoint(x:right,y:top-arcRadius+lineLength));
    
        //lef arrow
        ctx.move(to: CGPoint(x:lx,y:ty));
        ctx.addLine(to: CGPoint(x:getRadianX(radian:radian),y:getRadianY(radian:radian)));
    
        //right arrow
        ctx.move(to: CGPoint(x:ra2x,y:ra2y));
        ctx.addLine(to: CGPoint(x:getRadianX(radian:radian2),y:getRadianY(radian:radian2)));
    
        //bottom arc
        ctx.move(to: CGPoint(x:centerX+arcRadius,y:centerY));
        ctx.addArc(center: CGPoint(x:centerX,y:centerY), radius: arcRadius, startAngle: 0, endAngle:angleToRadian(angle:angle), clockwise: false);
        
        //top arc
        ctx.move(to: CGPoint(x:left,y:centerY));
        ctx.addArc(center: CGPoint(x:centerX,y:centerY), radius: arcRadius, startAngle: CGFloat(M_PI), endAngle:angleToRadian(angle:angle)-CGFloat(M_PI), clockwise: false);
    }
    
    //draw tow arc by progress,and line‘s length pyramid down to 0;
    private func drawReleaseStateWithContext(ctx:CGContext)
    {
        let startRadian = CGFloat(M_PI)+angleToRadian(angle:rotateAngle);
        let endRadian = endAngle/180.0*CGFloat(M_PI)-CGFloat(M_PI)+angleToRadian(angle:rotateAngle);
        
        let startRadian2 = angleToRadian(angle:rotateAngle);
        let endRadian2 = endAngle/180.0*CGFloat(M_PI)+startRadian2;
        
        let rax = getRadianX(radian:endRadian) - arrowLenth*sin(angleToRadian(angle:endAngle+rotateAngle+30));
        let ray = getRadianY(radian:endRadian) + arrowLenth*cos(angleToRadian(angle:endAngle+rotateAngle+30));
        
        let ra2x = getRadianX(radian:endRadian2) + arrowLenth*cos(angleToRadian(angle:endAngle+rotateAngle-60));
        let ra2y = getRadianY(radian:endRadian2) + arrowLenth*sin(angleToRadian(angle:endAngle+rotateAngle-60));

        ctx.move(to: CGPoint(x:rax,y:ray));
        ctx.addLine(to: CGPoint(x:getRadianX(radian: endRadian),y:getRadianY(radian: endRadian)));
    
        ctx.move(to: CGPoint(x:ra2x,y:ra2y));
        ctx.addLine(to: CGPoint(x:getRadianX(radian: endRadian2),y:getRadianY(radian: endRadian2)));
    
        ctx.move(to: CGPoint(x:getRadianX(radian: startRadian),y:getRadianY(radian: startRadian)));
        ctx.addArc(center: CGPoint(x:centerX,y:centerY), radius: arcRadius, startAngle: startRadian, endAngle: endRadian, clockwise: false);
    
        ctx.move(to: CGPoint(x:getRadianX(radian: startRadian2),y:getRadianY(radian: startRadian2)));
        ctx.addArc(center: CGPoint(x:centerX,y:centerY), radius: arcRadius, startAngle: startRadian2, endAngle:endRadian2, clockwise: false);
    }
    
    private func angleToRadian(angle:CGFloat) -> CGFloat
    {
         return angle / 180.0 * CGFloat(M_PI);
    }
    
    private func getRadianX(radian:CGFloat) -> CGFloat
    {
         return centerX + cos(radian) * arcRadius;
    }
    
    private func getRadianY(radian:CGFloat) -> CGFloat
    {
        return centerY + sin(radian) * arcRadius;
    }
    
    
    public func startLoaingAnimation(){
        if(state == LayerState.LOADING){
            return;
        }
        state = LayerState.LOADING;
        playRotateAnimation();
    }
    
    public func beginRefreshing(){
        initData();
        state = LayerState.LOADING;
        setNeedsDisplay();
        playRotateAnimation();
    }
    
    public func reset(){
        _offsetY = 0;
        angle = 0;
        rotateAngle = 0;
        state = LayerState.PULL_TO_TRANSITION;
        setNeedsDisplay();
    }
    
    
}
