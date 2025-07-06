//
//  SavedLottoViewController.swift
//  lottoSchedule
//
//  Created by 김용해 on 7/5/25.
//

import UIKit
class SavedLottoViewController: UIViewController {
    var savedLottos: [SavedLotto]!
    var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // 기본 셋업
        UICommon.setUpGradientBackground(view: self.view) // 배경색
        // navigation 제목 및 leftButton
        setUpConfigure()
        setUpTableViewConfigure()
        // SavedLottos update
        SavedLottoDataManager.shared.updateLottos()
        savedLottos = SavedLottoDataManager.shared.savedLottos
    }
    
    // TODO: 기본 셋업
    private func setUpConfigure() {
        self.navigationItem.title = "보관함"
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeScreen))
    }
    
    @objc func closeScreen() {
        self.dismiss(animated: true)
    }
    
    private func setUpTableViewConfigure() {
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none

        // Register header cell
        tableView.register(SavedLottoViewCell.self, forCellReuseIdentifier: SavedLottoViewCell.reuseIdentifier)
        self.view.addSubview(self.tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor,constant: 8),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -8),
            tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension SavedLottoViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return savedLottos.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedLottos[section].numbers?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SavedLottoViewCell.reuseIdentifier, for: indexPath) as? SavedLottoViewCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        guard let numbers = savedLottos[indexPath.section].numbers?[indexPath.row] as? [Int],
              let rank = (savedLottos[indexPath.section].ranks?[indexPath.row] as? String)
         else { return UITableViewCell() }
        
        cell.configure(numbers: numbers, rank: rank)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let containerView = UIView()
        containerView.backgroundColor = .clear

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = UIColor(hex: "676767")
        label.text = "제 \(savedLottos[section].round)회"
        label.backgroundColor = .clear

        containerView.addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 7),
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -7),
            label.topAnchor.constraint(equalTo: containerView.topAnchor),
            label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        return containerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
}
