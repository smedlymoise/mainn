//
//  CodeScannerView.swift
//  CUNYCoin
//
//  Created by Amit Aharoni on 11/4/23.
//

import Foundation
import AVFoundation
import SwiftUI

// This struct conforms to UIViewControllerRepresentable, allowing integration of a UIViewController in SwiftUI.
struct CodeScannerView: UIViewControllerRepresentable {
    // This closure will handle the result of the scan.
    var completion: (Result<ScanResult, ScanError>) -> Void

    // Coordinator class to manage the communication between UIKit and SwiftUI.
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // Creates the UIViewController instance that will manage the camera view.
    func makeUIViewController(context: Context) -> UIViewController {
        let scannerViewController = UIViewController()
        // AVCaptureSession manages capture activity and coordinates the flow of data from input devices to capture outputs.
        let captureSession = AVCaptureSession()

        // Setting up the camera input.
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
              captureSession.canAddInput(videoInput) else {
            completion(.failure(.initializationError))
            return scannerViewController
        }
        
        // Add the camera as the input device.
        captureSession.addInput(videoInput)
        
        // Set up the output for capturing metadata (in this case, barcodes).
        let metadataOutput = AVCaptureMetadataOutput()

        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            // Set the delegate to receive the metadata objects and set the type of metadata to look for.
            metadataOutput.setMetadataObjectsDelegate(context.coordinator, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean8, .ean13, .qr] // The types of codes you expect on water bottles (Barcodes types like EAN8 and EAN13.)
        } else {
            completion(.failure(.setupError))
            return scannerViewController
        }

        // Set up the preview layer to show camera content.
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        // Make the preview layer the same size as the view container.
        previewLayer.frame = scannerViewController.view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        scannerViewController.view.layer.addSublayer(previewLayer)

        // Start the capture session, this begins the flow of data from the inputs to the outputs.
        captureSession.startRunning()

        return scannerViewController
    }
    
    // This method is called when the SwiftUI view re-renders and allows updating of the UIViewController.
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    // This method is called when the SwiftUI view is removed from the view hierarchy.
    static func dismantleUIViewController(_ uiViewController: UIViewController, coordinator: Coordinator) {
        // Stop the session if the view is disappearing.
        if let captureSession = (uiViewController.view.layer.sublayers?.first as? AVCaptureVideoPreviewLayer)?.session {
            captureSession.stopRunning()
        }
    }
    
    // Coordinator class that conforms to AVCaptureMetadataOutputObjectsDelegate to handle the metadata capture.
    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        let parent: CodeScannerView

        init(_ scannerView: CodeScannerView) {
            self.parent = scannerView
        }

        // This delegate method is called when a barcode is captured by the session.
        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            if let metadataObject = metadataObjects.first {
                
                // The metadataObject is cast to AVMetadataMachineReadableCodeObject and its string value is extracted.
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
                      let stringValue = readableObject.stringValue else { return }

                // Trigger a haptic feedback to notify the user that a code was scanned.
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                
                // Call the completion handler with the scanned code.
                parent.completion(.success(ScanResult(string: stringValue)))
            }
        }
    }
    
    // Custom error types for scanning.
    enum ScanError: Error {
        case initializationError // Error in setting up the camera input.
        case setupError // Error in setting up the capture session or adding outputs.
    }
    
    // Structure to encapsulate the result of a scan.
    struct ScanResult {
        let string: String // The actual string value decoded from the barcode.
    }
}
