//
//  PopOverContentViewController.swift
//  lottoSchedule
//
//  Created by 김용해 on 6/30/25.
//

import UIKit

class PopOverContentViewController: UITableViewController {
    let lotto: Lotto
    weak var delegate: PopOverContentViewControllerDelegate?
    
    init(lotto: Lotto) {
        self.lotto = lotto
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private struct MenuItem {
        let title: String
        let iconName: String
        let action: action
        enum action {
            case update
            case delete
        }
    }
    
    private let menu: [MenuItem] = [
        MenuItem(title: "수정하기", iconName: "pencil.circle", action: .update),
        MenuItem(title: "삭제하기", iconName: "trash.circle", action: .delete)
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PopOverMenu")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        menu.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PopOverMenu", for: indexPath)
        
        var config = cell.defaultContentConfiguration()
        config.text = menu[indexPath.row].title
        config.image = UIImage(systemName: menu[indexPath.row].iconName)
        config.imageProperties.tintColor = UIColor(hex: "D44853")
        cell.contentConfiguration = config
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }
    
    // Action Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedAction = menu[indexPath.row].action
        
        switch selectedAction {
            case .update:
                print("update!!")
            case .delete:
                print("hello delete!!")
                delegate?.didTapDeleteButton(lotto: lotto)
        }
        self.dismiss(animated: true)
    }
}

