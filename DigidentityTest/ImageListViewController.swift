//
//  ImageListViewController.swift
//  DigidentityTest
//
//  Created by Adam Lovastyik [Standard] on 05/09/2017.
//  Copyright © 2017 Adam Lovastyik. All rights reserved.
//

import UIKit
import CoreData

class ImageListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var photosTableView: UITableView!
    
    private var lastId: String? = nil
    private var hasMoreData = true
    private var isFetchingPhotos = false
    
    private let rowHeightRatio: CGFloat = 0.25
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        title = NSLocalizedString("Photos", comment: "Photos scene navigation title")

        setupFetchedResultsController()
        
        loadPhotos()
        
        fetchPhotos()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if photosFetchedResultsController != nil && photosFetchedResultsController!.fetchedObjects != nil {
            
            return photosFetchedResultsController!.fetchedObjects!.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ImageListCell.cellReuseId, for: indexPath) as! ImageListCell
        
        let photo = photosFetchedResultsController!.fetchedObjects![indexPath.row] as! Photo
        
        cell.setup(with: photo)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return tableView.bounds.size.width * rowHeightRatio
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return tableView.bounds.size.width * rowHeightRatio
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        var shouldFetch = lastId == nil
        
        if !shouldFetch {
        
            if photosFetchedResultsController != nil, let photos = photosFetchedResultsController?.fetchedObjects as? [Photo] {
                
                if photos.count == indexPath.row + 1 {
                    
                    shouldFetch = true
                }
                else {
                    
                    let photo = photos[indexPath.row]
                    
                    if photo.id != nil && photo.id == lastId {
                        
                        shouldFetch = true
                    }
                }
            }
            else {
                
                shouldFetch = true
            }
        }
        
        if shouldFetch {
            
            fetchPhotos()
        }
    }
    
    // MARK: - FetchedResultsController
    
    private var photosFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    private func setupFetchedResultsController() {
        
        if photosFetchedResultsController != nil {
            
            photosFetchedResultsController!.delegate = nil
            photosFetchedResultsController = nil
        }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Photo.entityName)
        let sort = [
            NSSortDescriptor(key: Photo.idKey, ascending: false),
        ]
        request.sortDescriptors = sort
        
        photosFetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: CoreDataManager.sharedInstance.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        photosFetchedResultsController!.delegate = self
    }
    
    private func loadPhotos() {
        
        if photosFetchedResultsController != nil {
            
            do {
                
                try photosFetchedResultsController!.performFetch()
            }
            catch let error {
                print("Error loading photos: \(error)")
            }
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        photosTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
            
        case .insert: photosTableView.insertRows(at: [IndexPath(row: newIndexPath!.row, section: 0)], with: .automatic)
        case .delete: photosTableView.deleteRows(at: [IndexPath(row: indexPath!.row, section: 0)], with: .automatic)
        case .update: photosTableView.reloadRows(at: [IndexPath(row: indexPath!.row, section: 0)], with: .automatic)
        default: break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        photosTableView.endUpdates()
    }
    
    // MARK: - Backend integration
    
    private lazy var networManager: NetworkManager = {
       
        let manager = NetworkManager()
        
        return manager
    }()
    
    private func fetchPhotos() {
        
        if !isFetchingPhotos && self.hasMoreData {
            
            isFetchingPhotos = true
            
            networManager.fetchItems(sinceId: nil, maxId: lastId, completion: { (count, fetchedFirstId, fetchedLastId, error) in
                
                self.isFetchingPhotos = false

                if error == nil {
                
                    if fetchedLastId != nil {
                        
                        self.lastId = fetchedLastId
                    }
                    
                    self.hasMoreData = count > 0
                }
                else {
                    
                    // TODO: Implement error display
                }
                
                // TODO: Implement UI update
            })
        }
    }

}
