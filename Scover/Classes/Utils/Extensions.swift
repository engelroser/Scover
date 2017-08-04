//
//  Extensions.swift
//  Scover
//
//  Created by Mobile App Dev on 4/17/17.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit
import MBProgressHUD

typealias HUD = MBProgressHUD

extension UIColor {
    
    convenience init(r: Int, g: Int, b: Int) {
        self.init(red:   max(min(CGFloat(r), 255.0), 0.0) / 255.0,
                  green: max(min(CGFloat(g), 255.0), 0.0) / 255.0,
                  blue:  max(min(CGFloat(b), 255.0), 0.0) / 255.0,
                  alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(r:(netHex >> 16) & 0xff, g:(netHex >> 8) & 0xff, b:netHex & 0xff)
    }
    
    static let gradTop:   UIColor = UIColor(netHex: 0x3f4c6b)
    static let gradBot:   UIColor = UIColor(netHex: 0x606c88)
    static let fade:      UIColor = UIColor(netHex: 0x3b3e46)
    static let hint:      UIColor = UIColor(netHex: 0x888888)
    static let dark:      UIColor = UIColor(netHex: 0x3c3f47)
    static let main:      UIColor = UIColor(netHex: 0x414f6d)
    static let mainBG:    UIColor = UIColor(netHex: 0x465876)
    static let cellFade:  UIColor = UIColor(netHex: 0x4b5b80)
    static let actions:   UIColor = UIColor(netHex: 0x333333)
    static let darkBlue:  UIColor = UIColor(netHex: 0x3d465d)
    static let lightBlue: UIColor = UIColor(netHex: 0x3d82f5)
    static let posRed:    UIColor = UIColor(netHex: 0xfc7b7b)
    static let negGray:   UIColor = UIColor(netHex: 0xd0d0d0)
    static let cardBG:    UIColor = UIColor(netHex: 0x555e73)
    static let bannerBG:  UIColor = UIColor(netHex: 0x505d7a)
    static let darkBG:    UIColor = UIColor(netHex: 0x44506f)
    static let searchBG:  UIColor = UIColor(netHex: 0x3e4453)
    static let greenArc:  UIColor = UIColor(netHex: 0x50d2c2)
    static let pinkArc:   UIColor = UIColor(netHex: 0xd667cd)
    static let bulletOn:  UIColor = UIColor(netHex: 0x0066ff)
    static let bulletOn2: UIColor = UIColor(netHex: 0x00ff0c)
    static let bulletOff: UIColor = UIColor(netHex: 0x5d5f65)
    static let lineGray:  UIColor = UIColor(netHex: 0x7f8185)
    static let mapGrad:   UIColor = UIColor(netHex: 0x5b6784)
    
}

extension Date {
    
    static let calendar: Calendar = {
        var cal: Calendar = Calendar(identifier: .gregorian)
        cal.firstWeekday  = 2 // monday
        return cal
    }()
    
    var totalWeeks: Int {
        return Date.calendar.range(of: .weekOfMonth, in: .month, for: self)?.count ?? 5
    }

    var previousMonth: Date {
        var comps: DateComponents = Date.calendar.dateComponents([.year, .month, .day, .timeZone], from: self)
        comps.day    = 1
        comps.hour   = 0
        comps.minute = 0
        comps.second = 1
        if comps.month == 1 {
            comps.month = 12
            comps.year  = comps.year == nil ? nil : (comps.year! - 1)
        } else {
            comps.month = comps.month == nil ? nil : (comps.month! - 1)
        }
        return Date.calendar.date(from: comps) ?? Date()
    }
    
    var nextMonth: Date {
        var comps: DateComponents = Date.calendar.dateComponents([.year, .month, .day, .timeZone], from: self)
        comps.day    = 1
        comps.hour   = 0
        comps.minute = 0
        comps.second = 1
        if comps.month == 12 {
            comps.month = 1
            comps.year  = comps.year == nil ? nil : (comps.year!+1)
        } else {
            comps.month = comps.month == nil ? nil : (comps.month! + 1)
        }
        return Date.calendar.date(from: comps) ?? Date()
    }
    
    var startOfMonth: Date {
        var comps: DateComponents = Date.calendar.dateComponents([.year, .month, .day, .timeZone], from: self)
        comps.day    = 1
        comps.hour   = 0
        comps.minute = 0
        comps.second = 1
        return Date.calendar.date(from: comps) ?? Date()
    }
    
    var startOfDay: Date {
        return Date.calendar.date(bySettingHour: 0, minute: 0, second: 1, of: self) ?? self
    }
    
