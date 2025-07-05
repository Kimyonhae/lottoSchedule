//
//  ScannerViewController.swift
//  lottoSchedule
//
//  Created by 김용해 on 7/1/25.
//

import UIKit
import AVFoundation

class ScannerViewController: UIViewController {
    private var viewModel: ScannerViewModel = .init()
    private let captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer!
    lazy var cameraView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var bottomView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    // TODO: QR 설명 Label
    lazy var explainLabel: UILabel = {
        let label = UILabel()
        label.text = "QR 코드를 스캔하거나 QR 이미지를 업로드 해보세요"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.tintColor = .systemGray3
        label.textAlignment = .center
        return label
    }()
    // Empty Container
    let emptyView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .fillProportionally
        
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.scannerDelegate = self // ScannerVC에 주입
        // 기본 설정
        setUpConfigure()
        // Camera View Container if authorized
        setUpCameraConfigure()
        // bottom view container
        setupBottomView()
        // bottom EmptyView setUp
        setUpEmptyView()
    }
    
    // AutoLayout이 지정된 후 배치
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = cameraView.layer.bounds
    }
    
    // TODO: 기본 설정
    private func setUpConfigure() {
        self.view.backgroundColor = .white
        navigationItem.title = "로또 스캔"
        navigationItem.leftBarButtonItem?.tintColor = .black
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(closeScanner))
    }
        
    // TODO: 카메라 화면 뷰
    func setUpCameraConfigure() {
        guard let cameraDevice = AVCaptureDevice.default(for: .video) else { return }
        
        do {
            let cameraInput = try AVCaptureDeviceInput(device: cameraDevice)
            if captureSession.canAddInput(cameraInput) {
                captureSession.addInput(cameraInput)
            }
            let output = AVCaptureMetadataOutput()
            if captureSession.canAddOutput(output) {
                captureSession.addOutput(output)
                output.setMetadataObjectsDelegate(self, queue: .main)
                output.metadataObjectTypes = [.qr]
            }
            
            // Camera Layout
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.videoGravity = .resizeAspectFill
            cameraView.layer.addSublayer(previewLayer) // cameraView에 감싸기
            
            
            DispatchQueue.global().async {
                // 백그라운드 실행이 필요한 함수
                self.captureSession.startRunning()
            }
        } catch {
            print("카메라 접근 실패..\(error)")
        }
        
        self.view.addSubview(cameraView)
        NSLayoutConstraint.activate([
            cameraView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            cameraView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            cameraView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            cameraView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.5)
        ])
    }
        
    // TODO: 하단 View
    func setupBottomView() {
        bottomView.addSubview(explainLabel)
        self.view.addSubview(bottomView)
        
        NSLayoutConstraint.activate([
            bottomView.topAnchor.constraint(equalTo: cameraView.bottomAnchor),
            bottomView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            explainLabel.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 20),
            explainLabel.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor),
            explainLabel.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor),
        ])
    }
    
    // leftBarButtonItem selector method
    @objc func closeScanner() {
        self.dismiss(animated: true)
    }
    
    // TODO: empty lotto view in bottom
    private func setUpEmptyView() {
        let imageView: UIImageView = {
            let image = UIImageView(image: UIImage(systemName: "qrcode.viewfinder"))
            image.translatesAutoresizingMaskIntoConstraints = false
            image.contentMode = .scaleAspectFit
            image.tintColor = .lightGray
            
            return image
        }()
        
        let labelView: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = .systemFont(ofSize: 14, weight: .light)
            label.text = "QR코드 스캔하기"
            label.tintColor = .lightGray
            
            return label
        }()
        
        emptyView.addArrangedSubview(imageView)
        emptyView.addArrangedSubview(labelView)
        bottomView.addSubview(emptyView)
        NSLayoutConstraint.activate([
            emptyView.centerXAnchor.constraint(equalTo: bottomView.centerXAnchor),
            emptyView.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor),
            
            imageView.widthAnchor.constraint(equalToConstant: 50),
            imageView.heightAnchor.constraint(equalToConstant: 50),
        ])
    }

}

extension ScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metaData = metadataObjects.first as? AVMetadataMachineReadableCodeObject, metaData.type == .qr {
            if let result = metaData.stringValue {
                
                // 한번만 주입 하고 똑같은 값은 guard 처리
                guard viewModel.scanResult != result else { return }
                
                self.viewModel.scanResult = result // URL로 scanResult address check

                viewModel.fetchCrawlingData()
                
                DispatchQueue.main.async {
                    self.captureSession.stopRunning()
                }
            }
        }
    }
}


extension ScannerViewController: ScannerViewDelegate {
    func scannerCompletion(with lotto: [Int], round: String) {
        DispatchQueue.main.async {
            DataManager.shared.createLotto(numbers: lotto, round: round)
            DataManager.shared.updateLottos()
            self.dismiss(animated: true)
        }
    }
    
    func scannerNotAvailableLotto() {
        DispatchQueue.main.async {
            // 닫기
            self.dismiss(animated: true) {
                // showr Alert on
                let alert = UIAlertController(title: "알림", message: "이미 추첨된 회차입니다", preferredStyle: .alert)
                
                // add action
                alert.addAction(UIAlertAction(title: "확인", style: .cancel))

                if let mainVC = UIApplication.shared.connectedScenes
                    .compactMap({( $0 as? UIWindowScene)?.keyWindow })
                    .first?.rootViewController {
                    mainVC.present(alert, animated: true)
                }
            }
        }
    }
}
