//
//  BrowsePhotosViewController.swift
//  FairwayFinder
//
//  Created by Michael Ryan on 12/4/20.
//  Copyright © 2020 Michael Ryan. All rights reserved.
//

import UIKit

class BrowsePhotosViewController: UIViewController {
    
    var photos: Photos!
    var course: Course!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var backBarButton: UIBarButtonItem!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        photos = Photos()
        collectionView.delegate = self
        collectionView.dataSource = self

       
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        photos.loadData(course: course) {
            self.collectionView.reloadData()
        }
    }
    func leaveViewController() {
           let isPresentingInAddMode = presentingViewController is UINavigationController
           if isPresentingInAddMode {
               dismiss(animated: true, completion: nil)
           } else {
               navigationController?.popViewController(animated: true)
           }
    }

    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        leaveViewController()
    }
    
   
}
extension BrowsePhotosViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.photoArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let photoCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! CoursePhotoCollectionViewCell
        photoCell.course = course
        photoCell.photo = photos.photoArray[indexPath.row]
        return photoCell
    }
    
    
}
