//
//  ProfileVC.swift
//  Scover
//
//  Created by Kirill Kozhuhar on 4/25/17.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit
import Alamofire
import SquareMosaicLayout

class ProfileVC: CommonVC, UICollectionViewDataSource, UICollectionViewDelegate, ProfileHeaderDelegate {
    
    private var mRequest: DataRequest?
    
    enum Cell: String {
        case photoSmall = "photoSmall"
        case photoBig   = "photoBig"
        case checkIn    = "checkIn"
    }
    
    private lazy var mHeader: ProfileHeader = ProfileHeader(delegate: self)
    
    private var mHUD: UIActivityIndicatorView = .whiteLarge
    
    private var mCell: Cell = .photoSmall
    
    private var mPhotos: [Profile.Photo]   = []
    private var mChecks: [Profile.Checkin] = []
    
    private lazy var mError: UILabel = UILabel.label(font: UIFont.regular(14.0), text: "CANT_GET_PROFILE".loc, lines: 0, color: .white, alignment: .center, target: self, action: #selector(refreshed))

    private lazy var mTable: UICollectionView = { [weak self] () -> UICollectionView in
        let collection = UICollectionView(frame: UIScreen.main.bounds, collectionViewLayout: MosaicLayoutSmall())
        collection.register(CellPhotoSmall.self, forCellWithReuseIdentifier: Cell.photoSmall.rawValue)
        collection.register(CellPhotoBig.self, forCellWithReuseIdentifier: Cell.photoBig.rawValue)
        collection.register(CellCheckIn.self, forCellWithReuseIdentifier: Cell.checkIn.rawValue)
        collection.dataSource = self
        collection.delegate   = self
        collection.backgroundView  = UIView()
        collection.backgroundColor = .clear
        return collection;
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshed), name: .ProfileUpdated, object: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: Icon.settings.view(size: 20, color: .white, target: self, action: #selector(settings)))
        navigationItem.leftBarButtonItem  = UIBarButtonItem(customView: Icon.plus.view(size: 20, color: .white, target: self, action: #selector(invite)))
        navigationItem.title = "JLenoff"
        view.addSubview(mTable)
        view.addSubview(mHUD)
        mTable.addSubview(mHeader);
        show(photos: .multiple)
        refreshed()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mTable.frame  = view.bounds
        mError.origin = CGPoint(x: floor((view.width - mError.width)/2.0), y: 20.0)
        mHUD.origin   = CGPoint(x: floor((view.width - mHUD.width)/2.0), y: 20.0)
        scrollViewDidScroll(mTable)
    }
    
    @objc private func invite() {
        present(UINavigationController(rootViewController: InviteVC()), animated: true)
    }
    
    @objc private func settings() {
        present(UINavigationController(rootViewController: SettingsVC()), animated: true)
    }
    
    @objc private func refreshed() {
        mError.isHidden = true
        mTable.isHidden = true
        mHUD.startAnimating()
        mRequest?.cancel()
        mRequest = Service.profile(get: { [weak self] (p: Profile?, c: Int) in
            self?.mRequest = nil
            if c == 200, let p = p {
                Settings.profile = p
                self?.mHeader.profile = p
                self?.requestPhotos()
            } else {
                self?.showError()
            }
        })
    }
    
    private func requestPhotos() {
        if mRequest == nil {
            mRequest = Service.profile(photos: { [weak self] (p: [Profile.Photo?]?, c: Int) in
                self?.mRequest = nil
                if let p = p, c == 200 {
                    self?.mPhotos = p.flatMap({ $0 })
                    self?.requestChecks()
                } else {
                    self?.showError()
                }
            })
        }
    }
    
    private func requestChecks() {
        if mRequest == nil {
            mRequest = Service.profile(checkins: { [weak self] (p: [Profile.Checkin?]?, c: Int) in
                self?.mRequest = nil
                if let p = p, c == 200 {
                    self?.mChecks = p.flatMap({ $0 })
                    self?.mHUD.stopAnimating()
                    self?.mTable.reloadData()
                    self?.mTable.isHidden = false
                } else {
                    self?.showError()
                }
            })
        }
    }
    
    private func showError() {
        mHUD.stopAnimating()
        mError.isHidden = false
    }
    
    // MARK: - UICollectionViewDataSource methods
    // -------------------------------------------------------------------------
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if mCell == .photoBig || mCell == .photoSmall {
            return mPhotos.count
        }
        return mChecks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch mCell {
        case .checkIn:
            let cell: CellCheckIn = collectionView.dequeueReusableCell(withReuseIdentifier: mCell.rawValue, for: indexPath) as! CellCheckIn
            cell.checkin = mChecks[indexPath.row]
            return cell
        case .photoBig:
            let cell: CellPhotoBig = collectionView.dequeueReusableCell(withReuseIdentifier: mCell.rawValue, for: indexPath) as! CellPhotoBig
            cell.photo = mPhotos[indexPath.row]
            return cell
        case .photoSmall:
            let cell: CellPhotoSmall = collectionView.dequeueReusableCell(withReuseIdentifier: mCell.rawValue, for: indexPath) as! CellPhotoSmall
            cell.photo = mPhotos[indexPath.row]
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {}
    
    func scrollViewDidScroll(_ s: UIScrollView) {
        let h: CGFloat = mHeader.height(for: s.width)
        let g: CGFloat = mHeader.barHeight
        let y: CGFloat = s.contentOffset.y > -g ? (s.contentOffset.y - h + g) : min(s.contentOffset.y, -h)
        mHeader.frame  = CGRect(x: 0, y: y, width: s.width, height: h)
        mHeader.fade   = s.contentOffset.y > -g*2.0 ? max(min((s.contentOffset.y + g*2.0)/(g), 1.0), 0) : 0.0
        s.contentInset.top = h
        
        if let last = s.subviews.last, last != mHeader, !(last is UICollectionViewCell) {
            s.insertSubview(mHeader, belowSubview: last)
        } else {
            s.bringSubview(toFront: mHeader)
        }
    }
    
    // MARK: - ProfileHeaderDelegate methods
    // -------------------------------------------------------------------------
    func show(photos: PhotosBar.State) {
        mTable.collectionViewLayout.invalidateLayout()
        mTable.setCollectionViewLayout(photos == .single ? MosaicLayoutBig() : MosaicLayoutSmall(), animated: false)
        mCell = (photos == .single ? .photoBig : .photoSmall)
        mTable.reloadData()
    }
    
    func showCheckins() {
        mTable.collectionViewLayout.invalidateLayout()
        mTable.setCollectionViewLayout(SingleLineLayout(), animated: false)
        mCell = .checkIn
        mTable.reloadData()
    }
}
