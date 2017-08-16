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
class GradeViewController: UIViewController,UINavigationControllerDelegate {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Select Grade"
        self.navigationController?.delegate = self

    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! CourseViewController
        vc.setGradeName(name: segue.identifier!)
    }

}
