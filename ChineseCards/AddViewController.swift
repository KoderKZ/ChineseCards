//
//  AddViewController.swift
//  tableViewTest
//
//  Created by Kevin Zhou on 8/11/17.
//  Copyright © 2017 Kevin Zhou. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class AddViewController:UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    @IBOutlet weak var chineseTextField: UITextField!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var pinyinTextField: UITextField!
    @IBOutlet weak var englishTextField: UITextField!
    @IBOutlet weak var imageFilenameTextField: UITextField!
    var path1:URL!
    var path2:URL!
    var duration:CMTime!
    var firstCard:Bool!
    var image:UIImage!
    let picker = UIImagePickerController()
    
    override func viewDidLoad() {
        duration = kCMTimeZero
        duration.timescale = CMTimeScale(1000)
        recordButton.setImage(UIImage(named:"microphone.png"), for:.normal)
        firstCard = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.topViewController?.title = "Add Card"
    }
    
    @IBAction func addImageTapped(_ sender: Any) {
        createImgPicker()
    }
    @IBAction func microphoneTapDown(_ sender: Any) {
        if recordButton.currentImage == UIImage(named: "microphone.png"){
            let secondViewController = self.navigationController?.viewControllers[(navigationController?.viewControllers.count)!-2] as! CardListViewController
            if secondViewController.cardArray.count == 0{
                firstCard = true
            }
            let fileMgr = FileManager.default
            let dirPaths = fileMgr.urls(for: .documentDirectory,
                                        in: .userDomainMask)
            var writePath = dirPaths[0].appendingPathComponent("\(secondViewController.courseName!).wav")
            if !FileManager.default.fileExists(atPath: writePath.path) && firstCard{
                AudioUtil.record(path1: "\(secondViewController.courseName!).wav")
            }else{
                AudioUtil.record(path1: "2.wav")
            }
            recordButton.setImage(UIImage(named:"microphoneRecording.png"), for: .normal)
        }else{
            let secondViewController = self.navigationController?.viewControllers[(navigationController?.viewControllers.count)!-2] as! CardListViewController
            AudioUtil.stopRecording()
            let dirPaths = FileManager.default.urls(for: .documentDirectory,
                                        in: .userDomainMask)
            path1 = dirPaths[0].appendingPathComponent("\(secondViewController.courseName!).wav")
            path2 = dirPaths[0].appendingPathComponent("2.wav")
            recordButton.setImage(UIImage(named:"microphone.png"), for: .normal)
        }
    }
    @IBAction func addButtonTapped(_ sender: Any) {
        if chineseTextField.text == "" || englishTextField.text == "" || imageFilenameTextField.text == "" || pinyinTextField.text == "" || recordButton.currentImage == UIImage(named: "microphoneRecording.png"){
            let alert = UIAlertController(title: "Error", message: "Please fill out everything or stop recording", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else{
            self.hideKeyboardWhenTappedAround()
            chineseTextField.delegate = self
            pinyinTextField.delegate = self
            englishTextField.delegate = self
            imageFilenameTextField.delegate = self
            imageFilenameTextField.returnKeyType = UIReturnKeyType.done
            
            let fileMgr = FileManager.default
            let dirPaths = fileMgr.urls(for: .documentDirectory,
                                        in: .userDomainMask)
            let writePath = dirPaths[0].appendingPathComponent("2.wav")
            
            if !(!FileManager.default.fileExists(atPath: writePath.path) && firstCard){
                duration = AudioUtil.merge(audio1: path1 as NSURL, audio2: path2 as NSURL)
            }else{
                let secondViewController = self.navigationController?.viewControllers[(navigationController?.viewControllers.count)!-2] as! CardListViewController
                let fileMgr = FileManager.default
                let dirPaths = fileMgr.urls(for: .documentDirectory,
                                            in: .userDomainMask)
                let writePath = dirPaths[0].appendingPathComponent("\(secondViewController.courseName!).wav")
                
                
                let avAsset = AVURLAsset(url: writePath, options: nil)
                let tracks =  avAsset.tracks(withMediaType: AVMediaTypeAudio)
                let assetTrack:AVAssetTrack = tracks[0]
                duration = assetTrack.timeRange.duration
            }

            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
            let destinationPath = documentsPath.appendingPathComponent("\(imageFilenameTextField.text!).png")
            
            (UIImageJPEGRepresentation(image,1.0)! as NSData).write(toFile: destinationPath, atomically: true)

            let secondViewController = self.navigationController?.viewControllers[(navigationController?.viewControllers.count)!-2] as! CardListViewController
            secondViewController.addToImageNames(name: "\(imageFilenameTextField.text!)")
            let card = FlashCard(chinese: chineseTextField.text!, english: englishTextField.text!, pinyin: pinyinTextField.text!, imageFileName: imageFilenameTextField.text!, audioStartTime: secondViewController.newStartTime.seconds, audioDuration: duration!.seconds)
            secondViewController.addCard(card: card)
            self.navigationController?.popViewController(animated: true)
        }


        
    }
    
    func createImgPicker() {
        super.viewDidLoad()
        picker.delegate = self
        
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        self.parent?.present(picker, animated: true, completion: nil)
    }
    //MARK: - Delegates
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any])
    {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.image = chosenImage
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
