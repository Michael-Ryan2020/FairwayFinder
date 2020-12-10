//
//  CourseReviewsViewController.swift
//  FairwayFinder
//
//  Created by Michael Ryan on 11/30/20.
//  Copyright © 2020 Michael Ryan. All rights reserved.
//

import UIKit
import GooglePlaces
import MapKit
import Contacts

class CourseReviewsViewController: UIViewController {
    
    @IBOutlet weak var courseNameTextField: UITextField!
    
    @IBOutlet weak var addressNameTextField: UITextField!
    
    @IBOutlet weak var ratingLabel: UILabel!
    
    @IBOutlet weak var difficultyLabel: UILabel!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    
    
//    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    
    var course: Course!
    var photo: Photo!
    var photos: Photos!
    let regionDistance: CLLocationDegrees = 750.0
    var locationManager: CLLocationManager!
    var reviews: Reviews!
    var imagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        tableView.delegate = self
        tableView.dataSource = self
        imagePickerController.delegate = self
        getLocation()
        if course == nil {
            course = Course()
        } else {
            disableTextEditing()
            cancelBarButton.hide()
            saveBarButton.hide()
            navigationController?.setToolbarHidden(true, animated: true)
        }
//        setupMapView()
        reviews = Reviews()
        updateUserInterface()
        

       
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if course.documentID != "" {
            self.navigationController?.setToolbarHidden(true, animated: true)
        }
        reviews.loadData(course: course) {
            self.tableView.reloadData()
            if self.reviews.reviewArray.count == 0 {
                self.ratingLabel.text = ""
                self.difficultyLabel.text = ""
                self.scoreLabel.text = ""
            } else {
                let sum = self.reviews.reviewArray.reduce(0) { $0 + $1.rating }
                var avgRating = Double(sum)/Double(self.reviews.reviewArray.count)
                avgRating = ((avgRating * 10).rounded())/10
                self.ratingLabel.text = "\(avgRating)"
                let difficultySum = self.reviews.reviewArray.reduce(0) { $0 + $1.difficulty }
                var avgdifficultyRating = Double(difficultySum)/Double(self.reviews.reviewArray.count)
                avgdifficultyRating = ((avgdifficultyRating * 10).rounded())/10
                self.difficultyLabel.text = "\(avgdifficultyRating)"
                let scoreSum = self.reviews.reviewArray.reduce(0) { $0 + $1.score }
                var avgscoreRating = Double(scoreSum)/Double(self.reviews.reviewArray.count)
                avgscoreRating = ((avgscoreRating * 10).rounded())/10
                self.scoreLabel.text = "\(avgscoreRating)"
                
            }
        }
    }
//    func setupMapView() {
//        let region = MKCoordinateRegion(center: course.coordinate, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
//        mapView.setRegion(region, animated: true)
//    }
    func updateUserInterface() {
        courseNameTextField.text = course.courseName
        addressNameTextField.text = course.courseAddress
//        updateMap()
    }
    func disableTextEditing() {
        courseNameTextField.isEnabled = false
        addressNameTextField.isEnabled = false
        courseNameTextField.backgroundColor = .clear
        addressNameTextField.backgroundColor = .clear
        courseNameTextField.borderStyle = .none
        addressNameTextField.borderStyle = .none
        
    }
