//
//  CodeScannerView.swift
//  CUNYCoin
//
//  Created by Amit Aharoni on 11/4/23.
//

import Foundation
import AVFoundation
import SwiftUI

struct CodeScannerView: UIViewControllerRepresentable {
    var completion: (Result<ScanResult, ScanError>) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let scannerViewController = UIViewController()
        let captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
              captureSession.canAddInput(videoInput) else {
            completion(.failure(.initializationError))
            return scannerViewController
        }

        captureSession.addInput(videoInput)

        let metadataOutput = AVCaptureMetadataOutput()

        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(context.coordinator, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean8, .ean13] // The types of codes you expect on water bottles.
        } else {
            completion(.failure(.setupError))
            return scannerViewController
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = scannerViewController.view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        scannerViewController.view.layer.addSublayer(previewLayer)

        captureSession.startRunning()

        return scannerViewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    static func dismantleUIViewController(_ uiViewController: UIViewController, coordinator: Coordinator) {
        if let captureSession = (uiViewController.view.layer.sublayers?.first as? AVCaptureVideoPreviewLayer)?.session {
            captureSession.stopRunning()
        }
    }

    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        let parent: CodeScannerView

        init(_ scannerView: CodeScannerView) {
            self.parent = scannerView
        }

        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            if let metadataObject = metadataObjects.first {
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
                      let stringValue = readableObject.stringValue else { return }

                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                parent.completion(.success(ScanResult(string: stringValue)))
            }
        }
    }

    enum ScanError: Error {
        case initializationError
        case setupError
    }

    struct ScanResult {
        let string: String
    }
}
