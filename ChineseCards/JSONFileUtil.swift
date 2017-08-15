//
//  JSONFileUtil.swift
//  tableViewTest
//
//  Created by Kevin Zhou on 8/12/17.
//  Copyright © 2017 Kevin Zhou. All rights reserved.
//

import Foundation

class JSONFileUtil{
    static func saveCourseToFile(course:Course){
        if let json = course.toJSON(){
            NSLog(json)
            let dict = convertToDictionary(text: json)
            let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
            let writePath = documents.appendingPathComponent("\(course.courseName).json")
            NSLog(writePath)
            let rawData: NSData!
            
            if JSONSerialization.isValidJSONObject(dict!) { // True
                do {
                    rawData = try JSONSerialization.data(withJSONObject: dict!, options: .prettyPrinted) as NSData
                    try rawData.write(toFile: writePath, options: .atomic)
                    NSLog(writePath)
                } catch {
                    NSLog("error")
                }
            }
        }
    }
    
    static func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    static func readCourseFromFile(courseName:String) -> Course{
        let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let writePath = documents.appendingPathComponent("\(courseName).json")
        if !FileManager.default.fileExists(atPath: writePath){
            let course = Course(courseName: courseName, cards: NSMutableArray())
            JSONFileUtil.saveCourseToFile(course: course)
        }
        let jsonData = NSData(contentsOfFile: writePath)
        do{
            let jsonDict = try JSONSerialization.jsonObject(with: jsonData! as Data, options: .mutableContainers) as! NSDictionary
            let course = Course(courseName: jsonDict.object(forKey: "courseName") as! String, cards: jsonDict.object(forKey: "cards") as! NSMutableArray)
            return course
        }catch{
            //error
        }
        let course = Course(courseName: "", cards: NSMutableArray())
        return course
    }

}
