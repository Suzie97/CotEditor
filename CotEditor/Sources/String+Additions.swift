/*
 
 String+Additions.swift
 
 CotEditor
 https://coteditor.com
 
 Created by 1024jp on 2016-05-27.
 
 ------------------------------------------------------------------------------
 
 © 2016 1024jp
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 
 */

extension String {
    
    /// line range adding ability to exclude last line ending character if exists
    func lineRange(for range: Range<Index>, excludingLastLineEnding: Bool) -> Range<Index> {
        
        var lineRange = self.lineRange(for: range)
        
        guard excludingLastLineEnding else { return lineRange }
        
        if self.characters[self.index(before: lineRange.upperBound)] == "\n" {
            lineRange = lineRange.lowerBound..<self.index(before: lineRange.upperBound)
        }
        
        return lineRange
    }
    
    
    /// check if character at the location in UTF16 is escaped with backslash
    func isCharacterEscaped(at location: Int) -> Bool {
        
        let MaxEscapesCheckLength = 16
        let escapesCheckLength = min(location, MaxEscapesCheckLength)
        
        var locationIndex = self.utf16.index(self.utf16.startIndex, offsetBy: location).samePosition(in: self)!
        
        var numberOfEscapes = 0
        for _ in 0..<escapesCheckLength {
            locationIndex = self.index(before: locationIndex)
            
            guard self[locationIndex] == "\\" else { break }
            
            numberOfEscapes += 1
        }
        
        return (numberOfEscapes % 2 == 1)
    }
    
}
