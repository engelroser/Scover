//
//  MosaicLayoutBig.swift
//  Scover
//
//  Created by Kirill Kozhuhar on 27/05/2017.
//  Copyright © 2017 Scover. All rights reserved.
//

import Foundation
import SquareMosaicLayout

class MosaicLayoutBig: SquareMosaicLayout, SquareMosaicDataSource {
    
    private class Pattern: SquareMosaicPattern {
        func patternBlocks() -> [SquareMosaicBlock] {
            return [
                BlockTop(),
                BlockBot()
            ]
        }
        
        func patternBlocksSeparator(at position: SquareMosaicBlockSeparatorPosition) -> CGFloat {
            return 0.0
        }
    }
    
    private class BlockTop: SquareMosaicBlock {
        
        public func blockFrames() -> Int {
            return 5
        }
        
        public func blockFrames(origin: CGFloat, side: CGFloat) -> [CGRect] {
            let b: CGFloat = side/2.0
            let s: CGFloat = side/3.0
            return [
                CGRect(x: 0, y: origin, width: b, height: b),
                CGRect(x: b, y: origin, width: b, height: s),
                CGRect(x: b, y: origin+s, width: b, height: s),
                CGRect(x: 0, y: origin+b, width: b, height: b),
                CGRect(x: b, y: origin+s*2.0, width: b, height: s)
            ]
        }
        
    }
    
    private class BlockBot: SquareMosaicBlock {
        
        public func blockFrames() -> Int {
            return 3
        }
        
        public func blockFrames(origin: CGFloat, side: CGFloat) -> [CGRect] {
            let b: CGFloat = side/2.0
            let s: CGFloat = side/3.0
            return [
                CGRect(x: 0, y: origin, width: b, height: s),
                CGRect(x: b, y: origin, width: b, height: 2.0*s),
                CGRect(x: 0, y: origin+s, width: b, height: s)
            ]
        }
    }
    
    convenience init() {
        self.init(direction: .vertical)
        self.dataSource = self
    }
    
    func layoutPattern(for section: Int) -> SquareMosaicPattern {
        return Pattern()
    }
    
    func layoutSeparatorBetweenSections() -> CGFloat {
        return 0
    }
    
    func layoutSupplementaryBackerRequired(for section: Int) -> Bool {
        return false
    }
    
    func layoutSupplementaryFooter(for section: Int) -> SquareMosaicSupplementary? {
        return nil
    }
    
    func layoutSupplementaryHeader(for section: Int) -> SquareMosaicSupplementary? {
        return nil
    }
    
}
