//
//  CourseStruct.swift
//  tableViewTest
//
//  Created by Kevin Zhou on 8/12/17.
//  Copyright © 2017 Kevin Zhou. All rights reserved.
//

import Foundation
import AVFoundation
public struct Course:JSONSerializable{
    var courseName:String
    var cards:NSMutableArray
}

public struct FlashCard:JSONSerializable{
    var chinese:String
    var english:String
    var pinyin:String
    var imageFileName:String
    var audioStartTime:Double
    var audioDuration:Double
}
