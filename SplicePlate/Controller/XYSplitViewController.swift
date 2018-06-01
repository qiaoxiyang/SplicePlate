//
//  XYSplitViewController.swift
//  SplicePlate
//
//  Created by qiaoxy on 2018/5/28.
//  Copyright © 2018年 qiaoxy. All rights reserved.
//

import UIKit
import SVProgressHUD
import SnapKit
import ZLPhotoBrowser

protocol XYSplitViewControllerDelegate {
    func done(images:[XYSplitImageModel],horizonal:[XYSplitImageModel],vertical:[XYSplitImageModel],assets:[PHAsset]?)
}

class XYSplitViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {

    private var collectionView :UICollectionView!
    var dataSource = [XYSplitImageModel]()
    private let cellId = "XYSplitCollectionViewCell"
    private let infoLabel = UILabel()
    var asset :[PHAsset]?
    var delegate :XYSplitViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initSubViews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initSubViews() {
        
        let flowLayout = UICollectionViewFlowLayout()
        let leftMargin:CGFloat = 15
        let margin:CGFloat = 2
        let allWidth = self.view.bounds.size.width - 2 * leftMargin - 3 * margin
        let width = allWidth / 4.0
        let height = width
        flowLayout.itemSize = CGSize.init(width: width, height: height)
        flowLayout.minimumLineSpacing = margin
        flowLayout.minimumInteritemSpacing = margin
        flowLayout.sectionInset = UIEdgeInsetsMake(10, leftMargin, 0, leftMargin)
        self.collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: flowLayout)
        self.collectionView.backgroundColor = UIColor.white
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.view.addSubview(self.collectionView)
        self.collectionView.register(UINib(nibName: cellId, bundle: nil), forCellWithReuseIdentifier: cellId)
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(cancelClick))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "完成", style: .plain, target: self, action: #selector(doneClick))
        
        
        infoLabel.font = UIFont.systemFont(ofSize: 15)
        self.view.addSubview(infoLabel)
        infoLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.view.snp.bottom).offset(-20)
            make.centerX.equalTo(self.view)
        }
 
        _ = configureInfoData()
        
        
    }

    func configureInfoData()->(Array<XYSplitImageModel>,Array<XYSplitImageModel>) {
        
        if self.dataSource.count == 0 {
            infoLabel.textColor = UIColor.red
            infoLabel.text = "总数量：0  横图数量：0  竖图数量：0"
            return (Array<XYSplitImageModel>(),Array<XYSplitImageModel>())
        }
        
        let verticalArray = self.dataSource.filter({$0.isVertical!})
        
        let horizonalArray = self.dataSource.filter({!$0.isVertical!})
        let count = self.dataSource.count % 9
        let verticalCount = verticalArray.count % 2
        let horizonalCount = horizonalArray.count % 2
        let allColor = count != 0 ? UIColor.red : UIColor.green
        let verticalColor = verticalCount != 0 ? UIColor.red : UIColor.green
        let horizonalColor = horizonalCount != 0 ? UIColor.red : UIColor.green
        
        let allAttribute = NSAttributedString(string: "总数量:\(self.dataSource.count)   ", attributes: [NSAttributedStringKey.foregroundColor : allColor])
        let horizonalAttribute = NSAttributedString(string: "横图数量：\(horizonalArray.count)   ", attributes: [NSAttributedStringKey.foregroundColor : horizonalColor])
        
        let verticalAttribute = NSAttributedString(string: "竖图数量：\(verticalArray.count)", attributes: [NSAttributedStringKey.foregroundColor : verticalColor])
        let infoAttribute = NSMutableAttributedString()
        infoAttribute.append(allAttribute)
        infoAttribute.append(horizonalAttribute)
        infoAttribute.append(verticalAttribute)
        infoLabel.attributedText = infoAttribute
      
        return (verticalArray,horizonalArray)
    }
    
    //取消
