//
//  SelectDayVC.swift
//  Scover
//
//  Created by Mobile App Dev on 5/11/17.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

class SelectDayVC: CommonVC {
    
    private let mHolidays: [[Holiday]]
    private var mDays:     [UIView] = []
    private var mBlock:    ((Int)->Void)?
    
    init(from holidays: [[Holiday]], callback: ((Int)->Void)? = nil) {
        mHolidays = holidays
        super.init(nibName: nil, bundle: nil)
        mBlock = callback
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "CHOSE_DAY".loc
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: Icon.cross.view(size: 20.0, color: .white, padding: 0, target: self, action: #selector(close)))
        
        mHolidays.enumerated().forEach { (offset: Int, h: [Holiday]) in
            if h.count > 0 {
                let tmp: DayTile = DayTile(count: h.count, image: h.first?.backgroundUrl?.abs ?? "", date: h.first?.dateObj(), block: { [weak self] () -> Void in
                    self?.mBlock?(offset)
                    self?.presentingViewController?.dismiss(animated: true)
                })
                mDays.append(tmp)
                view.addSubview(tmp)
            }
        }
        
        mHolidays.forEach { (h: [Holiday]) in

        }
        
        if mHolidays.count % 2 == 1 {
            let tmp: DayEmpty = DayEmpty()
            mDays.append(tmp)
            view.addSubview(tmp)
        }
    }
    
//    @objc private func close() {
//        presentingViewController?.dismiss(animated: true)
//    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let w: CGFloat = self.view.width/2.0
        let h: CGFloat = self.view.height/4.0
        var y: CGFloat = 0.0
        
        mDays.enumerated().forEach { (offset: Int, element: UIView) in
            element.frame = CGRect(x: w * CGFloat(offset%2), y: y, width: w, height: h)
            y += (offset == 0 || offset%2 == 0) ? 0 : h
        }
    }
    
}
