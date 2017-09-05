//
//  Photo+Data.swift
//  DigidentityTest
//
//  Created by Adam Lovastyik [Standard] on 05/09/2017.
//  Copyright © 2017 Adam Lovastyik. All rights reserved.
//

import Foundation
import CoreData

extension Photo {
    
    static let entityName = "Photo"
    
    private static let idKey      = "id"
    
    struct JSONkeys {
        
        static let id           = "_id"
        static let confidence   = "confidence"
        static let img          = "img"
        static let text         = "text"
    }
    
    class func newPhoto(in context: NSManagedObjectContext) -> Photo {
        
        let photoDescription = NSEntityDescription.entity(forEntityName: entityName, in: context)!
        
        let photo = Photo(entity: photoDescription, insertInto: context)
        
        return photo
    }
    
    class func find(by idValue: String, in context: NSManagedObjectContext) -> Photo? {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "\(idKey) = %@", idValue)
        fetchRequest.fetchLimit = 1
        
        do {
            
            if let results = try context.fetch(fetchRequest) as? [Photo] {
                
                return results.first
            }
        }
        catch {
            print("Error fetching photos")
        }
        
        return nil
    }
    
    private func update(with json: [String: Any]) {
        
        if let idValue = json[JSONkeys.id] as? String {
        
            id = idValue
        }
        else {
            
            id = nil
        }
        
        if let confidenceValue = json[JSONkeys.confidence] as? Double {
            
            confidence = confidenceValue
        }
        else {
            
            confidence = 0.0
        }
        
        if let imgValue = json[JSONkeys.img] as? String {
            
            img = imgValue
        }
        else {
            
            img = nil
        }
        
        if let textValue = json[JSONkeys.text] as? String {
            
            text = textValue
        }
        else {
            
            text = nil
        }
    }
    
    class func process(items: [[String: Any]], context: NSManagedObjectContext, completion: PaginatedFetchCompletionBlockType?) {
        
        context.perform {
            
            var count = 0
            
            for item in items {
                
                if let id = item[JSONkeys.id] as? String {

                    var photo = Photo.find(by: id, in: context)
                    
                    if photo == nil {
                        
                        photo = Photo.newPhoto(in: context)
                    }
                    
                    if photo != nil {
                    
                        photo!.update(with: item)
                    
                        count += 1
                    }
                }
            }
            
            do {
                
                try context.save()
                
                completion?(count, nil)
            }
            catch let cdError {
                
                completion?(0, cdError)
            }
        }
    }
}
