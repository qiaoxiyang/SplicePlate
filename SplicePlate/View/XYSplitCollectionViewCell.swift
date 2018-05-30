//
//  XYSplitCollectionViewCell.swift
//  SplicePlate
//
//  Created by qiaoxy on 2018/5/28.
//  Copyright © 2018年 qiaoxy. All rights reserved.
//

import UIKit


typealias RemoveBlock = (Int,XYSplitCollectionViewCell)->()
class XYSplitCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var closeButton: UIButton!
    
    @IBAction func closeButtonAction() {
        
        self.removeBlock?(closeButton.tag,self)
        
    }
    
    var removeBlock :RemoveBlock?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
