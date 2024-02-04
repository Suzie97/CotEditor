//
//  IncompatibleCharacterTests.swift
//  Tests
//
//  CotEditor
//  https://coteditor.com
//
//  Created by 1024jp on 2016-05-29.
//
//  ---------------------------------------------------------------------------
//
//  © 2016-2024 1024jp
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import XCTest
@testable import CotEditor

final class IncompatibleCharacterTests: XCTestCase {
    
    func testIncompatibleCharacterScan() throws {
        
        let string = "abc\\ \n ¥ \n ~"
        let incompatibles = try string.charactersIncompatible(with: .plainShiftJIS)
        
        XCTAssertEqual(incompatibles.count, 2)
        
        let backslash = try XCTUnwrap(incompatibles.first)
        
        XCTAssertEqual(backslash.value.character, "\\")
        XCTAssertEqual(backslash.value.converted, "＼")
        XCTAssertEqual(backslash.location, 3)
        
        let tilde = incompatibles[1]
        
        XCTAssertEqual(tilde.value.character, "~")
        XCTAssertEqual(tilde.value.converted, "?")
        XCTAssertEqual(tilde.location, 11)
    }
    
    
    func testSequentialIncompatibleCharactersScan() throws {
        
        let string = "~~"
        let incompatibles = try string.charactersIncompatible(with: .plainShiftJIS)
        
        XCTAssertEqual(incompatibles.count, 2)
        
        let tilde = incompatibles[1]
        
        XCTAssertEqual(tilde.value.character, "~")
        XCTAssertEqual(tilde.value.converted, "?")
        XCTAssertEqual(tilde.location, 1)
    }
    
    
    func testIncompatibleCharacterScanWithLengthShift() throws {
        
        let string = "family 👨‍👨‍👦 with 🐕"
        let incompatibles = try string.charactersIncompatible(with: .japaneseEUC)
        
        XCTAssertEqual(incompatibles.count, 2)
        
        XCTAssertEqual(incompatibles[0].value.character, "👨‍👨‍👦")
        XCTAssertEqual(incompatibles[0].value.converted, "????????")
        XCTAssertEqual(incompatibles[0].location, 7)
        
        XCTAssertEqual(incompatibles[1].value.character, "🐕")
        XCTAssertEqual(incompatibles[1].value.converted, "??")
        XCTAssertEqual(incompatibles[1].location, 21)
    }
}



private extension String.Encoding {
    
    static let plainShiftJIS = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.shiftJIS.rawValue)))
}
