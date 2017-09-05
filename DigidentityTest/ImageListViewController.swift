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
    
    @IBOutlet weak var loadingFooterHeight: NSLayoutConstraint!
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingLabel: UILabel!
    
    private var lastId: String? = nil
    private var hasMoreData = true
    
    private var isFetchingPhotos = false
    
    private let rowHeightRatio: CGFloat = 0.25
    
    private let sectionHeaderHeight: CGFloat = 20.0
    private let sectionFooterHeight: CGFloat = 30.0
    private let animationDuration: TimeInterval = 0.25
    
    private var lastError: Error? = nil
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        title = NSLocalizedString("Photos", comment: "Photos scene navigation title")
        
        setupTableView()
        
        setupFooter()

        setupFetchedResultsController()
        
        loadPhotos()
        
        fetchPhotos()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK - UI Customization
    
    private func setupTableView() {
        
        photosTableView.tableFooterView = UIView()
        
        addPullToresfresh()
    }
    
    private func addPullToresfresh() {
        
        if #available(iOS 6.0, *) {
            
            let refreshControl = UIRefreshControl()
            refreshControl.attributedTitle = NSAttributedString(string: NSLocalizedString("Fetching photos...", comment: "Photos tableview refresh control title"), attributes: [NSForegroundColorAttributeName: UIColor.darkGray, NSFontAttributeName: UIFont.systemFont(ofSize: 15.0)])
            refreshControl.tintColor = UIColor.darkGray
            
            refreshControl.addTarget(self, action: #selector(self.refreshControlValueChanged(sender:)), for: .valueChanged)
            
            photosTableView.refreshControl = refreshControl
        }
    }
    
    private func setupFooter() {
        
        loadingLabel.text = NSLocalizedString("Fetching photos...", comment: "Fetching footer label title")
        loadingLabel.textColor = UIColor.darkGray
        
        loadingActivityIndicator.tintColor = UIColor.darkGray
    }
    
    // MARK: - Actions
    
    func refreshControlValueChanged(sender: UIRefreshControl) {
        
        if !isFetchingPhotos {
        
            lastId = nil
            hasMoreData = true
            
            fetchPhotos()
        }
        else {
            
            sender.endRefreshing()
        }
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return lastError == nil ? 0.0 : sectionHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return lastError == nil ? nil : errorHeaderView
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
        
        if !isFetchingPhotos || self.hasMoreData {
            
            isFetchingPhotos = true
            
            toggleLoadingActivityIndicator(animating: true)
            
            networManager.fetchItems(sinceId: nil, maxId: lastId, completion: { (count, fetchedFirstId, fetchedLastId, error) in
                
                self.isFetchingPhotos = false

                if error == nil {
                
                    if fetchedLastId != nil {
                        
                        self.lastId = fetchedLastId
                    }
                    
                    self.hasMoreData = count > 0
                }
                
                DispatchQueue.main.async {
                    
                    if #available(iOS 6.0, *) {
                        
                        if let refreshControl = self.photosTableView.refreshControl {
                            
                            if refreshControl.isRefreshing {
                                
                                refreshControl.endRefreshing()
                            }
                        }
                    }
                    
                    self.lastError = error
                    
                    if self.lastError != nil {
                        
                        self.photosTableView.reloadData()
                    }
                    
                    self.toggleLoadingActivityIndicator(animating: false)
                }
            })
        }
    }
    
    // MARK: - Loading and error
    
    private lazy var errorHeaderView: UIView = {
       
        let holder = UIView(frame: CGRect(x: 0, y: 0, width: self.photosTableView.frame.size.width, height: self.sectionHeaderHeight))
       
        holder.autoresizingMask = .flexibleWidth
        
        holder.backgroundColor = UIColor.white
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: holder.frame.size.width, height: holder.frame.size.height))
        label.text = NSLocalizedString("There was an error fetching photos", comment: "Error label title")
        label.textColor = UIColor.red
        label.textAlignment = .center
        
        holder.addSubview(label)
        
        return holder
    }()

    private func toggleLoadingActivityIndicator(animating: Bool) {
        
        if animating && !loadingActivityIndicator.isAnimating {
            
            loadingActivityIndicator.startAnimating()
        }
        else if !animating && loadingActivityIndicator.isAnimating {
            
            loadingActivityIndicator.stopAnimating()
        }
        
        if loadingFooterHeight.constant == 0.0 && animating {
            
            loadingFooterHeight.constant = sectionFooterHeight
            
            UIView.animate(withDuration: animationDuration, animations: {
                
                self.view.layoutIfNeeded()
            })
        }
        else if loadingFooterHeight.constant == sectionFooterHeight && !animating {
            
            loadingFooterHeight.constant = 0.0
            
            UIView.animate(withDuration: animationDuration, animations: {
                
                self.view.layoutIfNeeded()
            })
        }
    }
}