    var month: Int {
        return Date.calendar.dateComponents([.month], from: self).month ?? 1
    }
    
    var year: Int? {
        return Date.calendar.dateComponents([.year], from: self).year
    }
    
    var weekday: Int {
        return Date.calendar.dateComponents([.weekday], from: self).weekday ?? 1
    }
    
    var isFirstDay: Bool {
        return Date.calendar.firstWeekday == self.weekday
    }
    
    var weekOfMonth: Int {
        return Date.calendar.dateComponents([.weekOfMonth], from: self).weekOfMonth ?? 1
    }
    
    var startOfWeek: Date {
        if let weekday = Date.calendar.ordinality(of: .weekday, in: .weekOfMonth, for: self) {
            return self.addingTimeInterval(TimeInterval((1-weekday) * 86400)).startOfDay
        }
        return self.startOfDay
    }
    
    var searchFormat: String {
        let df: DateFormatter = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df.string(from: self)
    }
    
    var checkinFormat: String {
        if Calendar.current.isDateInToday(self) {
            return "TODAY".loc
        }
        let df: DateFormatter = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df.string(from: self)
    }
    
    var longFormat: String {
        let df: DateFormatter = DateFormatter()
        df.dateFormat = "EEEE MMMM dd, yyyy"
        return df.string(from: self)
    }
    
    var tileFormat: String {
        let df: DateFormatter = DateFormatter()
        df.dateFormat = "dd\nEEEE"
        return df.string(from: self)
    }
    
}

enum Icon: String {
    
    case plus     = "a"
    case share    = "b"
    case calendar = "c"
    case compas   = "d"
    case bookmark = "e"
    case profile  = "f"
    case arrow    = "g"
    case heart    = "h"
    case negative = "i"
    case positive = "j"
    case back     = "k"
    case bell     = "l"
    case cross    = "m"
    case search   = "n"
    case pic      = "o"
    case location = "p"
    case check    = "q"
    case addPhoto = "r"
    case cab      = "s"
    case car      = "t"
    case train    = "u"
    case walk     = "v"
    case expand   = "w"
    case left     = "x"
    case right    = "y"
    case play     = "z"
    case settings = "A"
    case edit     = "B"
    case up       = "C"
    case single   = "D"
    case multiple = "E"
    case time     = "F"

    func view(size: CGFloat, color: UIColor, padding: CGFloat = 0, square: Bool = false, target: Any? = nil, action: Selector? = nil) -> UILabel {
        let tmp: UILabel = .label(font: UIFont.icon(size), text: self.rawValue, lines: 1, color: color, alignment: .center)
        tmp.frame.size.width += padding * 2.0
        
        if square {
            tmp.frame.size = CGSize(width: max(tmp.width, tmp.height), height: max(tmp.width, tmp.height))
        }
        
        if let t = target, let a = action {
            tmp.isUserInteractionEnabled = true
            tmp.addGestureRecognizer(UITapGestureRecognizer(target: t, action: a))
        }
        return tmp
    }
    
}

extension UILabel {
    
    static func label(font: UIFont? = nil, text: String = "", lines: Int = 0, color: UIColor = .black, alignment: NSTextAlignment = .center, target: Any? = nil, action: Selector? = nil) -> UILabel {
        let tmp: UILabel = UILabel(frame: CGRect.zero)
        tmp.font = font
        tmp.text = text
        tmp.textColor = color
        tmp.numberOfLines   = lines
        tmp.textAlignment   = alignment
        tmp.backgroundColor = .clear
        tmp.sizeToFit()
        tmp.frame.size = CGSize(width: ceil(tmp.width), height: ceil(tmp.height))
        tmp.isUserInteractionEnabled = true
        if let t = target, let a = action {
            tmp.addGestureRecognizer(UITapGestureRecognizer(target: t, action: a))
        }
        return tmp
    }
    
}

extension String {

    var abs: String {
        if self.hasPrefix("http") {
            return self
        }
        return Settings.URL.base+self
    }
    
    var loc: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func show(`in` view: UIView?, hide: TimeInterval = 2.0) {
        DispatchQueue.main.async {
            MBProgressHUD.text(self, in: view, hide: hide)
        }
    }
    
    func heightFor(width: CGFloat, font: UIFont) -> CGFloat {
        return ceil(self.boundingRect(with:       CGSize(width: width, height: .greatestFiniteMagnitude),
                                      options:    .usesLineFragmentOrigin,
                                      attributes: [NSFontAttributeName: font],
                                      context:    nil).height)
    }
    
