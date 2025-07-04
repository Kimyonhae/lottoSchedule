//
//  PopOverContentViewController.swift
//  lottoSchedule
//
//  Created by 김용해 on 6/30/25.
//

import UIKit

class PopOverContentViewController: UITableViewController {
    var lotto: Lotto? = nil
    weak var delegate: PopOverContentViewControllerDelegate?
    private let menu: [MenuItem]
    init(lotto: Lotto, menu: [MenuItem]) {
        self.lotto = lotto
        self.menu = menu
        
        super.init(nibName: nil, bundle: nil)
    }
    
    // basic init
    init(menu: [MenuItem]) {
        self.menu = menu
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
                if let lotto = lotto {
                    delegate?.didTapDeleteButton(lotto: lotto)
                }
            case .destination:
                print("페이지 이동을 할거에요")
            self.dismiss(animated: true) { [weak self] in
                self?.delegate?.didTapLottoResultButton()
            }
            
            return
        }
        self.dismiss(animated: true)
    }
}

