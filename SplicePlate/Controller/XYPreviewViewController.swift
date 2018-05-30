//
//  XYPreviewViewController.swift
//  SplicePlate
//
//  Created by qiaoxy on 2018/5/29.
//  Copyright © 2018年 qiaoxy. All rights reserved.
//

import UIKit
import SnapKit
import SVProgressHUD
class XYPreviewViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    private let contentScrollView = UIScrollView()
    
    private var dataSource = [[XYSplitImageModel]]()
    
    var cutModelArray :[XYSplitImageModel]!
    var splitModelArray :[XYSplitImageModel]!
    private var tableViewArray = [UITableView]()
    private let cellId = "XYImageTableViewCell"
    var saveImages = [UIImage]()
    var page = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        title = "预览1"
        initSubVies()
        configureData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initSubVies() {
        
        if #available(iOS 11, *) {
            self.contentScrollView.contentInsetAdjustmentBehavior = .never
        }else{
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        self.view.addSubview(self.contentScrollView)
        self.contentScrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        
        let contentW = self.view.tz_width * 9
        self.contentScrollView.contentSize = CGSize(width: contentW, height: 0)
        self.contentScrollView.isPagingEnabled = true
        self.contentScrollView.tag = 100
        self.contentScrollView.delegate = self
        for index in 0..<9 {
            let tableView = UITableView()
            tableView.tag = index
            let width = self.view.tz_width
            let height = self.view.tz_height
            let x = CGFloat(index) * width
            tableView.delegate = self
            tableView.dataSource = self
            tableView.separatorStyle = .none
            tableView.register(UINib(nibName: cellId, bundle: nil), forCellReuseIdentifier: cellId)
            tableView.frame = CGRect.init(x: x, y: 0, width: width, height: height)
            tableView.estimatedRowHeight = 100
            self.contentScrollView.addSubview(tableView)
            tableViewArray.append(tableView)
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "保存", style: .plain, target: self, action: #selector(saveClick))
    }
    
    func configureData() {
        
        let count = self.splitModelArray.count / 9
        
        for i in 0..<9 {
            var dataArray = [XYSplitImageModel]()
            let begain = i * count
            let end = (i + 1) * count
            for n in begain ..< end {
                let model = self.splitModelArray[n]
                dataArray.append(model)
            }
            let cutModel = self.cutModelArray[i]
            dataArray.insert(cutModel, at: (count / 2))
            self.dataSource.append(dataArray)
        }
        
        print(self.dataSource)
        for t in tableViewArray {
            t.reloadData()
        }
        
    }
    
    //保存到本地
    @objc func saveClick() {
    
        
        page = 0
        for tableView in tableViewArray {
            
            let image = self.captureTabelView(tableView: tableView)
            if let img = image{
                saveImages.append(img)
            }
        }
        SVProgressHUD.show()
        self.writeImageToAlumb(index: page)
    
        
    }
    
    func writeImageToAlumb(index:Int)  {
        
        if index >= self.saveImages.count {
            SVProgressHUD.dismiss()
            SVProgressHUD.showSuccess(withStatus: "保存成功")
            SVProgressHUD.setDefaultStyle(.dark)
            return
        }
        let img = self.saveImages[index]
        UIImageWriteToSavedPhotosAlbum(img, self, #selector(self.imageSavedToPhoto(image:error:contextInfo:)), nil)
        
    }
    
    
    func captureTabelView(tableView:UITableView) -> UIImage? {
        
        var image :UIImage?
        UIGraphicsBeginImageContextWithOptions(tableView.contentSize, false, 2)
        let savedContentOffset = tableView.contentOffset
        let savedFrame = tableView.frame
        tableView.contentOffset = CGPoint.zero
        tableView.frame = CGRect.init(x: 0, y: 0, width: tableView.contentSize.width, height: tableView.contentSize.height)
        tableView.layer.render(in: UIGraphicsGetCurrentContext()!)
        image = UIGraphicsGetImageFromCurrentImageContext()
        tableView.contentOffset = savedContentOffset
        tableView.frame = savedFrame
        UIGraphicsEndImageContext()
        
        return image
    }
    
    
    @objc func imageSavedToPhoto(image:UIImage,error:NSError?,contextInfo: AnyObject)  {
        page += 1
//        print("保存---------- \(page)")
        if error != nil {
            SVProgressHUD.showSuccess(withStatus: "保存失败")
            SVProgressHUD.setDefaultStyle(.dark)
        }
        self.writeImageToAlumb(index: page)
    }
    
    //MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.dataSource.count == 0 {
            return 0
        }
        let array = self.dataSource[tableView.tag]
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! XYImageTableViewCell
        let array = self.dataSource[tableView.tag]
        let model = array[indexPath.row]
        cell.photpImageView.image = model.image
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let array = self.dataSource[tableView.tag]
        let model = array[indexPath.row]
        
        return model.rowHeight ?? 0
    }
    
    //MARK: UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.tag == 100 {
            
            let index = ceil(scrollView.contentOffset.x / self.view.tz_width)
            self.title = "预览\(Int(index) + 1)"
        }
        
    }
    

}
