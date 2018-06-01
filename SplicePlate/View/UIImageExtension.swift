//
//  UIImageExtension.swift
//  Nongjibang
//
//  Created by xiyang on 2017/8/10.
//  Copyright © 2017年 gaofan. All rights reserved.
//

import Foundation
import UIKit
extension UIImage{
    
    class func navigationBarImage(imgColor color:UIColor) -> UIImage {
        let screenWidth = UIScreen.main.bounds.size.width
        
        let rect = CGRect(x: 0, y: 0, width: screenWidth, height: 64)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return img!
    }
    
    func kt_drawRectWithRoundedCorner(radius: CGFloat, sizetoFit: CGSize) -> UIImage {
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: sizetoFit)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
        
        UIGraphicsGetCurrentContext()?.addPath(UIBezierPath(roundedRect: rect, byRoundingCorners: UIRectCorner.allCorners,
                                                            cornerRadii: CGSize(width: radius, height: radius)).cgPath)
        UIGraphicsGetCurrentContext()?.clip()
        
        self.draw(in: rect)
        UIGraphicsGetCurrentContext()?.drawPath(using: .fillStroke)
        let output = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return output!
    }

}

extension UIImageView {
    /**
     / !!!只有当 imageView 不为nil 时，调用此方法才有效果
     
     :param: radius 圆角半径
     */
    func kt_addCorner(radius: CGFloat,size:CGSize) {
        self.image = self.image?.kt_drawRectWithRoundedCorner(radius: radius, sizetoFit: size)
    }
}



