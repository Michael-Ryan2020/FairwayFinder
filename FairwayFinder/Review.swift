//
//  Review.swift
//  FairwayFinder
//
//  Created by Michael Ryan on 12/1/20.
//  Copyright © 2020 Michael Ryan. All rights reserved.
//

import Foundation
import Firebase

class Review {
    var rating: Int
    var difficulty: Int
    var handicap: Int
    var score: Int
    var text: String
    var date: Date
    var reviewUserID: String
    var documentID: String
    
    var dictionary: [String: Any] {
        let timeIntervalDate = date.timeIntervalSince1970
        return ["rating": rating, "difficulty": difficulty, "handicap": handicap, "score": score, "text": text, "date": timeIntervalDate, "reviewUserID": reviewUserID]
    }
    init(rating: Int, difficulty: Int, handicap: Int, score: Int, text: String, date: Date,reviewUserID: String, documentID: String) {
        self.rating = rating
        self.difficulty = difficulty
        self.handicap = handicap
        self.score = score
        self.text = text
        self.date = date
        self.reviewUserID = reviewUserID
        self.documentID = documentID
    }
    convenience init() {
        let reviewUserID = Auth.auth().currentUser?.uid ?? ""
        self.init(rating: 0, difficulty: 0, handicap: 0, score: 0, text: "", date: Date(), reviewUserID: reviewUserID, documentID: "")
    }
    convenience init(dictionary: [String: Any]) {
        let rating = dictionary["rating"] as! Int? ?? 0
        let difficulty = dictionary["difficulty"] as! Int? ?? 0
        let handicap = dictionary["handicap"] as! Int? ?? 0
        let score = dictionary["score"] as! Int? ?? 0
        let text = dictionary["text"] as! String? ?? ""
        let timeIntervalDate = dictionary["date"] as! TimeInterval? ?? TimeInterval()
        let date = Date(timeIntervalSince1970: timeIntervalDate)
        let reviewUserID = dictionary["reviewUserID"] as! String? ?? ""
        let documentID = dictionary["documentID"] as! String? ?? ""
        
        
        
        self.init(rating: rating, difficulty: difficulty, handicap: handicap, score: score, text: text, date: date, reviewUserID: reviewUserID, documentID: documentID)
    }
    
    
    func saveData(course: Course, completion: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        
        let dataToSave: [String: Any] = self.dictionary
        if self.documentID == "" {
            var ref: DocumentReference? = nil
            ref = db.collection("courses").document(course.documentID).collection("reviews").addDocument(data: dataToSave){ (error) in
                guard error == nil else {
                    print("ERROR: Adding document \(error!.localizedDescription)")
                    return completion(false)
                    
                }
                self.documentID = ref!.documentID
                print("Added document \(self.documentID) to spot \(course.documentID)")
                course.updateAvgDifficultyRating {
                    completion(true)
                }
                course.updateAvgRating {
                    completion(true)
                }
                course.updateAvgScoreRating {
                    completion(true)
                }
                
        
            }
        } else {
            let ref = db.collection("courses").document(course.documentID).collection("reviews").document(self.documentID)
            ref.setData(dataToSave) { (error) in
                guard error == nil else {
                    print("ERROR: Updating document \(error!.localizedDescription) in spot: \(course.documentID)")
                    return completion(false)
                    
                }
                print("Updated document \(self.documentID)")
               
                course.updateAvgDifficultyRating {
                    completion(true)
                }
                course.updateAvgRating {
                    completion(true)
                               }
                course.updateAvgScoreRating {
                    completion(true)
                }
                    
            }
        }

    }
    func deleteData(course: Course, completion: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        db.collection("courses").document(course.documentID).collection("reviews").document(documentID).delete { (error) in
            if let error = error {
                print("Error: deleting review document ID \(self.documentID). Error: \(error.localizedDescription) ")
                completion(false)
            } else {
                print("Successfuly deleted document \(self.documentID)")
                course.updateAvgRating {
                    completion(true)
                }
                course.updateAvgDifficultyRating {
                    completion(true)
                }
                course.updateAvgScoreRating {
                    completion(true)
                               }
                               
            }
        }
    }
    
}
