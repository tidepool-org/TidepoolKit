//
//  StatusTableViewCell.swift
//  TidepoolKit Example
//
//  Created by Darin Krauss on 2/17/20.
//  Copyright © 2020 Tidepool Project. All rights reserved.
//

import UIKit

class StatusTableViewCell: UITableViewCell {
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var environmentLabel: UILabel!
    @IBOutlet weak var authenticationTokenLabel: UILabel!
    @IBOutlet weak var userIDLabel: UILabel!

    override public func prepareForReuse() {
        super.prepareForReuse()
        
        stateLabel?.text = nil
        environmentLabel?.text = nil
        authenticationTokenLabel?.text = nil
        userIDLabel?.text = nil
    }
}