    static func from(data: Data?) -> String? {
        if let d = data {
            return String(data: d, encoding: String.Encoding.utf8)
        }
        return nil
    }
    
}

extension CGRect {
    
    func center() -> CGPoint {
        return CGPoint(x: self.origin.x + self.size.width/2.0, y: self.origin.y + self.size.height/2.0)
    }
    
}

extension UIImage {
    
    static func smallLogo() -> UIImage {
        return UIImage(named: "smallLogo") ?? UIImage()
    }
    
    static func main() -> UIImage {
        return UIImage(named: "main") ?? UIImage()
    }
    
    static func tabBG() -> UIImage {
        return UIImage(named: "tabBG") ?? UIImage()
    }
    
    static func gps() -> UIImage {
        return UIImage(named: "gps") ?? UIImage()
    }
    
    static func location() -> UIImage {
        return UIImage(named: "location") ?? UIImage()
    }
    
    static func face() -> UIImage {
        return UIImage(named: "face") ?? UIImage()
    }
    
    static func ok() -> UIImage {
        return UIImage(named: "ok") ?? UIImage()
    }
    
    static func lockRed() -> UIImage {
        return UIImage(named: "lockRed") ?? UIImage()
    }
    
    static func enter() -> UIImage {
        return UIImage(named: "enter") ?? UIImage()
    }
    
    static func go() -> UIImage {
        return UIImage(named: "go") ?? UIImage()
    }
    
    static func user() -> UIImage {
        return UIImage(named: "user") ?? UIImage()
    }
    
    static func fIcon() -> UIImage {
        return UIImage(named: "fIcon") ?? UIImage()
    }
    
    static func gIcon() -> UIImage {
        return UIImage(named: "gIcon") ?? UIImage()
    }
    
    static func sep() -> UIImage {
        return UIImage(named: "sep") ?? UIImage()
    }
    
    static func mail() -> UIImage {
        return UIImage(named: "mail") ?? UIImage()
    }
    
    static func pass() -> UIImage {
        return UIImage(named: "pass") ?? UIImage()
    }
    
    static func tabIcon3() -> UIImage {
        return UIImage(named: "tabIcon3") ?? UIImage()
    }
    
    static func todayBG() -> UIImage {
        return UIImage(named: "todayBG") ?? UIImage()
    }
    
    static func recommendedBG() -> UIImage {
        return UIImage(named: "recommendedBG") ?? UIImage()
    }
    
    static func upcomming() -> UIImage {
        return UIImage(named: "upcomming") ?? UIImage()
    }
    
    static func actionBG() -> UIImage {
        return UIImage(named: "actionBG") ?? UIImage()
    }
    
    func resize(size: CGSize) -> UIImage? {
        let s: CGFloat = min(size.width  / self.size.width, size.height / self.size.height)
        let d: CGSize  = CGSize(width: self.size.width * s, height: self.size.height * s)
        UIGraphicsBeginImageContextWithOptions(d, false, UIScreen.main.scale)
        self.draw(in: CGRect(origin: .zero, size: d))
        let img: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
    
}

extension UIActivityIndicatorView {
    
    @nonobjc static var white: UIActivityIndicatorView {
        return def(.white)
    }
    
    @nonobjc static var gray: UIActivityIndicatorView {
        return def(.gray)
    }
    
    @nonobjc static var whiteLarge: UIActivityIndicatorView {
        return def(.whiteLarge)
    }
    
    static func def(_ style: UIActivityIndicatorViewStyle) -> UIActivityIndicatorView {
        let tmp: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: style)
        tmp.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50.0)
        tmp.hidesWhenStopped = true
        tmp.startAnimating()
        return tmp
    }
    
}

extension Integer {
    
    func plura(zero: String, one: String, many: String) -> String {
        return self==0 ? zero : ("\(self) "+(self == 1 ? one : many))
    }
    
}

extension Int {
    func likes() -> NSAttributedString {
        let likes: NSMutableAttributedString = NSMutableAttributedString(string: Icon.heart.rawValue,
                                                                         attributes: [NSFontAttributeName: UIFont.icon(16.3),
                                                                                      NSForegroundColorAttributeName: UIColor.posRed])
        likes.append(NSAttributedString(string: "   \(self.short)", attributes: [NSFontAttributeName: UIFont.regular( 10.5),
                                                                                 NSForegroundColorAttributeName: UIColor.white,
                                                                                 NSBaselineOffsetAttributeName: 4]))
        return likes
    }
    
