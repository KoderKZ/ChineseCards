//
//  GradeViewController.swift
//  tableViewTest
//
//  Created by Kevin Zhou on 8/11/17.
//  Copyright © 2017 Kevin Zhou. All rights reserved.
//

import Foundation
import UIKit
import os.log
class GradeViewController: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Select Grade"
//        let bundle = Bundle.main
//        let path = bundle.path(forResource: "test", ofType: "json")
//        do{
//            if let data = data,
//                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
//                let blogs = json["blogs"] as? [[String: Any]] {
//                for blog in blogs {
//                    if let name = blog["name"] as? String {
//                        names.append(name)
//                    }
//                }
//            }
//        }catch{
//            NSLog("something went wrong")
//        }
    }
}
