//
//  CourseTableViewCell.swift
//  FairwayFinder
//
//  Created by Michael Ryan on 11/30/20.
//  Copyright © 2020 Michael Ryan. All rights reserved.
//

import UIKit
import CoreLocation

class CourseTableViewCell: UITableViewCell {

    
    @IBOutlet weak var courseNameLabel: UILabel!
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var difficultyLabel: UILabel!
    
    @IBOutlet weak var ratingLabel: UILabel!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
  
    
    var currentLocation: CLLocation!
    var course: Course! {
        didSet {
            courseNameLabel.text = course.courseName
            let roundedAvg = ((course.averageRating * 10).rounded()) / 10
            ratingLabel.text = "Avg. Rating: \(roundedAvg)"
            let roundedDifficultyAvg = ((course.averageDifficulty * 10).rounded()) / 10
            difficultyLabel.text = "Avg. Difficulty: \(roundedDifficultyAvg)"
            let roundedScoreAvg = ((course.averageScore * 10).rounded()) / 10
            scoreLabel.text = "Avg. Score: \(roundedScoreAvg)"
            
            guard let currentLocation = currentLocation else {
                distanceLabel.text = "Distance: -.-"
                return
            }
            let distanceInMeters = course.location.distance(from: currentLocation)
            let distanceInMiles = ((distanceInMeters * 0.00062137) * 10).rounded() / 10
            distanceLabel.text = "Distance: \(distanceInMiles) miles"
        }
    }
}
