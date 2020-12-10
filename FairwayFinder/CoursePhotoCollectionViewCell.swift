//
//  CoursePhotoCollectionViewCell.swift
//  FairwayFinder
//
//  Created by Michael Ryan on 12/4/20.
//  Copyright © 2020 Michael Ryan. All rights reserved.
//

import UIKit
import SDWebImage

class CoursePhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    var course: Course!
    var photo: Photo! {
        didSet {
            if let url = URL(string: self.photo.photoURL) {
                self.photoImageView.sd_imageTransition = .fade
                self.photoImageView.sd_imageTransition?.duration = 0.2
                self.photoImageView.sd_setImage(with: url)
                
            } else {
                print("URL Didn't work: \(self.photo.photoURL)")
                self.photo.loadImage(course: self.course) { (success) in
                    self.photo.saveData(course: self.course) { (success) in
                        print("Image updated with url \(self.photo.photoURL)")
                    }
                }
            }
//            photo.loadImage(course: course) { (success) in
//                if success {
//                    self.photoImageView.image = self.photo.image
//                } else {
//                    print("ERROR: no success in loading photo in CoursePhotoCollectionViewCell")
//                }
//            }
        }
    }
}
