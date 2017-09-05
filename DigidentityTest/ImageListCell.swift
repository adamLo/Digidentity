//
//  ImageListCell.swift
//  DigidentityTest
//
//  Created by Adam Lovastyik [Standard] on 05/09/2017.
//  Copyright © 2017 Adam Lovastyik. All rights reserved.
//

import UIKit

class ImageListCell: UITableViewCell {
    
    static let cellReuseId = "imageListCell"
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var idTitleLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    
    @IBOutlet weak var confidenceTitleLabel: UILabel!
    @IBOutlet weak var confidenceLabel: UILabel!
    
    @IBOutlet weak var textContentLabel: UILabel!

    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        idTitleLabel.text = NSLocalizedString("ID:", comment: "ID title in list cell")
        confidenceTitleLabel.text = NSLocalizedString("Confidence:", comment: "Confidence title in list cell")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup(with photo: Photo) {
        
        idLabel.text = photo.id ?? NSLocalizedString("N/A", comment: "Not Available placeholder")
        confidenceLabel.text = String(format: "%0.5f", photo.confidence)
        textContentLabel.text = photo.text
        
        photoImageView.image = nil
        if let imgString = photo.img {
        
            if let data = Data(base64Encoded: imgString) {
                
                if let image = UIImage(data: data) {
                    
                    photoImageView.image = image
                }
            }
        }
        
    }

}
