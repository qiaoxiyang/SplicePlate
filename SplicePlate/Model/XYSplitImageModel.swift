
//
//  XYSplitImageModel.swift
//  SplicePlate
//
//  Created by qiaoxy on 2018/5/29.
//  Copyright © 2018年 qiaoxy. All rights reserved.
//

import UIKit

class XYSplitImageModel: NSObject {

    var image :UIImage?
    var isVertical :Bool?
    var rowHeight :CGFloat?
    
    init(image:UIImage) {
        self.image = image
        if let i = self.image {
            isVertical = i.size.width > i.size.height ? false : true
            let screenW = UIScreen.main.bounds.size.width
            rowHeight = screenW * i.size.height / i.size.width
        }
        
        
    }
    
}
