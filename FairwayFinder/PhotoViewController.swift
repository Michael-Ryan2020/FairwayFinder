//
//  PhotoViewController.swift
//  FairwayFinder
//
//  Created by Michael Ryan on 12/3/20.
//  Copyright © 2020 Michael Ryan. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .none
    return dateFormatter
}()

class PhotoViewController: UIViewController {

    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    
    @IBOutlet weak var deleteBarButton: UIBarButtonItem!
    @IBOutlet weak var postedOnLabel: UILabel!
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    var course: Course!
    var photo: Photo!
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        guard course != nil else {
            print("Error: No spot passed to PhotoViewController.swift")
            return
        }
        if photo == nil {
            photo = Photo()
            
        }
        updateUserInterface()
        

        
    }
    func updateUserInterface() {
        postedOnLabel.text = "posted on: \(dateFormatter.string(from: photo.date))"
        photoImageView.image = photo.image
        if photo.documentID == "" {
            print("This doesn't matter")
        } else {
            if photo.photoUserID == Auth.auth().currentUser?.uid {
                self.navigationItem.leftItemsSupplementBackButton = false
                saveBarButton.title = "Update"
                self.navigationController?.setToolbarHidden(false, animated: true)
            } else {
                saveBarButton.hide()
                cancelBarButton.hide()
            
            }
        }
        guard let url = URL(string: photo.photoURL) else {
            
            photoImageView.image = photo.image
                   return
               }
               photoImageView.sd_imageTransition = .fade
               photoImageView.sd_imageTransition?.duration = 0.5
               photoImageView.sd_setImage(with: url)
    }
    func updateFromUserInterface() {
        photo.image = photoImageView.image!
    }
    func leaveViewController() {
           let isPresentingInAddMode = presentingViewController is UINavigationController
           if isPresentingInAddMode {
               dismiss(animated: true, completion: nil)
           } else {
               navigationController?.popViewController(animated: true)
           }
    }
    

    @IBAction func deleteButtonPressed(_ sender: UIBarButtonItem) {
        photo.deleteData(course: course) { (success) in
            if success {
                self.leaveViewController()
            } else {
                print("Delete unsuccessful")
            }
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        leaveViewController()
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
//        leaveViewController()
        updateFromUserInterface()
        photo.saveData(course: course) { (success) in
            if success {
                    self.leaveViewController()
                } else {
                    print("ERROR: Can't unwind segue from Photo because of photo saving error")
                }
        }
    }
    

}
