//
//  Photos.swift
//  FairwayFinder
//
//  Created by Michael Ryan on 12/4/20.
//  Copyright © 2020 Michael Ryan. All rights reserved.
//

import Foundation
import Firebase

class Photos {
    var photoArray: [Photo] = []
    
    var db: Firestore!
    
    init() {
        db = Firestore.firestore()
    }
    func loadData(course: Course, completed: @escaping () -> ()) {
        guard course.documentID != "" else {
            return
        }
        db.collection("courses").document(course.documentID).collection("photos").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("ERROR: adding the snapshot listener \(error!.localizedDescription)")
                return completed()
            }
            self.photoArray = []
            for document in querySnapshot!.documents {
                let photo = Photo(dictionary: document.data())
                photo.documentID = document.documentID
                self.photoArray.append(photo)
            }
            completed()
        }
    }
}


