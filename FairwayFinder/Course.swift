//
//  Course.swift
//  FairwayFinder
//
//  Created by Michael Ryan on 11/30/20.
//  Copyright © 2020 Michael Ryan. All rights reserved.
//

import Foundation
import CoreLocation
import Firebase
import MapKit

class Course: NSObject, MKAnnotation {
    var courseName: String
    var courseAddress: String
    var coordinate: CLLocationCoordinate2D
    var averageRating: Double
    var averageDifficulty: Double
    var averageScore: Double
    var numberOfReviews: Int
    var postingUserID: String
    var documentID: String
    // ADD IN COORDINATE LATITUDE AND LONGITUDE INTO THE DICTIONARY
    var dictionary: [String: Any] {
        return ["courseName": courseName, "courseAddress": courseAddress, "latitude": latitude, "longitude": longitude, "averageRating": averageRating, "averageDifficulty": averageDifficulty, "averageScore": averageScore, "numberOfReviews": numberOfReviews, "postingUserID": postingUserID, "documentID": documentID]
    }
    var latitude: CLLocationDegrees {
        return coordinate.latitude
    }
    var longitude: CLLocationDegrees {
        return coordinate.longitude
    }
    var location: CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    var title: String? {
        return courseName
    }
    var subtitle: String? {
        return courseAddress
    }
    
    init(courseName: String, courseAddress: String, coordinate: CLLocationCoordinate2D, averageRating: Double, averageDifficulty: Double, averageScore: Double, numberOfReviews: Int, postingUserID: String, documentID: String) {
        self.courseName = courseName
        self.courseAddress = courseAddress
        self.coordinate = coordinate
        self.averageRating = averageRating
        self.averageDifficulty = averageDifficulty
         self.averageScore = averageScore
        self.numberOfReviews = numberOfReviews
        self.postingUserID = postingUserID
        self.documentID = documentID
    }
    
