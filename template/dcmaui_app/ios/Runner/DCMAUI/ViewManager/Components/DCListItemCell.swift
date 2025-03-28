import UIKit

class DCListItemCell: UITableViewCell {
    var contentViewId: String = ""
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }
    
    private func setupCell() {
        backgroundColor = .clear
        selectionStyle = .none
    }
    
    func configure(withContentView contentView: UIView, itemKey: String) {
        // Remove any previous content views
        for subview in contentView.subviews {
            if subview.tag == 42 {
                subview.removeFromSuperview()
            }
        }
        
        // Add new content view
        contentView.tag = 42
        contentViewId = itemKey
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(contentView)
        
        // Set constraints
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
        ])
    }
    
    func configure(withEmptyContent: UIView) {
        // Minimal empty configuration
        configure(withContentView: withEmptyContent, itemKey: "empty_\(UUID().uuidString)")
    }
}
