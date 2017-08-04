//
//  PhotoCellSmall.swift
//  Scover
//
//  Created by Kirill Kozhuhar on 27/05/2017.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

class CellPhotoSmall: UICollectionViewCell {
    
    private let mImage: UIImageView = {
        let tmp: UIImageView = UIImageView(image: UIImage(named: "test2"))
        tmp.backgroundColor = .lightGray
        tmp.layer.cornerRadius  = 4.0
        tmp.layer.masksToBounds = true
        tmp.contentMode = .scaleAspectFill
        return tmp
    }()
    
    private var mPhoto: Profile.Photo?
    var photo: Profile.Photo? {
        get {
            return mPhoto
        }
        set {
            mPhoto = newValue
            mImage.sd_setImage(with: URL(string: mPhoto?.imgUrl?.abs ?? ""))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(mImage)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mImage.frame = self.bounds.insetBy(dx: 2.0, dy: 2.0)
    }
    
}
