//
//  DCSectionList.swift
//  Runner
//
//  Created for DC MAUI Framework
//

import UIKit

/// Data structure for representing a section in the list
struct DCSection {
    let sectionId: String
    let data: [[String: Any]]
    let renderSectionHeader: [String: Any]?
    let renderSectionFooter: [String: Any]?
}

/// SectionList component that matches React Native's SectionList
class DCSectionList: DCListView {
    // Section-specific properties
    private var sections: [DCSection] = []
    private var stickySectionHeadersEnabled: Bool = false
    
    // Additional function references specific to sections
    var renderSectionHeaderRef: [String: Any]?
    var renderSectionFooterRef: [String: Any]?
    var sectionKeyExtractorRef: [String: Any]?
    
    // Reuse identifiers
    private let headerReuseIdentifier = "DCSectionHeaderIdentifier"
    private let footerReuseIdentifier = "DCSectionFooterIdentifier"
    
    // Table view-specific configuration
    private var sectionHeaderHeight: CGFloat = UITableView.automaticDimension
    private var sectionFooterHeight: CGFloat = UITableView.automaticDimension
    
    override func setupTableView() {
        super.setupTableView()
        
        // Register reusable views for section headers and footers
        tableView.register(DCSectionHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: headerReuseIdentifier)
        tableView.register(DCSectionHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: footerReuseIdentifier)
        
        // Section specific setup
        tableView.sectionHeaderHeight = sectionHeaderHeight
        tableView.sectionFooterHeight = sectionFooterHeight
    }
    
    override func updateProps(props: [String: Any]) {
        // First handle the basic list properties from the parent class
        super.updateProps(props: props)
        
        // Then handle section list-specific properties
        if let sectionsData = props["sections"] as? [[String: Any]] {
            parseSections(sectionsData)
        }
        
        if let stickySectionHeadersEnabled = props["stickySectionHeadersEnabled"] as? Bool {
            self.stickySectionHeadersEnabled = stickySectionHeadersEnabled
            if #available(iOS 11.0, *) {
                tableView.insetsContentViewsToSafeArea = stickySectionHeadersEnabled
            }
        }
        
        if let keyExtractor = props["keyExtractor"] as? [String: Any] {
            // Store the key extractor function ID for later use
            self.keyExtractorRef = keyExtractor
        }
        
        if let sectionKeyExtractor = props["sectionKeyExtractor"] as? [String: Any] {
            // Store the section key extractor function ID for later use
            self.sectionKeyExtractorRef = sectionKeyExtractor
        }
        
        if let renderSectionHeader = props["renderSectionHeader"] as? [String: Any] {
            // Store the render section header function ID for later use
            self.renderSectionHeaderRef = renderSectionHeader
        }
        
        if let renderSectionFooter = props["renderSectionFooter"] as? [String: Any] {
            // Store the render section footer function ID for later use
            self.renderSectionFooterRef = renderSectionFooter
        }
        
        if let renderItem = props["renderItem"] as? [String: Any] {
            // Store the render item function ID for later use
            self.renderItemRef = renderItem
        }
        