    convenience override init() {
        self.init(courseName: "", courseAddress: "", coordinate: CLLocationCoordinate2D(), averageRating: 0.0, averageDifficulty: 0.0, averageScore: 0.0, numberOfReviews: 0, postingUserID: "", documentID: "" )
    }
    convenience init(dictionary: [String: Any]) {
        let courseName = dictionary["courseName"] as! String? ?? ""
        let courseAddress = dictionary["courseAddress"] as! String? ?? ""
        let latitude = dictionary["latitude"] as! Double? ?? 0.0
        let longitude = dictionary["longitude"] as! Double? ?? 0.0
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let averageRating = dictionary["averageRating"] as! Double? ?? 0.0
        let averageDifficulty = dictionary["averageDifficulty"] as! Double? ?? 0.0
        let averageScore = dictionary["averageScore"] as! Double? ?? 0.0
        let numberofReviews = dictionary["numberOfReviews"] as! Int? ?? 0
        let postingUserID = dictionary["postingUserID"] as! String? ?? ""
        self.init(courseName: courseName, courseAddress: courseAddress, coordinate: coordinate, averageRating: averageRating, averageDifficulty: averageDifficulty, averageScore: averageScore, numberOfReviews: numberofReviews, postingUserID: postingUserID, documentID: "")
        
    }
    func saveData(completion: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        guard let postingUserID = Auth.auth().currentUser?.uid else {
            print("ERROR: Could not save data")
            return completion(false)
        }
        self.postingUserID = postingUserID
        let dataToSave: [String: Any] = self.dictionary
        if self.documentID == "" {
            var ref: DocumentReference? = nil
            ref = db.collection("courses").addDocument(data: dataToSave){ (error) in
                guard error == nil else {
                    return completion(false)
                    print("ERROR: Adding document \(error!.localizedDescription)")
                }
                self.documentID = ref!.documentID
                print("Added document \(self.documentID)")
                completion(true)
            }
        } else {
            let ref = db.collection("courses").document(self.documentID)
            ref.setData(dataToSave) { (error) in
                guard error == nil else {
                    return completion(false)
                    print("ERROR: Updating document \(error!.localizedDescription)")
                }
                print("Updated document \(self.documentID)")
                completion(true)
            }
        }

    }
   func updateAvgRating(completed: @escaping() -> ()) {
        let db = Firestore.firestore()
        let reviewsRef = db.collection("courses").document(documentID).collection("reviews")
        reviewsRef.getDocuments { (querySnapshot, error) in
            guard error == nil else {
                print("Error: Failed to get querySnapshot for reviewsRef \(reviewsRef)")
                return completed()
            }
            var ratingTotal = 0.0
            for document in querySnapshot!.documents {
                let reviewDictionary = document.data()
                let rating = reviewDictionary["rating"] as! Int? ?? 0
                ratingTotal = ratingTotal + Double(rating)
            }
            self.averageRating = ratingTotal / Double(querySnapshot!.count)
            self.numberOfReviews = querySnapshot!.count
            let dataToSave = self.dictionary
            let spotRef = db.collection("courses").document(self.documentID)
            spotRef.setData(dataToSave) { (error) in
                if let error = error {
                    print("Error: updating document \(self.documentID) in spot after changing averageReview and reviewInfo \(error.localizedDescription)")
                    completed()
                } else {
                    print("New average \(self.averageRating). Document updated with ref ID \(self.documentID)")
                    completed()
                }
            }
        }
    }
  func updateAvgDifficultyRating(completed: @escaping() -> ()) {
        let db = Firestore.firestore()
        let reviewsRef = db.collection("courses").document(documentID).collection("reviews")
        reviewsRef.getDocuments { (querySnapshot, error) in
            guard error == nil else {
                print("Error: Failed to get querySnapshot for reviewsRef \(reviewsRef)")
                return completed()
            }
            var ratingTotal = 0.0
            for document in querySnapshot!.documents {
                let reviewDictionary = document.data()
                let rating = reviewDictionary["difficulty"] as! Int? ?? 0
                ratingTotal = ratingTotal + Double(rating)
            }
            self.averageDifficulty = ratingTotal / Double(querySnapshot!.count)
            self.numberOfReviews = querySnapshot!.count
            let dataToSave = self.dictionary
            let spotRef = db.collection("courses").document(self.documentID)
            spotRef.setData(dataToSave) { (error) in
                if let error = error {
                    print("Error: updating document \(self.documentID) in spot after changing averageReview and reviewInfo \(error.localizedDescription)")
                    completed()
                } else {
                    print("New difficulty average \(self.averageDifficulty). Document updated with ref ID \(self.documentID)")
                    completed()
                }
            }
        }
    }
    
    func updateAvgScoreRating(completed: @escaping() -> ()) {
        let db = Firestore.firestore()
        let reviewsRef = db.collection("courses").document(documentID).collection("reviews")
        reviewsRef.getDocuments { (querySnapshot, error) in
            guard error == nil else {
                print("Error: Failed to get querySnapshot for reviewsRef \(reviewsRef)")
                return completed()
            }
            var ratingTotal = 0.0
            for document in querySnapshot!.documents {
                let reviewDictionary = document.data()
                let rating = reviewDictionary["score"] as! Int? ?? 0
                ratingTotal = ratingTotal + Double(rating)
            }
            self.averageScore = ratingTotal / Double(querySnapshot!.count)
            self.numberOfReviews = querySnapshot!.count
            let dataToSave = self.dictionary
            let spotRef = db.collection("courses").document(self.documentID)
            spotRef.setData(dataToSave) { (error) in
                if let error = error {
                    print("Error: updating document \(self.documentID) in spot after changing averageReview and reviewInfo \(error.localizedDescription)")
                    completed()
                } else {
                    print("New difficulty average \(self.averageScore). Document updated with ref ID \(self.documentID)")
                    completed()
                }
            }
        }
    }
    
}
