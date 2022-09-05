//
//  String+Extension.swift
//  Note_Eval
//
//  Created by Kim TaeSoo on 2022/09/02.
//

import UIKit

extension String {
    func highlightText(_ text: String, with color: UIColor, font: UIFont = .preferredFont(forTextStyle: .body)) -> NSAttributedString {
        
        let attrString = NSMutableAttributedString(string: self)
        let range = (self as NSString).range(of: text, options: .caseInsensitive)
        attrString.addAttribute(.foregroundColor, value: color, range: range)
        attrString.addAttribute(.font, value: font, range: NSRange(location: 0, length: attrString.length))
        return attrString
    }
    func allIsWhiteSpace() -> Bool {
        var count = 0
        self.forEach { char in
            if char.isWhitespace {
                count += 1
            }
        }
        if self.count == count {
            return true
        }
        return false
    }
}
