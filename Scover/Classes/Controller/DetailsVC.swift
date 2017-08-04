//
//  DetailsVC.swift
//  Scover
//
//  Created by Mobile App Dev on 5/9/17.
//  Copyright © 2017 Scover. All rights reserved.
//

import Alamofire
import UIKit

class DetailsVC: CommonVC, UICollectionViewDataSource, UICollectionViewDelegate {
    
    private var mPhotos:      [Photo] = []
    private var mReqPhotos:   DataRequest?
    private var mReqUpload:   DataRequest?
    private var mRequest:     DataRequest?
    private lazy var mHeader: Details = Details(block: { [weak self] (r: Route) in
        self?.navigationController?.pushViewController(RouteVC(with: r), animated: true)
    }) { [weak self] () -> Void in
        self?.mGallery.show()
    }
    
    private lazy var mTable: UICollectionView = { [weak self] () -> UICollectionView in
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.headerReferenceSize = CGSize(width: 0, height: 48.0)

        switch UIScreen.main.bounds.width {
        case 320:
            layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
            layout.minimumLineSpacing = 8
            layout.minimumInteritemSpacing = 8
            layout.itemSize = CGSize(width: 96, height: 96)
        case 375:
            layout.sectionInset = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
            layout.minimumLineSpacing = 7
            layout.minimumInteritemSpacing = 7
            layout.itemSize = CGSize(width: 85, height: 85)
        default:
            layout.sectionInset = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
            layout.minimumLineSpacing = 6
            layout.minimumInteritemSpacing = 6
            layout.itemSize = CGSize(width: 96, height: 96)
        }

        let tmp: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        tmp.dataSource = self
        tmp.delegate   = self
        tmp.alpha      = 0
        tmp.backgroundView  = UIView()
        tmp.backgroundColor = .clear
        tmp.register(PhotoCell.self, forCellWithReuseIdentifier: "cell")
        tmp.register(SectionView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "section")
        return tmp
    }()
    
    private lazy var mGallery: Gallery = Gallery(root: self) { [weak self] (img: UIImage) in
        self?.upload(image: img)
    }
    
    private let mHUD:    UIActivityIndicatorView = .whiteLarge
    private var mPlace:  Place
    
    private lazy var mFooter: Footer = Footer(scroll: self.mTable, error: { [weak self] () -> Void in
        self?.startPhotosLoad()
    })
    
    init(`for` place: Place) {
        mPlace = place
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "LOCATION_DETAILS".loc
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: Icon.back.view(size: 20.0, color: .white, padding: 3.0, target: self, action: #selector(back)))
        view.addSubview(mTable)
        view.addSubview(mHUD)
        
        mTable.addSubview(mHeader)

        mRequest = Service.place(id: mPlace.place_id, callback: { [weak self] (p: Place?) in
            self?.mHUD.stopAnimating()
            self?.mRequest = nil
            if let p = p {
                self?.show(place: p)
            } else {
                self?.navigationController?.popViewController(animated: true)
                "CANT_GET_PLACE".show(in: self?.view.window)
            }
        })
    }
    
    @objc private func startPhotosLoad() {
        if mRequest == nil {
            mFooter.state = .loading
            mRequest = Service.photos(for: mPlace.place_id, offset: UInt64(mPhotos.count), callback: { [weak self] (p: [Photo]?, count: UInt64) in
                guard let s = self else { return }
                if let p = p {
                    s.mPhotos.append(contentsOf: p)
                    s.mTable.reloadData()
                    s.mFooter.state = UInt64(s.mPhotos.count) >= count ? .hidden : .loading
                } else {
                    s.mFooter.state = .error
                }
                s.mRequest = nil
            })
        }
    }
    
    deinit {
        mRequest?.cancel()
        mRequest = nil
        mReqPhotos?.cancel()
        mReqPhotos = nil
        mReqUpload?.cancel()
        mReqUpload = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        forceLayout()
    }
    
    private func forceLayout() {
        mTable.frame  = view.bounds
        mTable.contentInset.top = mHeader.maxHeight
        mTable.contentOffset.y  = -mTable.contentInset.top
        mHeader.frame  = CGRect(x: 0, y: -mHeader.maxHeight, width: mTable.width, height: mHeader.maxHeight)
        mHUD.origin    = CGPoint(x: (view.width - mHUD.width)/2.0, y: 0)
    }
    
    private func show(place p: Place) {
        mPlace = p
        mHeader.show(place: p)
        mTable.reloadData()
        mTable.alpha = 1.0
        forceLayout()
        startPhotosLoad()
    }
    
    private func upload(image: UIImage) {
        mReqUpload?.cancel()
        mReqUpload = nil
        
        let hud: HUD? = HUD.show(in: self.view)
        mReqUpload = Service.photos(add: image, to: mPlace.place_id, callback: { [weak self] (p: Photo?) in
            hud?.hide(animated: true)
            self?.mReqUpload = nil
            if let p = p {
                self?.mPhotos.insert(p, at: 0)
                self?.mTable.reloadData()
                NotificationCenter.default.post(name: .ProfileUpdated, object: nil)
            } else {
                "CANT_UPLOAD_PHOTO".show(in: self?.view.window)
            }
        })
    }
    
    // MARK: - UICollectionViewDataSource && UICollectionViewDelegate methods
    // -------------------------------------------------------------------------
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if mFooter.state == .loading && mFooter.convert(.zero, to: self.view).y < self.view.height {
            startPhotosLoad()
        }
        mFooter.adjust()
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let section: SectionView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "section", for: indexPath) as! SectionView
        section.icon = indexPath.section == 0 ? UIImageView(image: .smallLogo()) : Icon.pic.view(size: 16.4, color: .white)
        section.name = indexPath.section == 0 ? "Scover \(mPlace.name)" : "MORE_PHOTOS".loc
        return section
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1 + (mPhotos.count > 0 ? 1 : 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return mPlace.photos.count
        }
        return mPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: PhotoCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PhotoCell
        cell.show(image: indexPath.section == 0 ? mPlace.photos[indexPath.row] : mPhotos[indexPath.row].imgUrl)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
}
