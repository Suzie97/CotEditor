//
//  OutlineViewController.swift
//
//  CotEditor
//  https://coteditor.com
//
//  Created by 1024jp on 2018-02-27.
//
//  ---------------------------------------------------------------------------
//
//  © 2018 1024jp
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

import Cocoa

/// outilneView column identifiers
private extension NSUserInterfaceItemIdentifier {
    
    static let title = NSUserInterfaceItemIdentifier("title")
}



final class OutlineViewController: NSViewController {
    
    // MARK: Private Properties
    
    private var documentObserver: NSObjectProtocol?
    private var syntaxStyleObserver: NSObjectProtocol?
    private var selectionObserver: NSObjectProtocol?
    private var isOwnSelectionChange = false
    
    @IBOutlet private weak var outlineView: NSOutlineView?
    
    
    
    // MARK: -
    // MARK: View Controller Methods
    
    override var representedObject: Any? {
        
        didSet {
            self.observeDocument()
            self.observeSyntaxStyle()
            
            self.outlineView?.reloadData()
        }
    }
    
    
    override func viewDidAppear() {
        
        super.viewDidAppear()
        
        self.invalidateCurrentLocation()
        
        self.selectionObserver = NotificationCenter.default.addObserver(forName: NSTextView.didChangeSelectionNotification, object: nil, queue: .main) { [unowned self] (notification) in
            guard
                let textView = notification.object as? NSTextView,
                textView.window == self.view.window
                else { return }
            
            self.invalidateCurrentLocation(textView: textView)
        }
    }
    
    
    override func viewDidDisappear() {
        
        super.viewDidDisappear()
        
        if let observer = self.selectionObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    
    
    // MARK: Actions
    
    /// item in outlineView was clicked
    @IBAction func selectOutlineItem(_ outlineView: NSOutlineView) {
        
        self.selectOutlineItem(at: outlineView.clickedRow)
    }
    
    
    
    // MARK: Private Methods
    
    /// current outline items
    private var outlineItems: [OutlineItem] {
        
        return self.document?.syntaxStyle.outlineItems ?? []
    }
    
    
    /// current outline items
    private var document: Document? {
        
        return self.representedObject as? Document
    }
    
    
    /// select current outline item in textView
    private func selectOutlineItem(at row: Int) {
        
        guard
            let item = self.outlineItems[safe: row],
            item.title != .separator
            else { return }
        
        let range = item.range
        
        // abandon if text became shorter than range to select
        guard
            let textView = self.document?.textView,
            textView.string.nsRange.upperBound >= range.upperBound
            else { return }
        
        textView.selectedRange = range
        textView.scrollRangeToVisible(range)
        textView.showFindIndicator(for: range)
    }
    
    
    /// update document observation for syntax style
    private func observeDocument() {
        
        if let observer = self.documentObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        
        guard let document = self.document else { return }
        
        self.documentObserver = NotificationCenter.default.addObserver(forName: Document.didChangeSyntaxStyleNotification, object: document, queue: .main) { [unowned self] _ in
            self.observeSyntaxStyle()
            self.outlineView?.reloadData()
            
            self.invalidateCurrentLocation()
        }
    }
    
    
    /// update syntax style observation for outline menus
    private func observeSyntaxStyle() {
        
        if let observer = self.syntaxStyleObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        
        guard let syntaxStyle = self.document?.syntaxStyle else { return }
        
        self.syntaxStyleObserver = NotificationCenter.default.addObserver(forName: SyntaxStyle.didUpdateOutlineNotification, object: syntaxStyle, queue: .main) { [unowned self] _ in
            self.outlineView?.reloadData()
            
            self.invalidateCurrentLocation()
        }
    }
    
    
    /// update row selection to synchronize with editor's cursor location
    private func invalidateCurrentLocation(textView: NSTextView? = nil) {
        
        guard let outlineView = self.outlineView else { return }
        
        guard
            let textView = textView ?? self.document?.textView,
            let row = self.outlineItems.indexOfItem(for: textView.selectedRange, allowsSeparator: false),
            outlineView.numberOfRows > row
            else { return outlineView.deselectAll(nil) }
        
        self.isOwnSelectionChange = true
        outlineView.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
    }
    
}



extension OutlineViewController: NSOutlineViewDelegate {

    /// selection changed
    func outlineViewSelectionDidChange(_ notification: Notification) {
        
        defer {
            self.isOwnSelectionChange = false
        }
        
        guard
            !self.isOwnSelectionChange,
            let outlineView = notification.object as? NSOutlineView
            else { return }
        
        self.selectOutlineItem(at: outlineView.selectedRow)
    }
    
    
    /// avoid selecting separator item
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        
        return (item as? OutlineItem)?.title != .separator
    }
    
}



extension OutlineViewController: NSOutlineViewDataSource {
    
    /// return number of child items
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        
        return self.outlineItems.count
    }
    
    
    /// return if item is expandable
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        
        return false
    }
    
    
    /// return child items
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        
        return self.outlineItems[index]
    }
    
    
    /// return suitable item for cell to display
    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        
        guard
            let identifier = tableColumn?.identifier,
            let outlineItem = item as? OutlineItem
            else { return nil }
        
        switch identifier {
        case .title:
            let font: NSFont = outlineView.font ?? .systemFont(ofSize: NSFont.smallSystemFontSize)
            
            return outlineItem.attributedTitle(for: font)
            
        default:
            return nil
        }
    }
    
}
