//
//  AViewController.swift
//  DragNavigationController
//
//  Created by FundSmart IOS on 16/5/21.
//  Copyright © 2016年 黄海龙. All rights reserved.
//

import UIKit

class AViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismiss(animated: true, completion: nil)
    }

}
