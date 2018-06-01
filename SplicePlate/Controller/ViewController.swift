//
//  ViewController.swift
//  SplicePlate
//
//  Created by qiaoxy on 2018/5/22.
//  Copyright © 2018年 qiaoxy. All rights reserved.
//

import UIKit
import ZLPhotoBrowser
import SVProgressHUD
class ViewController: UIViewController ,UICollectionViewDelegate,UICollectionViewDataSource,XYSplitViewControllerDelegate{
   
    

    //选取需要裁切的九宫格图片
    @IBAction func pickerButtonAction(_ sender: UIButton) {
        
        self.takePhoto()
    }
    //选取需要拼接的图片
    @IBAction func pickeSplitPhotoAction(_ sender: UIButton) {
        
        let splitVC = XYSplitViewController()
        splitVC.delegate = self
        splitVC.dataSource = self.splitDataSource
        splitVC.asset = self.assets
        self.navigationController?.pushViewController(splitVC, animated: true)
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var splitCollectionView: UICollectionView!
    
    @IBOutlet weak var splitLayout: UICollectionViewFlowLayout!
    
    
    private let cellId = "XYPhotoCollectionViewCell"
    private var dataSource = [UIImage]()
    private var splitDataSource = [XYSplitImageModel]()
    private var widthHeight:CGFloat = 0
    private let left:CGFloat = 30
    private var assets:[PHAsset]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initSubViews()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func initSubViews() {
        let screenWidth = UIScreen.main.bounds.size.width
        
        widthHeight = screenWidth - 2 * left
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        let w = (widthHeight - 4) / 3.0
        self.flowLayout.itemSize = CGSize.init(width: w, height: w)
        self.flowLayout.minimumLineSpacing = 2
        self.flowLayout.minimumInteritemSpacing = 2
        self.collectionView.register(UINib(nibName: cellId, bundle: nil), forCellWithReuseIdentifier: cellId)
        
        //拼接的collectionview
        
        let splitW = (screenWidth - left - 3 * 2) / 3.0
        splitLayout.itemSize = CGSize.init(width: splitW, height: splitW)
        splitLayout.minimumLineSpacing = 2
        splitLayout.scrollDirection = .horizontal
        self.splitCollectionView.delegate = self
        self.splitCollectionView.dataSource = self
        self.splitCollectionView.register(UINib(nibName: cellId, bundle: nil), forCellWithReuseIdentifier: cellId)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "预览", style: .plain, target: self, action: #selector(previewClick))
        
        self.dataSource = self.cutImageSquare(image: #imageLiteral(resourceName: "placehold"))
        self.collectionView.reloadData()
    }
    
    //预览
    @objc func previewClick() {
        
        if self.dataSource.count == 0  {
            SVProgressHUD.showError(withStatus: "请选择需要切成九宫格的图片")
            SVProgressHUD.setDefaultStyle(.dark)
            return
        }
        if self.splitDataSource.count == 0  {
            SVProgressHUD.showError(withStatus: "请选择需要拼接的图片")
            SVProgressHUD.setDefaultStyle(.dark)
            return
        }
        
        let previewVC = XYPreviewViewController()
        
        let cutModelArray = self.dataSource.map({XYSplitImageModel(image: $0)})
        
        previewVC.cutModelArray = cutModelArray
        previewVC.splitModelArray = self.splitDataSource
        
        self.navigationController?.pushViewController(previewVC, animated: true)
    }

    //裁切图片选择器
    func takePhoto()  {

        let actionSheet = ZLPhotoActionSheet()
        actionSheet.configuration.allowSelectVideo = false
        actionSheet.configuration.allowSelectImage = true
        actionSheet.configuration.allowEditImage = false
        actionSheet.configuration.showCaptureImageOnTakePhotoBtn = false
        actionSheet.configuration.maxSelectCount = 1
        actionSheet.sender = self
        actionSheet.configuration.allowSelectOriginal = true
        actionSheet.selectImageBlock = { [weak self](images,assets,isOriginal) in
            
//            print(isOriginal)
            let coverImage = images?.first
            self?.dataSource = (self?.cutImageSquare(image: coverImage!))!
            self?.collectionView.reloadData()
        }
        
        actionSheet.cancleBlock = {
            print("取消选择图片")
        }
        actionSheet.showPhotoLibrary()
    }
    
    func cutImageSquare(image:UIImage) -> [UIImage] {
        
        var images = [UIImage]()
        
        let fixelW = image.size.width
        let fixelH = image.size.height
        var cutFloat:CGFloat = 0
        
        var subImage :UIImage!
        
        if fixelW > fixelH {
            let subFrame = CGRect(x: (fixelW - fixelH) / 2, y: 0, width: fixelH, height: fixelH)
            subImage = self.cutImage(image: image, rect: subFrame)
            cutFloat = fixelH
        }else {
            let subFrame = CGRect(x: 0, y: (fixelH - fixelW) / 2, width: fixelW, height: fixelW)
            subImage = self.cutImage(image: image, rect: subFrame)
            cutFloat = fixelW
        }
        
        let width = cutFloat / 3
        
        for index in 0..<9 {
            
            let x = CGFloat(index % 3) * width
            let y = CGFloat(index / 3) * width
            let imageF = CGRect.init(x: x, y: y, width: width, height: width)
            let piePic = self.cutImage(image: subImage, rect: imageF)
            images.append(piePic)
        }
        return images
    }
    
    func cutImage(image:UIImage,rect:CGRect) -> UIImage {
        
        let sourceImageRef = image.cgImage
        let newImageRef = sourceImageRef!.cropping(to: rect)
        let img = UIImage.init(cgImage: newImageRef!)
        
        return img
    }
    
    
    
    // MARK:UICollectionViewDelegate,UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag != 100 {
            return self.splitDataSource.count
        }else{
            return self.dataSource.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! XYPhotoCollectionViewCell
        if collectionView.tag != 100 {
            let model = self.splitDataSource[indexPath.item]
            cell.imageView.image = model.image
            
        }else{
            cell.imageView.image = self.dataSource[indexPath.item]
        }
        
        
        return cell
    }
    
    // MARK:XYSplitViewControllerDelegate
    func done(images: [XYSplitImageModel], horizonal: [XYSplitImageModel], vertical: [XYSplitImageModel], assets: [PHAsset]?) {
        let count = images.count / 9

        let verticalPreCount = vertical.count - vertical.count % count
        let horizonalPreCount = horizonal.count - horizonal.count % count
        
        let startVertical = Array(vertical[0..<verticalPreCount])
        let endVertical = Array(vertical[verticalPreCount..<vertical.count])
        
        let startHorizonal = Array(horizonal[0..<horizonalPreCount])
        let endHorizonal = Array(horizonal[horizonalPreCount..<horizonal.count])
        
        var end = endVertical + endHorizonal
        
        if end.count > 0 {
            let allCount = end.count / 2 - 1
            for i in 0..<allCount {
                let n = i * 2
                let m = (end.count - 1) - n
                end.swapAt(n, m)
            }
        }
        
        splitDataSource = startVertical + startHorizonal + end
        self.assets = assets
        self.splitCollectionView.reloadData()
    }

   
}

