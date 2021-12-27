//
//  CustomSportTableViewCell.swift
//  Sports_Players
//
//  Created by Mac on 23/05/1443 AH.
//

import UIKit

class CustomSportTableViewCell: UITableViewCell {

    
    @IBOutlet weak var sportName: UILabel!
    
    @IBOutlet weak var sportImageView: UIImageView!
    
    var delegate : SportDelegate?

    var indexPath :IndexPath?
    
    @IBOutlet weak var imageButton: UIButton!
    @IBAction func addImageButton(_ sender: UIButton) {
        
        delegate?.saveImage(by: self, with: "", at: indexPath)
    }
}
