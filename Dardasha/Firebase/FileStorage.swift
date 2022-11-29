//
//  FileStorage.swift
//  Dardasha
//
//  Created by Ahmed on 11/09/2022.
//

import Foundation
import UIKit
import ProgressHUD
import FirebaseStorage

let storage = Storage.storage()

class FileStorage {
    
    // MARK: - Image
    class func uploadImage(_ image : UIImage, directory : String, showProgress: Bool = true, complection : @escaping (_ photoLink : String? ) -> Void) {
        
        //1. create folder in firestore
        let storageRef = storage.reference(forURL: kFILEREFERACE).child(directory)
        
        //2. convert the image to data
        let imageData = image.jpegData(compressionQuality: 0.5)
        
        //3. put the data into firestore and return the link
        var task : StorageUploadTask!
        
        task = storageRef.putData(imageData!, metadata: nil, completion: { metaData, error in
            
            task.removeAllObservers()
            ProgressHUD.dismiss()
            
            if error != nil {
                print("Error uploading image \(error!.localizedDescription)")
                return
            }
            storageRef.downloadURL { url, error in
                guard let dowloadUrl = url else {
                    complection(nil)
                    return
                }
                complection(dowloadUrl.absoluteString)
            }
            
        })
        
        //4. obseve percentage upload
        task.observe(StorageTaskStatus.progress) { snapshot in
            let progress = snapshot.progress!.completedUnitCount / snapshot.progress!.totalUnitCount
            if showProgress {
                ProgressHUD.showProgress("Uploading the image, please wait", CGFloat(progress))
            }
        }
        
    }
    
    // download image
    class func downloadImage(imageUrl: String, complection : @escaping (_ image : UIImage?) -> Void) {
        
        let imageFileName = fileNameFrom(fileUrl: imageUrl)
        
        if fileExistsAtPath(path: imageFileName) {
            //get image locally
            if let contentOfFile = UIImage(contentsOfFile: fileInDocumentsDirectory(fileName: imageFileName)) {
                complection(contentOfFile)
            }else {
                print("could not convert local image")
                complection(UIImage(systemName: "person.circle.fill")!)
            }
            
        }else {
            //download image
            if imageUrl != "" {
                let documentUrl = URL(string: imageUrl)
                let downloadQueue = DispatchQueue(label: "imageDownloadQueue")
                
                downloadQueue.async {
                    let data = NSData(contentsOf: documentUrl!)
                    if data != nil {
                        
                        FileStorage.saveFileLocally(fileData: data!, fileName: imageFileName)
                        
                        DispatchQueue.main.async {
                            complection(UIImage(data: data! as Data))
                        }
                        
                    }else {
                        print("no document found in database")
                        complection(nil)
                    }
                }
            }
        }
        
    }
    
    // MARK: - Video
    class func uploadVideo(_ video : NSData, directory : String, complection : @escaping (_ videoLink : String? ) -> Void) {
        
        //1. create folder in firestore
        let storageRef = storage.reference(forURL: kFILEREFERACE).child(directory)
        
        //3. put the data into firestore and return the link
        var task : StorageUploadTask!
        
        task = storageRef.putData(video as Data, metadata: nil, completion: { metaData, error in
            
            task.removeAllObservers()
            ProgressHUD.dismiss()
            
            if error != nil {
                print("Error uploading video \(error!.localizedDescription)")
                return
            }
            storageRef.downloadURL { url, error in
                guard let dowloadUrl = url else {
                    complection(nil)
                    return
                }
                complection(dowloadUrl.absoluteString)
            }
            
        })
        
        //4. obseve percentage upload
        task.observe(StorageTaskStatus.progress) { snapshot in
            let progress = snapshot.progress!.completedUnitCount / snapshot.progress!.totalUnitCount
            
            ProgressHUD.showProgress("Uploading the video, please wait", CGFloat(progress))
        }
        
    }
    
