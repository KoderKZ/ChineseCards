//
//  CourseViewController.swift
//  tableViewTest
//
//  Created by Kevin Zhou on 8/11/17.
//  Copyright © 2017 Kevin Zhou. All rights reserved.
//

import Foundation
import UIKit
class CourseViewController: UIViewController,UINavigationControllerDelegate,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {
    @IBOutlet weak var classNameTextField: UITextField!
    @IBOutlet weak var classTableView: UITableView!
    let classNames:NSMutableArray = NSMutableArray()
    var gradeName:String!
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.navigationController?.delegate = self
        classNameTextField.delegate = self
        classTableView.dataSource = self
        classTableView.delegate = self
        classTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        classTableView.reloadData()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateClassNames()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.topViewController?.title = "Select Course"
    }
    
    @IBAction func addClassTapped(_ sender: Any) {
        if classNames.contains(classNameTextField.text!){
            let alert = UIAlertController(title: "Error", message: "Class name already used", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else{
            classNames.add(classNameTextField.text!)
        }
        
        let grade = Grade(gradeName: gradeName, classes: classNames)
        JSONFileUtil.saveGradeToFile(grade: grade)
        
    }
    
    func populateClassNames() {
        let grade = JSONFileUtil.readGradeFromFile(gradeName: gradeName)
        gradeName = grade.gradeName
        
        for var i in 0..<grade.classes.count{
            classNames.add(grade.classes.object(at: i))
        }
        classTableView.reloadData()
        JSONFileUtil.saveGradeToFile(grade: Grade(gradeName: gradeName, classes: classNames))
        
    }
    
    func setGradeName(name:String) {
        gradeName = name
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "CardListViewController") as! CardListViewController
        vc.setCourseName(name: classNames.object(at: indexPath.row) as! String)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            JSONFileUtil.deleteClass(className: classNames.object(at: indexPath.row) as! String)
            classNames.removeObject(at: indexPath.row)
            JSONFileUtil.saveGradeToFile(grade: Grade(gradeName: gradeName, classes: classNames))
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            tableView.reloadData()
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = classTableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = classNames[indexPath.row] as? String
        classNameTextField.text = ""
        return cell
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        classNameTextField.resignFirstResponder()
    }
}

