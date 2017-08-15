//
//  CardListViewController.swift
//  tableViewTest
//
//  Created by Kevin Zhou on 8/11/17.
//  Copyright © 2017 Kevin Zhou. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import MessageUI

class CardListViewController:UIViewController,UITableViewDelegate,UITableViewDataSource,UINavigationControllerDelegate,MFMailComposeViewControllerDelegate{
    @IBOutlet weak var cardTableView: UITableView!
    var cardArray:NSMutableArray! = NSMutableArray()
    let cardJSONArray:NSMutableArray! = NSMutableArray()
    var courseName:String! = String()
    let fileUtil:JSONFileUtil = JSONFileUtil()
    var newStartTime:CMTime!
    let imageNames:NSMutableArray! = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if cardArray.count == 0{
            newStartTime = kCMTimeZero
        }
        newStartTime.timescale = CMTimeScale(1000)
        populateFlashCards()
        
        cardTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        cardTableView.delegate = self
        cardTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        cardTableView.reloadData()
        self.navigationController?.topViewController?.title = "Cards"

    }
    
    
    func populateFlashCards() {
//        let card1 = FlashCard(chinese: "ch1", english: "en1", imageFileName: "img1.png", audioFileName: "", audioStartTime: 0, audioDuration: 0)
//        cardArray.add(card1)
//        cardJSONArray.add(card1.toJSON()!)
//
//        let card2 = FlashCard(chinese: "ch2", english: "en2", imageFileName: "img2.png", audioFileName: "", audioStartTime: 0, audioDuration: 0)
        let course = JSONFileUtil.readCourseFromFile(courseName: courseName)
        courseName = course.courseName
    
        for var i in 0..<course.cards.count{
            let dict = JSONFileUtil.convertToDictionary(text: course.cards[i] as! String)
            let card = FlashCard(chinese: dict?["chinese"] as! String, english: dict?["english"] as! String, pinyin: dict?["pinyin"] as! String, imageFileName: dict?["imageFileName"] as! String, audioStartTime: dict?["audioStartTime"] as! Double, audioDuration: dict?["audioDuration"] as! Double)
            cardArray.add(card)
            cardJSONArray.add(card.toJSON()!)
        }
        JSONFileUtil.saveCourseToFile(course: Course(courseName: courseName, cards: cardJSONArray))
        
    }
    
    func sendEmail() {
        if cardArray.count == 0{
            self.navigationController?.popViewController(animated: true)
            let alert = UIAlertController(title: "Error", message: "Please add cards before sending files", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: false, completion: nil)
        }else{
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            // Configure the fields of the interface.
            composeVC.setToRecipients(["wzhou8@gmail.com"])
            composeVC.setSubject("Files for A Class")
            composeVC.setMessageBody("Files for class:", isHTML: false)
            let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
            let writePath = documents.appendingPathComponent("\(courseName!).json")
            
            let fileData = NSData(contentsOfFile: writePath)
            
            
            composeVC.addAttachmentData(fileData! as Data, mimeType: "json", fileName: "courseInfo")
            
            let documents2 = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
            let writePath2 = documents2.appendingPathComponent("\(courseName!).wav")
            
            let fileData2 = NSData(contentsOfFile: writePath2)
            
            composeVC.addAttachmentData(fileData2! as Data, mimeType: "audio/wav", fileName: "courseAudio")
            
            
            
            for var i in 0..<imageNames.count{
                let imageName = imageNames.object(at: i)
                
                let documents2 = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
                let writePath2 = documents2.appendingPathComponent("\(imageName).png")
                
                let fileData2 = NSData(contentsOfFile: writePath2)
                
                composeVC.addAttachmentData(fileData2! as Data, mimeType: "image/png", fileName: "\(imageName)")
            }
            
            // Present the view controller modally.
            self.present(composeVC, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        // Check the result or perform other tasks.
        // Dismiss the mail compose view controller.
        self.navigationController?.popViewController(animated: true)
        controller.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func sendFilesTapped(_ sender: Any) {
        sendEmail()
    }
    func setCourseName(name:String) {
        courseName = name
    }
    
    public func addCard(card:FlashCard) {
        cardArray.add(card)
        cardJSONArray.add(card.toJSON()!)
        let course = Course(courseName: courseName, cards: cardJSONArray)
        JSONFileUtil.saveCourseToFile(course: course)
        
        newStartTime = CMTimeAdd(newStartTime, CMTimeMakeWithSeconds(card.audioDuration, newStartTime.timescale))
    }

    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let card = cardArray.object(at: indexPath.row) as! FlashCard
        NSLog("\(CMTimeMakeWithSeconds(card.audioStartTime, newStartTime.timescale), indexPath.row)")
        AudioUtil.playAudio(path: "\(courseName!).wav", startTime: CMTimeMakeWithSeconds(card.audioStartTime, newStartTime.timescale), duration: CMTimeMakeWithSeconds(card.audioDuration, newStartTime.timescale))
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            let card = cardArray.object(at: indexPath.row) as! FlashCard
            newStartTime! = CMTimeSubtract(newStartTime, CMTimeMakeWithSeconds(card.audioDuration, newStartTime.timescale))
            AudioUtil.delete(startTime: CMTimeMakeWithSeconds(card.audioStartTime, newStartTime.timescale), duration: CMTimeMakeWithSeconds(card.audioDuration, newStartTime.timescale), path: "\(courseName!).wav")
            NSLog("\(CMTimeMakeWithSeconds(card.audioDuration, newStartTime.timescale).seconds)")
            

            
            for var i in indexPath.row+1..<cardArray.count{
                var card2 = cardArray.object(at: i) as! FlashCard
                let startCMTime = CMTimeMakeWithSeconds(card2.audioStartTime, newStartTime.timescale)
                let durationCMTime = CMTimeMakeWithSeconds(card.audioDuration, newStartTime.timescale)
                let newCMTime = CMTimeSubtract(startCMTime, durationCMTime)
                card2.audioStartTime = newCMTime.seconds
                cardArray.removeObject(at: i)
                cardArray.insert(card2, at: i)
                cardJSONArray.removeObject(at: i)
                cardJSONArray.insert(card2.toJSON(), at: i)
                NSLog("\(card2.audioStartTime)")
                JSONFileUtil.saveCourseToFile(course: Course(courseName: courseName, cards: cardJSONArray))
            }
            cardArray.removeObject(at: indexPath.row)
            cardJSONArray.removeObject(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            tableView.reloadData()
            JSONFileUtil.saveCourseToFile(course: Course(courseName: courseName, cards: cardJSONArray))

        }
    }

    func addToImageNames(name:String){
        imageNames.add(name)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cardArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = cardTableView.dequeueReusableCell(withIdentifier: "cell")!
        let card = cardArray[indexPath.row] as! FlashCard
        cell.textLabel?.text = "Ch: \(card.chinese), PY: \(card.pinyin), En: \(card.english), Img: \(card.imageFileName).png"
        if imageNames.count < cardArray.count{
            imageNames.add(card.imageFileName)
        }
        cell.textLabel?.font = UIFont(name: "Helvetica", size: 10)
        let fileMgr = FileManager.default
        let dirPaths = fileMgr.urls(for: .documentDirectory,
                                    in: .userDomainMask)
        let writePath = dirPaths[0].appendingPathComponent("\(card.imageFileName).png")
        do{
            
            if cell.subviews.count < 2{
                let data = try Data(contentsOf: writePath)
                let image = UIImage(data: data)
                let imageView = UIImageView(image: image)
                let scale = imageView.frame.size.height/cell.frame.size.height
                imageView.frame.size = CGSize(width: imageView.frame.size.width/scale, height: imageView.frame.size.height/scale)
                imageView.frame.origin = CGPoint(x: cell.frame.size.width, y: 0)
                cell.contentView.addSubview(imageView)
            }
        }catch{}
        return cell
    }
    
    
}
