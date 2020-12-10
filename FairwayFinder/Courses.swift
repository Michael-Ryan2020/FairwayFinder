//
//  Courses.swift
//  FairwayFinder
//
//  Created by Michael Ryan on 11/30/20.
//  Copyright © 2020 Michael Ryan. All rights reserved.
//

import Foundation
import Firebase

class Courses {
    var courseArray: [Course] = []
    var db: Firestore!
    
    init() {
        db = Firestore.firestore()
    }
    func loadData(completed: @escaping () -> ()) {
        db.collection("courses").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("ERROR: adding the snapshot listener \(error!.localizedDescription)")
                return completed()
            }
            self.courseArray = []
            for document in querySnapshot!.documents {
                let course = Course(dictionary: document.data())
                course.documentID = document.documentID
                self.courseArray.append(course)
            }
            completed()
        }
    }
}
