# TreeTableViewAdaptor

[![DUB](https://img.shields.io/dub/l/vibe-d.svg)]() [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

Implementation of Adaptor pattern to add to UITableView supporting to show hierarchical data structures

- Just conform your model to TreeNode protocol and it can be displayed in UITableView hierarchically
- Declare adaptor property in your UIViewController
- Implement UITableViewDelegate and UITableViewDatasource using adaptor

![Image](https://www.dropbox.com/s/wwe998yhnv1u2t7/ezgif.com-resize.gif?dl=1)



## Example

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

Declare adaptor

```swift
	var folderAdaptor = TreeTableViewAdaptor<FolderCellViewModel>()
```

Implement UITableViewDelegate and UITableViewDatasource using adaptor

```swift
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folderAdaptor.numberOfRows
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cellViewModel = folderAdaptor.node(forIndexPath: indexPath),
              let cell = tableView.dequeueReusableCellWithIdentifier(cellViewModel.ident) as? FolderTableViewCell
        else { return cellNotFound() }
        
        cell.folderViewModel = cellViewModel
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let cellViewModel = folderAdaptor.node(forIndexPath: indexPath) where cellViewModel.hasChildren else { return }
        folderAdaptor.changeNodeState(inTableView: tableView, atIndexPath: indexPath)
    }
```

Set your model array to adaptor and reload data in UITableView
```swift
	folderAdaptor.nodes = [YOUR_MODEL]
	tableView.reloadData()
```

## Installation

**Carthage:**
```
github "dtsvz/TreeTableViewAdaptor" == 1.0.0
```
Or you can manually add TreeTableViewAdaptor.swift file to your project


