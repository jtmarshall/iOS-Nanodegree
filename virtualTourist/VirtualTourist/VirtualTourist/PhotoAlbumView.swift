//
//  PhotoAlbumView.swift
//  VirtualTourist
//
//  Created by Jordan  on 7/10/17.
//  Copyright © 2017 Jordan . All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class PhotoAlbumView: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var barButton: UIBarButtonItem!
    
    var tappedPin: Pin?
    var coordinate: CLLocationCoordinate2D?
    var latitude: Double?
    var longitude: Double?
    var numberOfPagesAvail: Int?
    
    // Array of cells that user taps for deletion
    var tappedIndexPaths = [IndexPath]()
    var insertedIndexPaths: [IndexPath]!
    var deletedIndexPaths: [IndexPath]!
    var updatedIndexPaths: [IndexPath]!
    
    lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        
        // Fetch request to specify what objects to track
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        fr.sortDescriptors = [NSSortDescriptor(key: "imageURL", ascending: true)]
        
        // Only want the photos associated with the current pin
        fr.predicate = NSPredicate(format: "pin = %@", self.tappedPin!)
        
        // Return the FetchedResultsController
        return NSFetchedResultsController(fetchRequest: fr, managedObjectContext: self.stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
    }()
    
    // Get the stack
    let stack = (UIApplication.shared.delegate as! AppDelegate).stack
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showPin()
        
        fetchedResultsController.delegate = self
        
        // Check if pin has photos in Core Data
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Error while trying to perform a search: \n\(error)\n\(fetchedResultsController)")
        }
        
        let fetchedObjects = fetchedResultsController.fetchedObjects
        
        // If no photos in Core Data, then load photos from Flickr
        if fetchedObjects?.count == 0 {
            loadPhotosFromFlickr(pageNumber: 1)
        }
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func showPin() {
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate!
        mapView.addAnnotation(annotation)
        
        // Center map for the pin
        self.mapView.centerCoordinate = self.coordinate!
        // Coordinate Span
        let coordinateSpan = MKCoordinateSpanMake(60,60)
        // Set Region
        let coordinateRegion = MKCoordinateRegion(center: coordinate!, span: coordinateSpan)
        self.mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func loadPhotosFromFlickr(pageNumber: Int) {
        FlickrClient.sharedInstance().getLocationPhotos(latitude: latitude!, longitude: longitude!, pageNumber: pageNumber) { (success, urlArray, error) in
            
            if success {
                for url in urlArray! {
                    
                    // Insert photo into the context
                    _ = Photo(pin: self.tappedPin!, imageURL: url as String, context: self.stack.context)
                }
                
                do {
                    try self.stack.context.save()
                } catch {
                    print("Error saving url")
                }
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
                
            } else {
                print("Error loading photos")
            }
        }
    }
    
    // Delete photos selected by user from Core Data
    func deleteSelectedPhotos() {
        
        // Delete selected photos at indices
        for indexPath in tappedIndexPaths {
            
            stack.context.delete(fetchedResultsController.object(at: indexPath as IndexPath) as! Photo)
        }
        
        do {
            try stack.context.save()
        } catch {
            print("Error context after deleting photos")
        }
        
        collectionView.reloadData()
    }
    
    // Remove all photos when user gets new images
    func deleteAllPhotos() {
        
        for object in fetchedResultsController.fetchedObjects! {
            stack.context.delete(object as! Photo)
            do {
                try stack.context.save()
            } catch {
                print("Error saving delete")
            }
        }
    }
    
    @IBAction func barButtonPressed(_ sender: Any) {
        // If images selected first
        if barButton.title == "Remove Selected Images" {
            
            deleteSelectedPhotos()
            
            barButton.title = "Get Images"
            
        } else {
            // If Get Images pressed
            deleteAllPhotos()
            
            FlickrClient.sharedInstance().getNumberOfPages(latitude: self.latitude!, longitude: self.longitude!) { (success, numberOfPages, error) in
                
                if success {
                    
                    let pageNumber = (arc4random_uniform(UInt32(numberOfPages!)))
                    print("Page#: ", pageNumber)
                    self.loadPhotosFromFlickr(pageNumber: Int(pageNumber))
                }
            }
        }
    }
}

extension PhotoAlbumView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        // Return number of objects in Core Data
        return fetchedResultsController.sections![0].numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        
        cell.activityIndicatorView.startAnimating()
        cell.activityIndicatorView.hidesWhenStopped = true;

        // Access to already downloaded photo urls
        let photoToLoad = fetchedResultsController.object(at: indexPath) as! Photo
        
        // If no photos then get from Flickr.
        if photoToLoad.imageData == nil {
            FlickrClient.sharedInstance().downloadPhotoWith(url: photoToLoad.imageURL!) { (success, imageData, error) in
                
                DispatchQueue.main.async {
                    cell.imageView.image = UIImage(data: imageData as! Data)
                    cell.activityIndicatorView.stopAnimating()
                }
                
                // Save the photo's imageData to Core Data.
                photoToLoad.imageData = imageData!
                
                do {
                    try self.stack.context.save()
                } catch {
                    print("Image data already exists")
                }
            }
            
            // Otherwise image already exists, display it in UI
        } else {
            
            DispatchQueue.main.async {
                cell.imageView.image = UIImage(data: photoToLoad.imageData as! Data)
                cell.activityIndicatorView.stopAnimating()
            }
        }
        
        return cell
    }
}

// MARK: UICollectionViewDelegate
extension PhotoAlbumView: UICollectionViewDelegate {
    
    // When user taps photo cells
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // Fade selected cells
        let cell = collectionView.cellForItem(at: indexPath as IndexPath)
        cell?.alpha = 0.5
        
        // Whenever user selects cells, update button to remove pictures
        barButton.title = "Remove Selected Images"
        
        tappedIndexPaths.append(indexPath)
    }
    
}

// MARK: NSFetchedResultsControllerDelegate
extension PhotoAlbumView: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexPaths = [IndexPath]()
        deletedIndexPaths = [IndexPath]()
        updatedIndexPaths = [IndexPath]()
    }
    
    // Only called when something is added or deleted. Collects indexPaths that changed and applies to the UI
    // indexPath is nil for insertions, and newIndexPath is nil for deletions.
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
            
        case .insert:
            insertedIndexPaths.append(newIndexPath!)
            print("Inserted new index path")
            break
            
        case .delete:
            deletedIndexPaths.append(indexPath!)
            print("Deleted index path")
            break
            
        case .update:
            updatedIndexPaths.append(indexPath!)
            print("Updated index path")
            break
            
        default:
            break
        }
    }

    // Updates UI to sync with Core Data
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        collectionView.performBatchUpdates({
            
            for indexPath in self.insertedIndexPaths{
                self.collectionView.insertItems(at: [indexPath as IndexPath])
            }
            
            for indexPath in self.deletedIndexPaths{
                self.collectionView.deleteItems(at: [indexPath as IndexPath])
            }
            
            for indexPath in self.updatedIndexPaths{
                self.collectionView.reloadItems(at: [indexPath as IndexPath])
            }
            
        }, completion: nil)
    }
}

