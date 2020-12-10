//
//  Photo.swift
//  FairwayFinder
//
//  Created by Michael Ryan on 12/4/20.
//  Copyright © 2020 Michael Ryan. All rights reserved.
//

import UIKit
import Firebase

class Photo {
    var image: UIImage
    var photoUserID: String
    var date: Date
    var photoURL: String
    var documentID: String
    
    var dictionary: [String: Any] {
        let timeIntervalDate = date.timeIntervalSince1970
        return ["photoUserID": photoUserID, "date": timeIntervalDate, "photoURL": photoURL]
    }
    init(image: UIImage, photoUserID: String, date: Date, photoURL: String, documentID: String) {
        self.image = image
        self.photoUserID = photoUserID
        self.date = date
        self.photoURL = photoURL
        self.documentID = documentID
        
    }
    convenience init() {
        let photoUserID = Auth.auth().currentUser?.uid ?? ""
        self.init(image: UIImage(), photoUserID: photoUserID, date: Date(), photoURL: "", documentID: "")
    }
    convenience init(dictionary: [String: Any]) {
           let photoUserID = dictionary["photoUserID"] as! String? ?? ""
           let timeIntervalDate = dictionary["date"] as! TimeInterval? ?? TimeInterval()
           let date = Date(timeIntervalSince1970: timeIntervalDate)
           let photoURL = dictionary["photoURL"] as! String? ?? ""
           
       
           
           
          self.init(image: UIImage(), photoUserID: photoUserID, date: date, photoURL: photoURL, documentID: "")
       }
    
    func saveData(course: Course, completion: @escaping (Bool) -> ()) {
           let db = Firestore.firestore()
           let storage = Storage.storage()
           
           guard let photoData = self.image.jpegData(compressionQuality: 0.5) else {
               print("Error: could not convert photo.image to data")
               return
           }
           
           let uploadMetaData = StorageMetadata()
           uploadMetaData.contentType = "image/jpeg"
           
           if documentID == "" {
               documentID = UUID().uuidString
           }
           
               let storageRef = storage.reference().child(course.documentID).child(documentID)
               
               let uploadTask = storageRef.putData(photoData, metadata: uploadMetaData) { (metadata, error) in
                   if let error = error {
                       print("Error: upload for ref \(uploadMetaData) failed. \(error.localizedDescription)")
                   }
               }
           uploadTask.observe(.success) { (snapshot) in
               print("Upload to firebase storage was successful")
               
               
               storageRef.downloadURL { (url, error) in
                   guard error == nil else {
                       print("Error: could not create download url \(error!.localizedDescription)")
                       return completion(false)
                   }
                   guard let url = url else {
                        print("Error: url was nil and this should not have happened")
                       return completion(false)
                   }
                   self.photoURL = "\(url)"
                   
                   let dataToSave: [String: Any] = self.dictionary
                              let ref = db.collection("courses").document(course.documentID).collection("photos").document(self.documentID)
                              ref.setData(dataToSave) { (error) in
                                  guard error == nil else {
                                   print("ERROR: Updating document \(error!.localizedDescription) in spot: \(course.documentID)")
                                      return completion(false)
                                      
                                  }
                                  print("Updated document \(self.documentID)")
                                  completion(true)
                              }
               }
              
           }
           uploadTask.observe(.failure) { (snapshot) in
               if let error = snapshot.error {
                   print("Error: upload task for file \(self.documentID) failed, in spot \(course.documentID), with error \(error.localizedDescription)")
                   
               }
               completion(false)
           }
               
       }
    func loadImage(course: Course, completion: @escaping (Bool) -> ()) {
           guard course.documentID != "" else {
               print("ERROR: did not pass a valid spot into loadImage")
               return
           }
           let storage = Storage.storage()
           let storageRef = storage.reference().child(course.documentID).child(documentID)
           storageRef.getData(maxSize: 25 * 1024 * 1024) { (data, error) in
               if let error = error {
                   print("ERROR: an error occurred while reading data from file ref: \(storageRef) error = \(error.localizedDescription)")
                   return completion(false)
               } else {
                   self.image = UIImage(data: data!) ?? UIImage()
                   return completion(true)
               }
           }
       }
    func deleteData(course: Course, completion: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        db.collection("courses").document(course.documentID).collection("photos").document(documentID).delete { (error) in
            if let error = error {
                print("Error: deleting photo document ID \(self.documentID). Error: \(error.localizedDescription) ")
                completion(false)
            } else {
                self.deleteImage(course: course)
                print("Successfuly deleted document \(self.documentID)")
                completion(true)
            }
        }
    }
    private func deleteImage(course: Course) {
        guard course.documentID != "" else {
            print("ERROR: Did not have valid spot into deleteImage")
            return
        }
        let storage = Storage.storage()
        let storageRef = storage.reference().child(course.documentID).child(documentID)
        storageRef.delete {error in
            if let error = error {
                print("Error could not delete photo \(error.localizedDescription)")
            } else {
                print("photo successfully deleted")
            }
        }
        
    }
       
}
