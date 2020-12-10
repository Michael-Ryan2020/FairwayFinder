//
//  ReviewTableViewController.swift
//  FairwayFinder
//
//  Created by Michael Ryan on 11/30/20.
//  Copyright © 2020 Michael Ryan. All rights reserved.
//

import UIKit
import Firebase

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .none
    return dateFormatter
}()

class ReviewTableViewController: UITableViewController {

    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var ratingTextView: UITextField!
    
    @IBOutlet weak var difficultyTextView: UITextField!
    
    @IBOutlet weak var handicapTextView: UITextField!
    
    @IBOutlet weak var scoreTextView: UITextField!
    
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var reviewTextView: UITextView!
    @IBOutlet weak var postedByLabel: UILabel!
    
    var review: Review!
    var course: Course!
    
    let numbers = [1,2,3,4,5,6,7,8,9,10]
    let handicap = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36]
    let score = [60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120]
    var ratingPicker = UIPickerView()
    var difficultyPicker = UIPickerView()
    var handicapPicker = UIPickerView()
    var scorePicker = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        ratingTextView.inputView = ratingPicker
        difficultyTextView.inputView = difficultyPicker
        handicapTextView.inputView = handicapPicker
        scoreTextView.inputView = scorePicker
        ratingPicker.delegate = self
        ratingPicker.dataSource = self
        difficultyPicker.delegate = self
        difficultyPicker.dataSource = self
        handicapPicker.delegate = self
        handicapPicker.dataSource = self
        scorePicker.delegate = self
        scorePicker.dataSource = self
        ratingPicker.tag = 1
        difficultyPicker.tag = 2
        handicapPicker.tag = 3
        scorePicker.tag = 4
        ratingTextView.textAlignment = .center
        difficultyTextView.textAlignment = .center
        handicapTextView.textAlignment = .center
        scoreTextView.textAlignment = .center
        guard course != nil else {
            print("Error: No spot passed to ReviewTableViewController.swift")
            return
        }
        if review == nil {
            review = Review()
        }
        updateUserInterface()
        
        

        
    }
    func updateUserInterface() {
        nameLabel.text = course.courseName
        reviewTextView.text = review.text
        ratingTextView.text = "\(review.rating)"
        difficultyTextView.text = "\(review.difficulty)"
        handicapTextView.text = "\(review.handicap)"
        scoreTextView.text = "\(review.score)"
        postedByLabel.text = "post date: \(dateFormatter.string(from: review.date))"
        if review.documentID == "" {
            addBordersToEditableObjects()
        } else {
            if review.reviewUserID == Auth.auth().currentUser?.uid {
                self.navigationItem.leftItemsSupplementBackButton = false
                saveBarButton.title = "Update"
                addBordersToEditableObjects()
                deleteButton.isHidden = false
            } else {
                saveBarButton.hide()
                cancelBarButton.hide()
                ratingTextView.isEnabled = false
                ratingTextView.borderStyle = .none
                difficultyTextView.isEnabled = false
                difficultyTextView.borderStyle = .none
                handicapTextView.isEnabled = false
                handicapTextView.borderStyle = .none
                scoreTextView.isEnabled = false
                scoreTextView.borderStyle = .none
                reviewTextView.isEditable = false
                ratingTextView.backgroundColor = .white
                difficultyTextView.backgroundColor = .white
                handicapTextView.backgroundColor = .white
                scoreTextView.backgroundColor = .white
                reviewTextView.backgroundColor = .white
            }
        }
    }
    func updateFromInterface() {
        review.text = reviewTextView.text!
        review.rating = Int(ratingTextView.text!)!
        review.difficulty = Int(difficultyTextView.text!)!
        review.handicap = Int(handicapTextView.text!)!
        review.score = Int(scoreTextView.text!)!

        
    }
    func addBordersToEditableObjects() {
        reviewTextView.addBorders(width: 0.5, radius: 5.0, color: .black)
        ratingTextView.addBorders(width: 0.5, radius: 5.0, color: .black)
        difficultyTextView.addBorders(width: 0.5, radius: 5.0, color: .black)
        handicapTextView.addBorders(width: 0.5, radius: 5.0, color: .black)
        scoreTextView.addBorders(width: 0.5, radius: 5.0, color: .black)
       
       
    }

    func leaveViewController() {
           let isPresentingInAddMode = presentingViewController is UINavigationController
           if isPresentingInAddMode {
               dismiss(animated: true, completion: nil)
           } else {
               navigationController?.popViewController(animated: true)
           }
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        review.deleteData(course: course) { (success) in
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
        updateFromInterface()
        review.saveData(course: course) { (success) in
            if success {
                self.leaveViewController()
            } else {
                 print("ERROR: Can't unwind segue from Review because of review saving error")
            }
        }
        
    }
    
}
extension ReviewTableViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 1:
            return numbers.count
        case 2:
            return numbers.count
        case 3:
            return handicap.count
        case 4:
            return score.count
        default:
            return 0
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case 1:
            return "\(numbers[row])"
        case 2:
            return "\(numbers[row])"
        case 3:
            return "\(handicap[row])"
        case 4:
            return "\(score[row])"
        default:
            return "This shouldn't happen"
        }
        
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 1:
            ratingTextView.text = "\(numbers[row])"
            ratingTextView.resignFirstResponder()
        case 2:
            difficultyTextView.text = "\(numbers[row])"
            difficultyTextView.resignFirstResponder()
        case 3:
            handicapTextView.text = "\(handicap[row])"
            handicapTextView.resignFirstResponder()
        case 4:
            scoreTextView.text = "\(score[row])"
            scoreTextView.resignFirstResponder()
        default:
            return
        }
        
    }
    
    
}