        // Update data
        reloadList()
    }
    
    private func parseSections(_ sectionsData: [[String: Any]]) {
        var newSections: [DCSection] = []
        
        for sectionData in sectionsData {
            guard let key = sectionData["key"] as? String,
                  let sectionItems = sectionData["data"] as? [[String: Any]] else {
                continue
            }
            
            let renderSectionHeader = sectionData["renderSectionHeader"] as? [String: Any]
            let renderSectionFooter = sectionData["renderSectionFooter"] as? [String: Any]
            
            let section = DCSection(
                sectionId: key,
                data: sectionItems,
                renderSectionHeader: renderSectionHeader,
                renderSectionFooter: renderSectionFooter
            )
            
            newSections.append(section)
        }
        
        self.sections = newSections
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section < sections.count else { return 0 }
        return sections[section].data.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! DCListItemCell
        
        guard indexPath.section < sections.count,
              indexPath.row < sections[indexPath.section].data.count else {
            return cell
        }
        
        let item = sections[indexPath.section].data[indexPath.row]
        configureCell(cell, withItem: item, atIndexPath: indexPath)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section < sections.count,
              let renderSectionHeaderRef = self.renderSectionHeaderRef ?? sections[section].renderSectionHeader else {
            return nil
        }
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerReuseIdentifier) as! DCSectionHeaderFooterView
        
        // Configure header view similar to cell configuration
        let sectionData = sections[section]
        let params: [String: Any] = [
            "section": [
                "key": sectionData.sectionId,
                "data": sectionData.data
            ],
            "sectionIndex": section
        ]
        
        // Render the header view using the render function from JS side
        let headerContentView = DCViewCoordinator.shared?.renderFunction(reference: renderSectionHeaderRef, params: params)
        
        if let contentView = headerContentView {
            headerView.configure(withContentView: contentView)
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard section < sections.count,
              let renderSectionFooterRef = self.renderSectionFooterRef ?? sections[section].renderSectionFooter else {
            return nil
        }
        
        let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: footerReuseIdentifier) as! DCSectionHeaderFooterView
        
        // Configure footer view similar to header configuration
        let sectionData = sections[section]
        let params: [String: Any] = [
            "section": [
                "key": sectionData.sectionId,
                "data": sectionData.data
            ],
            "sectionIndex": section
        ]
        
        // Render the footer view using the render function from JS side
        let footerContentView = DCViewCoordinator.shared?.renderFunction(reference: renderSectionFooterRef, params: params)
        
        if let contentView = footerContentView {
            footerView.configure(withContentView: contentView)  // Fix: use footerView instead of headerView
        }
        
        return footerView
    }
    
    override func configureCell(_ cell: DCListItemCell, withItem item: [String: Any], atIndexPath indexPath: IndexPath) {
        // Get section information
        let section = sections[indexPath.section]
        
        // Create rendering parameters
        let params: [String: Any] = [
            "item": item,
            "index": indexPath.row,
            "section": [
                "key": section.sectionId,
                "data": section.data
            ],
            "sectionIndex": indexPath.section
        ]
        
        // Generate a key for the item using key extractor if provided
        let itemKey: String
        if let keyExtractor = self.keyExtractorRef {
            itemKey = DCViewCoordinator.shared?.callFunction(reference: keyExtractor, params: ["item": item, "index": indexPath.row]) as? String ?? UUID().uuidString
        } else if let key = item["key"] as? String {
            itemKey = key
        } else {
            itemKey = "\(section.sectionId)_\(indexPath.row)"
        }
        
        // Invoke renderItem function to get the cell content
        if let renderItem = self.renderItemRef,
           let contentView = DCViewCoordinator.shared?.renderFunction(reference: renderItem, params: params) {
            cell.configure(withContentView: contentView, itemKey: itemKey)
        } else {
            let emptyView = self.withEmptyContent()
            cell.configure(withContentView: emptyView, itemKey: itemKey)
        }
    }
    
    // Override scroll view delegate methods to include section information
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        
        // Add section-specific scroll information if needed
        if let visibleSectionIndices = getVisibleSectionIndices() {
            DCViewCoordinator.shared?.sendEvent(
                viewId: viewId,
                eventName: "onViewableItemsChanged",
                params: [
                    "viewableItems": getViewableItems(),
                    "visibleSections": visibleSectionIndices,
                    "changed": [],
                    "target": viewId
                ]
            )
        }
    }
    
    private func getVisibleSectionIndices() -> [Int]? {
        guard let indexPaths = tableView.indexPathsForVisibleRows else {
            return nil
        }
        
        // Get unique section indices
        return Array(Set(indexPaths.map { $0.section })).sorted()
    }
    
    func getViewableItems() -> [[String: Any]] {
        guard let indexPaths = tableView.indexPathsForVisibleRows else {
            return []
        }
        
        return indexPaths.compactMap { indexPath -> [String: Any]? in
            guard indexPath.section < sections.count,
                  indexPath.row < sections[indexPath.section].data.count else {
                return nil
            }
            
            let item = sections[indexPath.section].data[indexPath.row]
            let section = sections[indexPath.section]
            
            return [
                "item": item,
                "key": item["key"] as? String ?? "\(section.sectionId)_\(indexPath.row)",
                "index": indexPath.row,
                "sectionIndex": indexPath.section,
                "section": [
                    "key": section.sectionId,
                    "data": section.data
                ],
                "isViewable": true
            ]
        }
    }
    
    override func reloadList() {
        tableView.reloadData()
    }
}

// Custom view for section headers and footers
class DCSectionHeaderFooterView: UITableViewHeaderFooterView {
    private var sectionContentContainer: UIView?
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        // Ensure background is clear
        if #available(iOS 14.0, *) {
            backgroundConfiguration = .clear()
        } else {
            backgroundView = UIView()
            backgroundView?.backgroundColor = .clear
        }
    }
    
    func configure(withContentView newContentView: UIView) {
        // Remove any existing content view
        sectionContentContainer?.removeFromSuperview()
        
        // Add the new content view
        sectionContentContainer = newContentView
        newContentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(newContentView)
        
        // Set constraints
        NSLayoutConstraint.activate([
            newContentView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            newContentView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            newContentView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            newContentView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
        ])
    }
}
