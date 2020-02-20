//
//  LabelTableViewCell.swift
//  TidepoolKit Example
//
//  Created by Darin Krauss on 1/22/20.
//  Copyright © 2020 Tidepool Project. All rights reserved.
//

import UIKit

class LabelTableViewCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        
        label?.text = nil
    }
}
