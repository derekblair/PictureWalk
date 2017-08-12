//
//  Presentation.swift
//  PictureWalk
//
//  Created by Derek Blair on 2017-07-01.
//  Copyright © 2017 Derek Blair. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage



// MARK: Presentation Abstractions


final class Table<T:TableView> {

    var model: [T.Cell.Model] = [] {
        didSet {
            view.reload()
        }
    }

    lazy var view: T  = {
        return T.make {[weak self] _ in
            return self?.model ?? []
        }
    }()
}


protocol TableCell {
    associatedtype Model: Equatable
    static func make() -> Self
    func render(model: Model)
}

protocol TableView: class {
    associatedtype Cell: TableCell
    func reload()
    static func make(_ provider:@escaping ()->[Cell.Model]) -> Self
}


// MARK: Presentation Implementation


extension UITableViewController: TableView {
    typealias Cell = UITableViewCell

    func reload() {
        tableView.reloadData()
    }

    static func make(_ provider:@escaping ()->[Cell.Model]) -> Self {
        return self.init().then {
            let adapter = Adapter(provider)
            objc_setAssociatedObject($0, &$0.title, adapter, .OBJC_ASSOCIATION_RETAIN)
            $0.tableView.dataSource = adapter
            $0.tableView.delegate = adapter
            $0.title = "Picture Walk"
        }
    }

    @objc final private class Adapter: NSObject, UITableViewDataSource, UITableViewDelegate {

        let provider: (()->[Cell.Model])
        init(_ provider:@escaping ()->[Cell.Model]) {
            self.provider = provider
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            return tableView.dequeueReusableCell(withIdentifier: Cell.Constants.identifier) ?? Cell.make()
        }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return provider().count
        }

        func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            cell.render(model: provider()[provider().count - 1 - indexPath.row])
        }

        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return Cell.Constants.height
        }
    }
}


extension UITableViewCell: TableCell {
    func render(model: URL) {
        fullImageView?.sd_setImage(with: model, placeholderImage: nil)
    }

    static func make() -> Self {
        let result = self.init()
        _ = UIImageView().then {
            result.contentView.addSubview($0)
            let constraints = [
                $0.leftAnchor.constraint(equalTo: result.contentView.leftAnchor),
                $0.rightAnchor.constraint(equalTo: result.contentView.rightAnchor),
                $0.topAnchor.constraint(equalTo: result.contentView.topAnchor),
                $0.bottomAnchor.constraint(equalTo: result.contentView.bottomAnchor)
            ]
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate(constraints)
            $0.tag = Constants.fullImageViewTag
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
        }
        return result
    }

    var fullImageView: UIImageView? {
        return viewWithTag(Constants.fullImageViewTag) as? UIImageView
    }

    struct Constants {
        static let identifier = "PictureCell"
        static let height: CGFloat = 200
        static let fullImageViewTag = 0xAA
    }
}

// MARK: Helpers

extension NSObject: Then {}
protocol Then {}
extension Then {
    func then( _ perform: (Self) -> ()) -> Self {
        perform(self)
        return self
    }
}



