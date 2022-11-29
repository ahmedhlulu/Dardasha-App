//
//  GlobalFunc.swift
//  Dardasha
//
//  Created by Ahmed on 11/09/2022.
//

import Foundation
import UIKit
import AVFoundation

func fileNameFrom(fileUrl: String) -> String {
    
    let name = fileUrl.components(separatedBy: "_").last
    let name1 = name?.components(separatedBy: "?").first
    let name2 = name1?.components(separatedBy: ".").first
    
    return name2!
}

func timeElapsed(_ date: Date) -> String {
    let second = Date().timeIntervalSince(date)
    var elapsed = ""
    
    if second < 60 {
        elapsed = "Just now"
        
    }else if second < 60 * 60 {
        let minutes = Int(second/60)
        let minText = minutes > 1 ? "mins" : "min"
        elapsed = "\(minutes) \(minText)"
        
    }else if second < 24 * 60 * 60 {
        let hour = Int(second / (60 * 60))
        let hourText = hour > 1 ? "hours" : "hour"
        elapsed = "\(hour) \(hourText)"
        
    }else {
        elapsed = "\(date.longDate())"
    }
    
    return elapsed
}

func videoThumbnail(videoURL: URL) -> UIImage {
    do {
        let asset = AVURLAsset(url: videoURL, options: nil)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        imgGenerator.appliesPreferredTrackTransform = true
        let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
        let thumbnail = UIImage(cgImage: cgImage)
        return thumbnail
    } catch let error {
        print("*** Error generating thumbnail: \(error.localizedDescription)")
        return kPLACEHOLDERMESSAGEIMAGE
    }
}
