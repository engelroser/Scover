//
//  MosaicLayoutSmall.swift
//  Scover
//
//  Created by Kirill Kozhuhar on 27/05/2017.
//  Copyright © 2017 Scover. All rights reserved.
//

import Foundation
import SquareMosaicLayout

class MosaicLayoutSmall: SquareMosaicLayout, SquareMosaicDataSource {
    
    private class Pattern: SquareMosaicPattern {
        func patternBlocks() -> [SquareMosaicBlock] {
            return [Block()]
        }
        
        func patternBlocksSeparator(at position: SquareMosaicBlockSeparatorPosition) -> CGFloat {
            return 0.0
        }
    }
    
    private class Block: SquareMosaicBlock {
        
        public func blockFrames() -> Int {
            return 4
        }
        
        public func blockFrames(origin: CGFloat, side: CGFloat) -> [CGRect] {
            let s: CGFloat = side/4.0
            return [
                CGRect(x: 0, y: origin, width: s, height: s),
                CGRect(x: s, y: origin, width: s, height: s),
                CGRect(x: s*2.0, y: origin, width: s, height: s),
                CGRect(x: s*3.0, y: origin, width: s, height: s)
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
