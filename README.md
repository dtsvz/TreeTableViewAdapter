# TreeTableViewAdapter

[![DUB](https://img.shields.io/dub/l/vibe-d.svg)]() [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

Implementation of Adapter pattern to add to UITableView supporting to show hierarchical data structures

**Quick start:**
- Just conform your model to TreeNode protocol and it can be displayed in UITableView hierarchically
- Implement custom TableViewCell
- Declare Adapter property in your UIViewController
- Implement UITableViewDelegate and UITableViewDatasource using Adapter

![Image](https://www.dropbox.com/s/wwe998yhnv1u2t7/ezgif.com-resize.gif?dl=1) ![Image](https://www.dropbox.com/s/p9k8s3hziwly15j/ezgif.com-resize-3.gif?dl=1)





## Usage

Comform your CellViewModel to TreeNode protocol as a FolderCellViewModel class

```swift
	public protocol TreeNode {
	    associatedtype T
	    var opened: Bool { get set }
	    var level: Int { get set }
	    var hasChildren: Bool { get }
	    func children <T where T: TreeNode> () -> [T]
	}
```

```swift
	class FolderCellViewModel: TreeNode {
	    typealias T = FolderCellViewModel
	    
	    init(ident: String) {
	        self.ident = ident
	    }

	    var ident: String
	    var name: String?
	    var subFolders = [FolderCellViewModel]()
	    
	    var opened: Bool = false
	    var level: Int = 0
	    
	    var hasChildren: Bool {
	        return subFolders.count > 0
	    }
	    
	    func children<FolderCellViewModel>() -> [FolderCellViewModel] {
	        return subFolders.flatMap { $0 as? FolderCellViewModel }
	    }
	}
```
Implement custom tableview cell

```swift

	class FolderTableViewCell: UITableViewCell {

	    @IBOutlet weak var label: UILabel!
	    @IBOutlet weak var folderImageView: UIImageView!
	    @IBOutlet weak var labelOffsetConstraint: NSLayoutConstraint!

	    var folderViewModel: FolderCellViewModel? { didSet { fill() } }

	    func fill() {
	        guard let folder = folderViewModel else { return }
	        label?.text = folder.name
	        labelOffsetConstraint.constant = CGFloat(folder.level * 16)
	        folderImageView.image = nil
	        backgroundColor = NodeStyles.leafColor
	        
	        guard folder.hasChildren else { return }
	        backgroundColor = NodeStyles.parentColor
	        folderImageView.image = folder.opened ? NodeStyles.openedImage : NodeStyles.closedImage
	    }
	}

	struct NodeStyles {
	    static let parentColor: UIColor = {
	        return UIColor.whiteColor()
	    }()
	    
	    static let leafColor: UIColor = {
	        return UIColor.whiteColor()
	    }()
	    
	    static let openedImage: UIImage? = {
	        return UIImage(named: "li_up")
	    }()
	    
	    static let closedImage: UIImage? = {
	        return UIImage(named: "li_down")
	    }()
	}
```

Declare Adapter

```swift
	var folderAdapter = TreeTableViewAdapter<FolderCellViewModel>()
```

Implement UITableViewDelegate and UITableViewDatasource using Adapter

```swift
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folderAdapter.numberOfRows
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cellViewModel = folderAdapter.node(forIndexPath: indexPath),
              let cell = tableView.dequeueReusableCellWithIdentifier(cellViewModel.ident) as? FolderTableViewCell
        else { return cellNotFound() }
        
        cell.folderViewModel = cellViewModel
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let cellViewModel = folderAdapter.node(forIndexPath: indexPath) where cellViewModel.hasChildren else { return }
        folderAdapter.changeNodeState(inTableView: tableView, atIndexPath: indexPath)
    }
```

Set your model array to Adapter and reload data in UITableView
```swift
	folderAdapter.nodes = [YOUR_MODEL]
	tableView.reloadData()
```

## Installation

**Carthage:**
```
github "dtsvz/TreeTableViewAdapter" == 1.0.1
```
Or you can manually add TreeTableViewAdapter.swift file to your project


