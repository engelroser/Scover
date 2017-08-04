//
//  PhotoCell.swift
//  Scover
//
//  Created by Kirill Kozhuhar on 5/9/17.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    private let mImage: UIImageView = {
        let tmp: UIImageView = UIImageView()
        tmp.backgroundColor = .gray
        tmp.contentMode = .scaleAspectFill
        tmp.layer.cornerRadius  = 2.0
        tmp.layer.masksToBounds = true
        return tmp
    }()
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        self.backgroundView  = UIView()
        
        addSubview(mImage)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mImage.frame = self.bounds
    }
    
    func show(image: String?) {
        mImage.sd_setImage(with: URL(string: image?.abs ?? ""))
    }
    
}