    // download video
    class func downloadVideo(videoUrl: String, complection : @escaping (_ isReadyToPlay : Bool, _ videoFileName: String) -> Void) {
        
        let videoFileName = fileNameFrom(fileUrl: videoUrl) + ".mov"
        
        if fileExistsAtPath(path: videoFileName) {
            //get video locally
            complection(true, videoFileName)
            
            
        }else {
            //download video
            if videoUrl != "" {
                let documentUrl = URL(string: videoUrl)
                let downloadQueue = DispatchQueue(label: "audioDownloadQueue")
                
                downloadQueue.async {
                    let data = NSData(contentsOf: documentUrl!)
                    if data != nil {
                        
                        FileStorage.saveFileLocally(fileData: data!, fileName: videoFileName)
                        
                        DispatchQueue.main.async {
                            complection(true, videoFileName)
                        }
                        
                    }else {
                        print("no document found in database")
                    }
                }
            }
        }
        
    }
    
    // MARK: - Audio
    class func uploadAudio(_ audioFileName : String, directory : String, complection : @escaping (_ audioLink : String? ) -> Void) {
        
        //1. create folder in firestore
        let fileName = audioFileName + ".m4a"
        let storageRef = storage.reference(forURL: kFILEREFERACE).child(directory)
        
        //3. put the data into firestore and return the link
        var task : StorageUploadTask!
        
        if fileExistsAtPath(path: fileName){
            if let audioData = NSData(contentsOfFile: fileInDocumentsDirectory(fileName: fileName)){
                task = storageRef.putData(audioData as Data, metadata: nil, completion: { metaData, error in
                    
                    task.removeAllObservers()
                    ProgressHUD.dismiss()
                    
                    if error != nil {
                        print("Error uploading audio \(error!.localizedDescription)")
                        return
                    }
                    storageRef.downloadURL { url, error in
                        guard let dowloadUrl = url else {
                            complection(nil)
                            return
                        }
                        complection(dowloadUrl.absoluteString)
                    }
                    
                })
                
                //4. obseve percentage upload
                task.observe(StorageTaskStatus.progress) { snapshot in
                    let progress = snapshot.progress!.completedUnitCount / snapshot.progress!.totalUnitCount
                    
                    ProgressHUD.showProgress("Uploading the recording, please wait", CGFloat(progress))
                }
            }
        } else {
            print("Recored does not exist")
        }
    }
    
    // download audio
    class func downloadAudio(audioUrl: String, complection : @escaping (_ audioFileName: String) -> Void) {
        
        let audioFileName = fileNameFrom(fileUrl: audioUrl) + ".m4a"
        
        if fileExistsAtPath(path: audioFileName) {
            //get video locally
            complection(audioFileName)
            
            
        }else {
            //download video
            if audioUrl != "" {
                let documentUrl = URL(string: audioUrl)
                let downloadQueue = DispatchQueue(label: "audioDownloadQueue")
                
                downloadQueue.async {
                    let data = NSData(contentsOf: documentUrl!)
                    if data != nil {
                        FileStorage.saveFileLocally(fileData: data!, fileName: audioFileName)
                        DispatchQueue.main.async {
                            complection(audioFileName)
                        }
                        
                    }else {
                        print("no document found in database")
                    }
                }
            }
        }
        
    }
    
    // MARK: - save file locally
    class func saveFileLocally(fileData: NSData, fileName: String) {
        
        let docUrl = getDocumentUrl().appendingPathComponent(fileName, isDirectory: false)
        fileData.write(to: docUrl, atomically: true)
    }
    
}

// MARK: - Helpers
func getDocumentUrl() -> URL {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
}

func fileInDocumentsDirectory(fileName: String) -> String {
    return getDocumentUrl().appendingPathComponent(fileName).path
}

func fileExistsAtPath(path: String) -> Bool {
    return FileManager.default.fileExists(atPath: fileInDocumentsDirectory(fileName: path))
}
