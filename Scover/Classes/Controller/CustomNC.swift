//
//  CustomNC.swift
//  Scover
//
//  Created by Kirill Kozhuhar on 5/11/17.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

class CustomNC: UINavigationController {
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        self.automaticallyAdjustsScrollViewInsets = false
        self.edgesForExtendedLayout = []
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.automaticallyAdjustsScrollViewInsets = false
        self.edgesForExtendedLayout = []
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
}