//    func updateMap() {
//        mapView.removeAnnotations(mapView.annotations)
//        mapView.addAnnotation(course)
//        mapView.setCenter(course.coordinate, animated: true)
//    }
    func updateFromUserInterface() {
        course.courseName = courseNameTextField.text!
        course.courseAddress = addressNameTextField.text!
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        updateFromUserInterface()
        switch segue.identifier ?? "" {
        case "AddReview":
            let navigationController = segue.destination as! UINavigationController
            let destination = navigationController.viewControllers.first as! ReviewTableViewController
            destination.course = course
        case "ShowReview":
            let destination = segue.destination as! ReviewTableViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow!
            destination.review = reviews.reviewArray[selectedIndexPath.row]
            destination.course = course
            
        case "AddPhoto":
        let navigationController = segue.destination as! UINavigationController
        let destination = navigationController.viewControllers.first as! PhotoViewController
        destination.course = course
        destination.photo = photo
        case "BrowsePhoto":
            let navigationController = segue.destination as! UINavigationController
            let destination = navigationController.viewControllers.first as! BrowsePhotosViewController
            destination.course = course 
            
            print("TODO")
        default:
             print("Couldn't find a case for segue identifier. Shouldn't have happened")
        }
       
    }
    func saveCancelAlert(title: String, message: String, segueIdentifier: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { (_) in
            self.course.saveData { (success) in
                self.saveBarButton.title = "Done"
                self.cancelBarButton.hide()
                self.navigationController?.setToolbarHidden(true, animated: true)
                self.disableTextEditing()
                if segueIdentifier == "AddReview" {
                    self.performSegue(withIdentifier: segueIdentifier, sender: nil)
               } else {
                   self.cameraOrLibraryAlert()
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        updateFromUserInterface()
        course.saveData { (success) in
            if success {
                self.leaveViewController()
            } else {
                self.oneButtonAlert(title: "Save Failed", message: "For some reason, the data would not save to the cloud")
            }
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        leaveViewController()
    }
    func leaveViewController() {
           let isPresentingInAddMode = presentingViewController is UINavigationController
           if isPresentingInAddMode {
               dismiss(animated: true, completion: nil)
           } else {
               navigationController?.popViewController(animated: true)
           }
    }
    func cameraOrLibraryAlert() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let photoLibaryAction = UIAlertAction(title: "Photo Library", style: .default) { (_) in
            self.accessPhotoLibrary()
            }
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (_) in
            self.accessCamera()
            
        }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
        alertController.addAction(photoLibaryAction)
        alertController.addAction(cameraAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func findLocationButtonPressed(_ sender: UIBarButtonItem) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        // Display the autocomplete view controller.
        present(autocompleteController, animated: true, completion: nil)
    }
    
    @IBAction func reviewButtonPressed(_ sender: UIButton) {
        if course.documentID == "" {
            saveCancelAlert(title: "This venue has not been saved", message: "You must save this venue before you can review it", segueIdentifier: "AddReview")
        } else {
         performSegue(withIdentifier: "AddReview", sender: nil)
        }
        
    }
    
    @IBAction func photoButtonPressed(_ sender: UIButton) {
        if course.documentID == "" {
            saveCancelAlert(title: "This venue has not been saved", message: "You must save this venue before you can review it", segueIdentifier: "AddPhoto")
        } else {
         cameraOrLibraryAlert()
        }
    }
    @IBAction func browseButtonPressed(_ sender: UIButton) {
        if course.documentID == "" {
            saveCancelAlert(title: "This venue has not been saved", message: "You must save this venue before you can add a photo to it", segueIdentifier: "BrowsePhoto")
        } else {
         performSegue(withIdentifier: "BrowsePhoto", sender: nil)
        }

    }
    
    
    @IBAction func nameFieldChanged(_ sender: UITextField) {
        let noSpaces = courseNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if noSpaces != "" {
            saveBarButton.isEnabled = true
        } else {
            saveBarButton.isEnabled = false
        }
    }
    
    
}
extension CourseReviewsViewController: GMSAutocompleteViewControllerDelegate {

  // Handle the user's selection.
  func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
    course.courseName = place.name ?? "Unknown Place"
    course.courseAddress = place.formattedAddress ?? "Unknown Address"
    course.coordinate = place.coordinate
    updateUserInterface()
    dismiss(animated: true, completion: nil)
  }

  func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
    // TODO: handle the error.
    print("Error: ", error.localizedDescription)
  }

  // User canceled the operation.
  func wasCancelled(_ viewController: GMSAutocompleteViewController) {
    dismiss(animated: true, completion: nil)
  }

  // Turn the network activity indicator on and off again.
 

}

extension CourseReviewsViewController: CLLocationManagerDelegate {
    func getLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("Checking authorization status")
        handleAuthorizationStatus(status: status)
    }
    func handleAuthorizationStatus(status: CLAuthorizationStatus) {
        switch status {
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            self.oneButtonAlert(title: "Location Services Denied", message: "It may be that parental controls are restricting location use in this app")
        case .denied:
            showAlertToPrivacySettings(title: "User has not Authorized Location Services", message: "Select 'Settings' below to enable device settings and enable location services for this app.")
        case .authorizedAlways,.authorizedWhenInUse:
            locationManager.requestLocation()
        @unknown default:
            print("DEVELOPER ALERT: Unknown case of status in handleAuthorizationStatus \(status)")
        }
    }
    func showAlertToPrivacySettings(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            print("Something went wrong")
            return
        }
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) in
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = locations.last ?? CLLocation()
        print("Updating Location is \(currentLocation.coordinate.latitude) \(currentLocation.coordinate.longitude)")
        var name = ""
        var address = ""
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(currentLocation) { (placemarks, error) in
            if error != nil {
                print("ERROR: retrieving place. \(error!.localizedDescription)")
            }
            if placemarks != nil {
                let placemark = placemarks?.last
                name = placemark?.name ?? "Name Unknown"
                if let postalAddress = placemark?.postalAddress {
                    address = CNPostalAddressFormatter.string(from: postalAddress, style: .mailingAddress)
                }
            } else {
                print("ERROR: retrieving placemark.")
                
            }
            if self.course.courseName == "" && self.course.courseAddress == "" {
                self.course.courseName = name
                self.course.courseAddress = address
                self.course.coordinate = currentLocation.coordinate
            }        
            self.updateUserInterface()
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("ERROR: \(error.localizedDescription). Failed to get device location")
    }
}
extension CourseReviewsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.reviewArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as! CourseReviewTableViewCell
        cell.review = reviews.reviewArray[indexPath.row]
        return cell 
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    
}
extension CourseReviewsViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        photo = Photo()
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            photo.image = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            photo.image = originalImage }
        dismiss(animated: true) {
            self.performSegue(withIdentifier: "AddPhoto", sender: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    func accessPhotoLibrary() {
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    func accessCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            imagePickerController.sourceType = .camera
            present(imagePickerController, animated: true, completion: nil)
        }
        else{
            self.oneButtonAlert(title: "Camera Not Avaliable", message: "There is no camera avaliable on this device")
        }
    }
}
