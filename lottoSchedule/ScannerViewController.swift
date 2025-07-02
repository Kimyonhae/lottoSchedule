//
//  ScannerViewController.swift
//  lottoSchedule
//
//  Created by 김용해 on 7/1/25.
//

import UIKit
import AVFoundation
import Combine

class ScannerViewController: UIViewController {
    private var scanResult: String?
    private let captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var tableView: UITableView!
    private var hasLottoValue: Bool = false // QR 스캔 전 뷰 상태 값
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
        // 기본 설정
        setUpConfigure()
        // Permission check and request Permisson
        requestCameraPermission()
        // bottom view container
        setupBottomView()
        // bottom tableView setUp
        setUpLottoList()
        // bottom EmptyView setUp
        setUpEmptyView()
        // bottom State setUp
        updateLottoStateUI()
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
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "minus.circle"), style: .plain, target: self, action: #selector(closeScanner))
    }
    
    // TODO: Camera 요청 권한을 통해 setUpCameraConfigure 실행
    private func requestCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // 카메라 실행
            print(" 접근 권한이 있음!!")
            setUpCameraConfigure()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted { //bool
                    DispatchQueue.main.async {
                        self.setUpCameraConfigure()
                    }
                }
            }
        default:
            print("접근을 허용 안함")
        }
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
    
    // TODO: tableView setUp for Lotto checking
    private func setUpLottoList() {
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ScannerCellView.self, forCellReuseIdentifier: ScannerCellView.identifier)
        
        bottomView.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: explainLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor)
        ])
    }
    
    // TODO: empty lotto view in bottom
    private func setUpEmptyView() {
        let imageView: UIImageView = {
            let image = UIImageView(image: UIImage(systemName: "qrcode.viewfinder"))
            image.translatesAutoresizingMaskIntoConstraints = false
            image.contentMode = .scaleAspectFit
            image.tintColor = .lightGray
            image.isUserInteractionEnabled = true
            image.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(scanQRCode)))
            
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
    
    @objc func scanQRCode() {
        self.hasLottoValue.toggle()
        print("hasLottoValue: \(hasLottoValue)")
        updateLottoStateUI()
    }
    
    private func updateLottoStateUI() {
        tableView.isHidden = !hasLottoValue
        emptyView.isHidden = hasLottoValue
    }
}

extension ScannerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ScannerCellView.identifier) as? ScannerCellView else {
            return ScannerCellView()
        }
        cell.selectionStyle = .none
        cell.configure(with: [12,23,45,32,11,23])
        return cell
    }
}



extension ScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metaData = metadataObjects.first as? AVMetadataMachineReadableCodeObject, metaData.type == .qr {
            if let result = metaData.stringValue {
                self.scanResult = result // URL로 scanResult address check
                guard scanResult != nil else { return }
                DispatchQueue.main.async {
                    self.captureSession.stopRunning()
                }
            }
        }
    }
}
