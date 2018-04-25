//
//  scan.swift
//  EazyFitness
//
//  Created by Luke on 2018/4/25.
//  Copyright © 2018年 luke. All rights reserved.
//

import UIKit

class scan: NSObject {
    
    class func checkScanPermissions() -> Bool {
        do {
            return try QRCodeReader.supportsMetadataObjectTypes()
        } catch let error as NSError {
            switch error.code {
            case -11852:
                AppDelegate.showError(title: "扫码时遇到错误", err: "没有权限使用后置摄像头")
            default:
                AppDelegate.showError(title: "扫码时遇到错误", err: "未知错误")
            }
            return false
        }
    }
    
    class func scanCard(_vc:QRCodeReaderViewControllerDelegate){
        if let vc = _vc as? DefaultViewController{
            let readerVC: QRCodeReaderViewController = {
                let builder = QRCodeReaderViewControllerBuilder {
                    $0.reader          = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
                    $0.showTorchButton = true
                    
                    $0.reader.stopScanningWhenCodeIsFound = false
                }
                return QRCodeReaderViewController(builder: builder)
            }()
            guard scan.checkScanPermissions() else { return }
            readerVC.modalPresentationStyle = .formSheet
            readerVC.delegate               = vc as! QRCodeReaderViewControllerDelegate
            readerVC.completionBlock = { (result: QRCodeReaderResult?) in
                if let result = result {
                    print("Completion with result: \(result.value) of type \(result.metadataType)")
                }
            }
            vc.present(readerVC, animated: true, completion: nil)
        }
    }
}