    func dislikes() -> NSAttributedString {
        let dis: NSMutableAttributedString = NSMutableAttributedString(string: Icon.negative.rawValue,
                                                                       attributes: [NSFontAttributeName: UIFont.icon(16.3),
                                                                                    NSForegroundColorAttributeName: UIColor.negGray])
        dis.append(NSAttributedString(string: "   \(self.short)", attributes: [NSFontAttributeName: UIFont.regular(10.5),
                                                                               NSForegroundColorAttributeName: UIColor.white,
                                                                               NSBaselineOffsetAttributeName: 4]))
        return dis
    }
    
    var short: String {
        var result: String? = nil
        [1000000, 100000, 1000].forEach { (v: Int) in
            if result == nil, let val = self.parts(of: v) {
                result = val
            }
        }
        return result ?? "\(self)"
    }
    
    private func parts(of: Int) -> String? {
        if of >= 1000, self >= of {
            let prt: Double = Double(self % of) / Double(of)
            let str: String = prt >= 0.1 ? String(format: ".%d", Int(floor(prt * 10.0))) : ""
            return String(format: "%d", self/of) + str + "k"
        }
        return nil
    }
}

extension MBProgressHUD {
    
    static func text(_ text: String, `in` view: UIView?, hide: TimeInterval = 2.0) {
        if let v = view {
            let tmp: MBProgressHUD = MBProgressHUD.showAdded(to: v, animated: true)
            tmp.mode = .text
            tmp.label.text = text
            tmp.label.numberOfLines = 0
            tmp.isUserInteractionEnabled = false
            tmp.hide(animated: true, afterDelay: hide)
        }
    }
    
    static func show(`in` view: UIView?) -> MBProgressHUD? {
        if let v = view {
            return MBProgressHUD.showAdded(to: v, animated: true)
        }
        return nil
    }
    
}

extension UINavigationController {
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}

extension UIFont {
    
    static func icon(_ size: CGFloat) -> UIFont {
        return UIFont(name: "scover", size: size) ?? UIFont.systemFont(ofSize:size)
    }
    
    static func regular(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Roboto-Regular", size: size) ?? UIFont.systemFont(ofSize:size)
    }
    
    static func light(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Roboto-Light", size: size) ?? UIFont.systemFont(ofSize:size)
    }
    
    static func josefinSansBold(_ size: CGFloat) -> UIFont {
        return UIFont(name: "JosefinSans-Bold", size: size) ?? UIFont.boldSystemFont(ofSize:size)
    }
    
    static func josefinSansRegular(_ size: CGFloat) -> UIFont {
        return UIFont(name: "JosefinSans", size: size) ?? UIFont.systemFont(ofSize:size)
    }

}

extension CGPoint {
    
    func offset(x: CGFloat = 0.0, y: CGFloat = 0.0) -> CGPoint {
        return CGPoint(x: self.x + x, y: self.y + y)
    }
    
}

extension UIView {
    
    @nonobjc var origin: CGPoint {
        get {
            return self.frame.origin
        }
        set {
            self.frame.origin = newValue
        }
    }
    
    @nonobjc var width: CGFloat {
        get {
            return self.frame.width
        }
        set {
            self.frame.size.width = newValue
        }
    }
    
    @nonobjc var height: CGFloat {
        get {
            return self.frame.height
        }
        set {
            self.frame.size.height = newValue
        }
    }
    
    @nonobjc var maxX: CGFloat {
        get {
            return self.frame.maxX
        }
    }
    
    @nonobjc var minX: CGFloat {
        get {
            return self.frame.minX
        }
    }
    
    @nonobjc var maxY: CGFloat {
        get {
            return self.frame.maxY
        }
    }
    
    @nonobjc var minY: CGFloat {
        get {
            return self.frame.minY
        }
    }
    
    static func line(with color: UIColor) -> UIView {
        let tmp: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 1.0/UIScreen.main.scale))
        tmp.backgroundColor = color
        return tmp
    }
    
}

extension Notification.Name {
    
    static let BookmarkNeedUpdatePlace:   Notification.Name = Notification.Name(rawValue: "BookmarkNeedUpdatePlace")
    static let BookmarkNeedUpdateHoliday: Notification.Name = Notification.Name(rawValue: "BookmarkNeedUpdateHoliday")
    static let ProfileUpdated:            Notification.Name = Notification.Name(rawValue: "ProfileUpdated")
    static let PushEnabled:               Notification.Name = Notification.Name(rawValue: "PushEnabled")
    static let PushDisabled:              Notification.Name = Notification.Name(rawValue: "PushDisabled")
    static let PushEnableError:           Notification.Name = Notification.Name(rawValue: "PushEnableError")
    
}
