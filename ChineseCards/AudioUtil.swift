//
//  AudioUtil.swift
//  tableViewTest
//
//  Created by Kevin Zhou on 8/13/17.
//  Copyright © 2017 Kevin Zhou. All rights reserved.
//

import Foundation
import AVFoundation
class AudioUtil{
    static var audioPlayer: AVAudioPlayer?
    static var audioRecorder: AVAudioRecorder?
    static var timer:Timer!
    static var globalStartTime:CMTime!
    static var globalDuration:CMTime!
    
    static func merge(audio1: NSURL, audio2:  NSURL) -> CMTime{
        
        //        var documentsDirectory:String = paths[0] as! String
        
        //Create AVMutableComposition Object.This object will hold our multiple AVMutableCompositionTrack.
        let composition = AVMutableComposition()
        //        var compositionAudioTrack1:AVMutableCompositionTrack = composition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID())
        //        var compositionAudioTrack2:AVMutableCompositionTrack = composition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID())
        
        //create new file to receive data
        
        let url1 = audio1
        let url2 = audio2
        
        
        let avAsset1 = AVURLAsset(url: url1 as URL, options: nil)
        let avAsset2 = AVURLAsset(url: url2 as URL, options: nil)
        
        let tracks1 =  avAsset1.tracks(withMediaType: AVMediaTypeAudio)
        let tracks2 =  avAsset2.tracks(withMediaType: AVMediaTypeAudio)
        
        let assetTrack1:AVAssetTrack = tracks1[0]
        let assetTrack2:AVAssetTrack = tracks2[0]
        
        let duration1: CMTime = assetTrack1.timeRange.duration
        let duration2: CMTime = assetTrack2.timeRange.duration
        
        
        let timeRange1 = CMTimeRangeMake(kCMTimeZero, duration1)
        let timeRange2 = CMTimeRangeMake(kCMTimeZero, duration2)
        
        do{
            try composition.insertTimeRange(timeRange1, of: avAsset1, at: kCMTimeZero)
            try composition.insertTimeRange(timeRange2, of: avAsset2, at: duration1)
        }catch{
            NSLog("couldn't load")
        }
        
        let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
        let fileDestinationUrl = documentDirectoryURL.appendingPathComponent("final.wav")
        

        
        var assetExport = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A)
        assetExport?.outputFileType = AVFileTypeAppleM4A
        assetExport?.outputURL = fileDestinationUrl
        
        assetExport?.exportAsynchronously(completionHandler: {
            switch assetExport!.status{
            case  AVAssetExportSessionStatus.failed:
                NSLog("failed 1 \(String(describing: assetExport?.error))")
            case AVAssetExportSessionStatus.cancelled:
                NSLog("cancelled \(String(describing: assetExport?.error))")
            default:
                NSLog("complete 1")
                
                do{
                    try FileManager.default.removeItem(atPath: audio1.path!)
                    try FileManager.default.copyItem(at: fileDestinationUrl!, to: audio1 as URL)
                    NSLog("remove 2")
                    
                    if FileManager.default.fileExists(atPath: (fileDestinationUrl?.path)!){
                        do{
                            try FileManager.default.removeItem(atPath: fileDestinationUrl!.path)
                        }catch{}
                    }
                }catch{
                }
            }
            
        })
        
        return duration2
        
    }
    
    static func playAudio(path:String, startTime:CMTime, duration:CMTime) {
        
        let fileMgr = FileManager.default
        let dirPaths = fileMgr.urls(for: .documentDirectory,
                                    in: .userDomainMask)
        let writePath = dirPaths[0].appendingPathComponent(path)
        
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        try! AVAudioSession.sharedInstance().setActive(true)
        
        do{
            try audioPlayer = AVAudioPlayer(contentsOf: writePath)
            audioPlayer?.currentTime = startTime.seconds
            audioPlayer!.prepareToPlay()
            audioPlayer!.play()
            globalStartTime = startTime
            globalDuration = duration
            timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(AudioUtil.checkSeconds), userInfo: nil, repeats: true)
        }catch{}
    }
    
    @objc static func checkSeconds() {
        if (audioPlayer?.currentTime)! >= globalStartTime.seconds+globalDuration.seconds{
            audioPlayer?.stop()
            timer.invalidate()
        }
    }
    
    static func delete(startTime:CMTime, duration:CMTime, path:String){
        let composition = AVMutableComposition()
        
        let timeRange = CMTimeRangeMake(startTime, duration)
        NSLog("\(startTime.timescale, duration.timescale)")
        
        let fileMgr = FileManager.default
        let dirPaths = fileMgr.urls(for: .documentDirectory,
                                    in: .userDomainMask)
        let writePath = dirPaths[0].appendingPathComponent(path)
        
        
        let avAsset = AVURLAsset(url: writePath, options: nil)
        let tracks =  avAsset.tracks(withMediaType: AVMediaTypeAudio)
        let assetTrack:AVAssetTrack = tracks[0]
        let duration: CMTime = assetTrack.timeRange.duration
        
        let tempTimeRange = CMTimeRangeMake(kCMTimeZero, duration)
        
        do{
            try composition.insertTimeRange(tempTimeRange, of: avAsset, at: kCMTimeZero)
            composition.removeTimeRange(timeRange)
        }catch{}
        
        let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
        let fileDestinationUrl = documentDirectoryURL.appendingPathComponent("final.wav")
        
        let assetExport = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A)
        assetExport?.outputFileType = AVFileTypeAppleM4A
        assetExport?.outputURL = fileDestinationUrl
        
        assetExport?.exportAsynchronously(completionHandler: {
            switch assetExport!.status{
            case  AVAssetExportSessionStatus.failed:
                NSLog("failed 1 \(String(describing: assetExport?.error))")
            case AVAssetExportSessionStatus.cancelled:
                NSLog("cancelled \(String(describing: assetExport?.error))")
            default:
                NSLog("complete 1")
                do{
                    try FileManager.default.removeItem(atPath: writePath.path)
                    try FileManager.default.copyItem(at: fileDestinationUrl!, to: writePath)
                    NSLog("remove 2")
                    
                    if FileManager.default.fileExists(atPath: (fileDestinationUrl?.path)!){
                        do{
                            try FileManager.default.removeItem(atPath: fileDestinationUrl!.path)
                        }catch{}
                    }
                }catch{
                }

            }
            
        })
        
    }
    
    static func record(path1:String){
        let fileMgr = FileManager.default
        let dirPaths = fileMgr.urls(for: .documentDirectory,
                                    in: .userDomainMask)
        var writePath = dirPaths[0].appendingPathComponent(path1)
        NSLog("\(writePath)")
        
        
        let recordSettings =
            [AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue,
             AVEncoderBitRateKey: 16,
             AVNumberOfChannelsKey: 2,
             AVSampleRateKey: 44100.0] as [String : Any]
        
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(
                AVAudioSessionCategoryPlayAndRecord)
        } catch let error as NSError {
            print("audioSession error: \(error.localizedDescription)")
        }
        
        do {
            try audioRecorder = AVAudioRecorder(url: writePath,
                                                settings: recordSettings as [String : AnyObject])
            audioRecorder?.prepareToRecord()
            if audioRecorder?.isRecording == false {
                audioRecorder?.record()
            }
        } catch let error as NSError {
            print("audioSession error: \(error.localizedDescription)")
        }

    }
    
    static func stopRecording(){
        if audioRecorder?.isRecording == true {
            audioRecorder?.stop()
        }
    }
    
    
}
