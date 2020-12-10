//
//  CourseReviewTableViewCell.swift
//  FairwayFinder
//
//  Created by Michael Ryan on 12/1/20.
//  Copyright © 2020 Michael Ryan. All rights reserved.
//

import UIKit

class CourseReviewTableViewCell: UITableViewCell {

    @IBOutlet weak var ratingLabel: UILabel!
    
    @IBOutlet weak var difficultyLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var handicapLabel: UILabel!
    
    var review: Review! {
        didSet {
            ratingLabel.text = "\(review.rating)"
            difficultyLabel.text = "\(review.difficulty)"
            handicapLabel.text = "\(review.handicap)"
            scoreLabel.text = "\(review.score)"
        }
    }
    
    
}
