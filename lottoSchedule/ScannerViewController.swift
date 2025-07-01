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
    
    lazy var testLabel: UILabel = {
        let label = UILabel()
        label.text = scanResult ?? "QR 코드 아직없음"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 기본 설정
        setUpConfigure()
        // Permission check and request Permisson
        requestCameraPermission()
        // bottom view container
        setupBottomView()
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
        
        bottomView.addSubview(testLabel)
        self.view.addSubview(bottomView)
        
        NSLayoutConstraint.activate([
            bottomView.topAnchor.constraint(equalTo: cameraView.bottomAnchor),
            bottomView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            testLabel.topAnchor.constraint(equalTo: bottomView.topAnchor),
            testLabel.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor),
            testLabel.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor),
            testLabel.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor)
        ])
    }
    // leftBarButtonItem selector method
    @objc func closeScanner() {
        self.dismiss(animated: true)
    }
}


extension ScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metaData = metadataObjects.first as? AVMetadataMachineReadableCodeObject, metaData.type == .qr {
            if let result = metaData.stringValue {
                self.scanResult = result // URL로 scanResult address check
                guard scanResult != nil else { return }
                testLabel.text = scanResult
                DispatchQueue.main.async {
                    self.captureSession.stopRunning()
                }
            }
        }
    }
}