//    @objc func cancelClick() {
//
//        self.navigationController?.dismiss(animated: true, completion: nil)
//    }
    
    //确定
    @objc func doneClick() {
        //18 36 54 72
        
        if self.dataSource.count < 18 {
            SVProgressHUD.showError(withStatus: "照片数量最低为18张!")
            SVProgressHUD.setDefaultStyle(.dark)
            return
        }
        
        let n = self.dataSource.count % 9
        
        if n != 0 {
            SVProgressHUD.showError(withStatus: "请选择18、36、54、72张图片")
            SVProgressHUD.setDefaultStyle(.dark)
            return
        }
        let count = (self.dataSource.count / 9) % 2
        if count != 0 {
            SVProgressHUD.showError(withStatus: "请选择18、36、54、72张图片")
            SVProgressHUD.setDefaultStyle(.dark)
            return
        }
        let data = self.configureInfoData()
        let verticalCount = data.0.count % 2
        let horizonalCount = data.1.count % 2
        
        if verticalCount != 0 {
            SVProgressHUD.showError(withStatus: "请再添加或者删除一张红框（竖）图片")
            SVProgressHUD.setDefaultStyle(.dark)
            return
        }
        
        if horizonalCount != 0 {
            SVProgressHUD.showError(withStatus: "请再添加或者删除一张绿框（横）图片")
            SVProgressHUD.setDefaultStyle(.dark)
            return
        }
        
        self.delegate?.done(images: self.dataSource, horizonal: data.1, vertical: data.0,assets: self.asset)
        self.navigationController?.popViewController(animated: true)

    }
    
    //拼接图片选择器
    func takeSliptPhoto() {
        
        
        let actionSheet = ZLPhotoActionSheet()
        actionSheet.configuration.allowSelectVideo = false
        actionSheet.configuration.allowSelectImage = true
        actionSheet.configuration.allowEditImage = false
        actionSheet.configuration.showCaptureImageOnTakePhotoBtn = false
        actionSheet.configuration.maxSelectCount = 72
        actionSheet.sender = self
        if let assets = asset {
             actionSheet.arrSelectedAssets = NSMutableArray(array: assets)
        }
       
        actionSheet.selectImageBlock = { [weak self](images,assets,isOriginal) in
            self?.asset = assets
        
            let modelArray = images?.map({XYSplitImageModel(image: $0)})
            self?.dataSource = modelArray!
            self?.collectionView.reloadData()
            _ = self?.configureInfoData()
        
        }
        
        actionSheet.cancleBlock = {
            print("取消选择图片")
        }
        actionSheet.showPhotoLibrary()
        
//        let pickerVC = TZImagePickerController(maxImagesCount: 72, columnNumber: 4, delegate: self)
//        pickerVC?.allowPickingVideo = false
//        if let asset = self.asset  {
//            pickerVC?.selectedAssets = NSMutableArray(array: asset)
//        }
//
//        self.present(pickerVC!, animated: true, completion: nil)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! XYSplitCollectionViewCell
        if indexPath.item == self.dataSource.count {
            cell.imageView.image = #imageLiteral(resourceName: "button_addto")
            cell.closeButton.isHidden = true
            cell.bgView.backgroundColor = UIColor.white
            return cell
        }
        
        let model = self.dataSource[indexPath.item]
        cell.imageView.image = model.image
        cell.closeButton.tag = indexPath.item
        cell.closeButton.isHidden = false
        cell.bgView.backgroundColor = model.isVertical! ? UIColor.red : UIColor(red:0.57, green:0.75, blue:0.31, alpha:1.00)
        
        cell.removeBlock = { [weak self](tag,splitCell) in
            self?.dataSource.remove(at: tag)
            self?.asset?.remove(at: tag)
            self?.collectionView.reloadData()
            _ = self?.configureInfoData()
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.item == self.dataSource.count {
            
            self.takeSliptPhoto()
        }
        
    }
   
}


