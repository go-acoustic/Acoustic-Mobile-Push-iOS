/*
 * Copyright © 2015, 2019 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */


import UIKit

class EditCell : UITableViewCell
{
    @IBOutlet weak var textField: UILabel?
    @IBOutlet weak var editField: KeyedTextField?
    @IBOutlet weak var selectField: UISegmentedControl?
}

class KeyedTextField: UITextField
{
    var key: String?
    var indexPath: IndexPath?
}
