//
//  FirstRunController.swift
//  lottoSchedule
//
//  Created by 김용해 on 6/28/25.
//
// 10001 - imageView
// 10002 - titleView
// 10003 - containerView

import UIKit

class FirstRunController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Grandient 배경 설정
        setUpGradientBackground()
        // ImageView Closer
        setUpImageView()
        // 제목 뷰 설정
        setUpTitleView()
        // 첫번째 정보 설정
        setUpInfoView()
        // 계속하기 버튼
        setUpButton()
    }
    
    // TODO: Grandient 배경 설정
    private func setUpGradientBackground() {
        self.view.backgroundColor = .clear
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [
            UIColor(hex: "FAE6E6").cgColor,
            UIColor.white.cgColor,
            UIColor(hex: "FAE6E6").cgColor,
        ]
        
        // 영역
        gradientLayer.locations = [
            NSNumber(value: 0.0),
            NSNumber(value: 0.2),
            NSNumber(value: 0.9),
            NSNumber(value: 1.0)
        ]
        
        // 방향 설정 (top → bottom)
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        // 뷰에 추가
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    // TODO: 이미지 뷰 설정
    private func setUpImageView() {
        lazy var imageView: UIImageView = {
            let image = UIImageView(image: UIImage(named: "lottoNumbers"))
            image.translatesAutoresizingMaskIntoConstraints = false
            image.contentMode = .scaleAspectFit
            image.tag = 10001
            return image
        }()
        self.view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 30),
        ])
    }
    // TODO: 제목 뷰 설정
    private func setUpTitleView() {
        lazy var titleView: UILabel = {
            let title = UILabel()
            title.translatesAutoresizingMaskIntoConstraints = false
            title.text = "로또 시작하기"
            title.tag = 10002
            title.font = .systemFont(ofSize: 32,weight: .semibold)
            title.textColor = .black
            title.textAlignment = .center
            
            return title
        }()
        
        if let imageView = self.view.viewWithTag(10001) as? UIImageView {
            self.view.addSubview(titleView)
            NSLayoutConstraint.activate([
                titleView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
                titleView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
                titleView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15)
            ])
        }
    }
    // TODO: 각 정보를 담고 있는 Row 열 뷰
    private func getInfoView(iconName: String, info: String) -> UIStackView {
        let iconView: UIImageView = {
            let icon = UIImageView(image: UIImage(systemName: iconName))
            icon.translatesAutoresizingMaskIntoConstraints = false
            icon.contentMode = .scaleAspectFit
            icon.tintColor = UIColor(hex: "D44853")
            return icon
        }()
        
        let spacerView: UIView = {
            let spacer = UIView()
            spacer.translatesAutoresizingMaskIntoConstraints = false
            return spacer
        }()
        
        let explainLabel: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = info
            label.numberOfLines = 3
            label.font = .systemFont(ofSize: 16, weight: .regular)
            
            return label
        }()
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 66),
            iconView.heightAnchor.constraint(equalToConstant: 66),
            // 공백
            spacerView.widthAnchor.constraint(equalToConstant: 20),
        ])
        
        let rowView: UIStackView = {
            let container = UIStackView(arrangedSubviews: [iconView, spacerView, explainLabel])
            container.translatesAutoresizingMaskIntoConstraints = false
            container.axis = .horizontal
            
            container.distribution = .fillProportionally
            return container
        }()
    
        return rowView
    }
    // TODO: 첫번째 정보 설정
    private func setUpInfoView() {
        
        let containerView: UIStackView = {
            let container = UIStackView(arrangedSubviews: [
                getInfoView(
                    iconName: "photo.on.rectangle.fill",
                    info: "로또를 찰영하면 자동으로 번호가 인식돼요. 더 이상 번호를 입력하거나 잃어버릴 걱정은 없어요",
                ),
                getInfoView(
                    iconName: "folder.badge.person.crop",
                    info: "로또들을 한눈에 확인하고 언제든 꺼내보는 나만의 로또 보관함",
                ),
                getInfoView(
                    iconName: "alarm",
                    info: "복권 추첨이 끝나는 날, 당신의 로또가 당첨됐는지 바로 알림을 드려요!",
                ),
            ])
            container.translatesAutoresizingMaskIntoConstraints = false
            container.axis = .vertical
            container.spacing = 20
            container.tag = 10003
            container.distribution = .fillEqually
            return container
        }()
        
        self.view.addSubview(containerView)
        
        if let titleView = self.view.viewWithTag(10002) as? UILabel {
            NSLayoutConstraint.activate([
                containerView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 20),
                containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
                containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15),
            ])
        }
    }
    // TODO: 계속하기 버튼 뷰
    private func setUpButton() {
        let button: UIButton = {
            let btn = UIButton()
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.setTitle("계속", for: .normal)
            btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
            btn.backgroundColor = UIColor(hex: "D44853")
            btn.layer.cornerRadius = 14
            return btn
        }()
        
        button.addAction(UIAction { _ in
            UserDefaults.standard.set(true, forKey: "isFirstRun") // not first excute
        }, for: .touchUpInside)
        
        self.view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            button.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
            button.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15),
            button.heightAnchor.constraint(equalToConstant: 52)
        ])
    }
}
