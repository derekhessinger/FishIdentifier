import SwiftUI
import AVFoundation
import UIKit
import TensorFlowLite
import CoreML
import Vision


struct ContentView: View {
    @State private var showImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var selectedImage: UIImage?
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var inputImage: UIImage?
    @State private var predictionResult: String = ""
    @State private var labelText: String = "Select Image"


    var body: some View {
        ZStack {
            Color(red: 0.2, green: 0.7, blue: 1.0)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Text("FishIdentifier")
                    .font(.system(size: 36, weight: .bold, design: .default))
                    .italic()
                    .padding()
                
                Text(labelText)
                        .multilineTextAlignment(.center)
                        .padding()
                        .frame(minWidth: 200, minHeight: 100)
                        .background(Color.white)
                        .cornerRadius(10)
                        .foregroundColor(.blue)
                    
                

                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                }

                if !predictionResult.isEmpty {
                    Text("Prediction: \(predictionResult)")
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                }

                Button(action: {
                    checkCameraAccess()
                }) {
                    HStack {
                        Image(systemName: "camera")
                        Text("Take a Picture")
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }

                Button(action: {
                    self.sourceType = .photoLibrary
                    self.showImagePicker = true
                }) {
                    HStack {
                        Image(systemName: "photo.on.rectangle")
                        Text("Select a Picture")
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                
                Button(action: {
                    selectedImage = nil
                    predictionResult = ""  // Clear the prediction when image is removed
                }){
                    HStack{
                        Image(systemName: "trash")
                        Text("Remove image")
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            .padding()
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(sourceType: self.sourceType, selectedImage: self.$selectedImage, predictFish: self.predictFish(image:))
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Camera Access"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    func checkCameraAccess() {
        print("Checking camera access...")
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            print("Camera access authorized.")
            self.sourceType = .camera
            self.showImagePicker = true
        case .notDetermined:
            print("Camera access not determined. Requesting access...")
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    print("Camera access granted.")
                    DispatchQueue.main.async {
                        self.sourceType = .camera
                        self.showImagePicker = true
                    }
                } else {
                    print("Camera access denied.")
                    self.showCameraAccessDeniedAlert()
                }
            }
        case .denied, .restricted:
            print("Camera access denied or restricted.")
            self.showCameraAccessDeniedAlert()
        @unknown default:
            print("Unknown camera access status.")
            self.showCameraAccessDeniedAlert()
        }
    }

    func showCameraAccessDeniedAlert() {
        DispatchQueue.main.async {
            self.alertMessage = "Camera access is denied. Please enable it in Settings to use this feature."
            self.showAlert = true
        }
    }

    /*
    // Create function to pass photo to model, get prediction and print predicted fish species
    func predictFish(for image: UIImage) {
        
        // This checks for the model availability
        
        if let resourcePath = Bundle.main.resourcePath {
            do {
                let resourceContents = try FileManager.default.contentsOfDirectory(atPath: resourcePath)
                print("Resource contents: \(resourceContents)")
                
                if let modelsPath = Bundle.main.path(forResource: "Models", ofType: nil) {
                    let modelsContents = try FileManager.default.contentsOfDirectory(atPath: modelsPath)
                    print("Models folder contents: \(modelsContents)")
                } else {
                    print("Models folder not found in the bundle")
                }
            } catch {
                print("Error accessing bundle resources: \(error.localizedDescription)")
            }
        }

        print("Predicting fish for image...")

                guard let modelURL = Bundle.main.url(forResource: "Fish", withExtension: "mlmodelc") else {
                    print("Failed to find the Fish.mlmodelc file in the bundle")
                    return
                }
                
                do {
                    // Load the MLModel from the .mlmodelc
                    let model = try MLModel(contentsOf: modelURL)

                    let output = try model.prediction(from: image as! MLFeatureProvider)

                    // Extract the MLMultiArray from the output
                    guard let multiArray = output.featureValue(for: "output")?.multiArrayValue else {
                        print("Failed to extract MLMultiArray from output")
                        return
                    }

                    // Process the MLMultiArray output
                    print("MLMultiArray output: \(multiArray)")

                    // Example processing of MLMultiArray assuming it's a classification model
                    let probabilities = multiArray.toArray()
                    if let topIndex = probabilities.indices.max(by: { probabilities[$0] < probabilities[$1] }) {
                        let topProbability = probabilities[topIndex]
                        print("Top probability: \(topProbability)")
                        // Map index to label if you have a label list
                        // self.predictionResult = labels[topIndex] + ": \(String(format: "%.2f", topProbability))"
                    }

                    DispatchQueue.main.async {
                        self.predictionResult = "Processed MLMultiArray output"
                        print("Updated predictionResult: \(self.predictionResult)")
                    }
                } catch {
                    print("Failed to load Core ML model or perform prediction: \(error.localizedDescription)")
                }
            }
    */
    private func predictFish(image: UIImage?){
        // Resize image, remove buffer
        guard let buffer = image?.resize(size: CGSize(width: 224, height: 224))?
            .getCVPixelBuffer() else{
                return
        }
        
        do{
            let config = MLModelConfiguration()
            let model = try Fish(configuration: config)
            //let input = FishInput(image: buffer)
            
            let output = try model.prediction(image: buffer)
            let array_out = output.Identity
            let classLabels = [
                "Largemouth Bass",
                "Smallmouth Bass",
                "Brook Trout",
                "Rainbow Trout",
                "Striped Bass",
                "Brown Trout",
                "Northern Pike",
                "Pickerel",
                "Croppie",
                "Sunfish",
                "Bluegill",
                "Lake Trout",
                "Sturgeon",
                "Muskie"
            ]
            let top3Predictions = getTop3Predictions(from: array_out, classLabels: classLabels)
            // Create a string from the top 3 predictions
            let predictionText = top3Predictions.enumerated().map { index, prediction in
                let (label, confidence) = prediction
                return "\(index + 1). \(label): \(String(format: "%.2f", confidence * 100))%"
            }.joined(separator: "\n")
            print(predictionText)
            DispatchQueue.main.async {
                    self.labelText = predictionText
                    print("Updated labelText: \(self.labelText)")
                }
        }
        catch{
            print(error.localizedDescription)
        }
    }

    func getTop3Predictions(from multiArray: MLMultiArray, classLabels: [String]) -> [(String, Double)] {
        // Convert MLMultiArray to array of (index, value) tuples
        let values = (0..<multiArray.count).map { (index: $0, value: multiArray[$0].doubleValue) }
        
        // Sort by value in descending order and take top 3
        let top3 = values.sorted { $0.value > $1.value }.prefix(3)
        
        // Map to (label, confidence) tuples
        return top3.map { (classLabels[$0.index], $0.value) }
    }
    
    
}
/*
private func predictFish(image: UIImage?){
    // Resize image, remove buffer
    guard let buffer = image?.resize(size: CGSize(width: 224, height: 224))?
        .getCVPixelBuffer() else{
            return
    }
    
    do{
        let config = MLModelConfiguration()
        let model = try Fish(configuration: config)
        //let input = FishInput(image: buffer)
        
        let output = try model.prediction(image: buffer)
        let array_out = output.Identity
        let classLabels = [
            "Largemouth Bass",
            "Smallmouth Bass",
            "Brook Trout",
            "Rainbow Trout",
            "Striped Bass",
            "Brown Trout",
            "Northern Pike",
            "Pickerel",
            "Croppie",
            "Sunfish",
            "Bluegill",
            "Lake Trout",
            "Sturgeon",
            "Muskie"
        ]
        let top3Predictions = getTop3Predictions(from: array_out, classLabels: classLabels)
        // Create a string from the top 3 predictions
        let predictionText = top3Predictions.enumerated().map { index, prediction in
            let (label, confidence) = prediction
            return "\(index + 1). \(label): \(String(format: "%.2f", confidence * 100))%"
        }.joined(separator: "\n")
        //label.text = predictionText
    }
    catch{
        print(error.localizedDescription)
    }
}

func getTop3Predictions(from multiArray: MLMultiArray, classLabels: [String]) -> [(String, Double)] {
    // Convert MLMultiArray to array of (index, value) tuples
    let values = (0..<multiArray.count).map { (index: $0, value: multiArray[$0].doubleValue) }
    
    // Sort by value in descending order and take top 3
    let top3 = values.sorted { $0.value > $1.value }.prefix(3)
    
    // Map to (label, confidence) tuples
    return top3.map { (classLabels[$0.index], $0.value) }
}
*/

/*
extension UIImage {
    // Convert UIImage to CVPixelBuffer
    func toCVPixelBuffer() -> CVPixelBuffer? {
        let size = CGSize(width: 224, height: 224)
        UIGraphicsBeginImageContext(size)
        guard let cgContext = UIGraphicsGetCurrentContext() else { return nil }
        cgContext.interpolationQuality = .high
        self.draw(in: CGRect(origin: .zero, size: size))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = scaledImage?.cgImage else { return nil }
        
        var pixelBuffer: CVPixelBuffer?
        let options: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: kCFBooleanTrue!,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: kCFBooleanTrue!
        ]
        
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(size.width), Int(size.height), kCVPixelFormatType_32ARGB, options as CFDictionary, &pixelBuffer)
        
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            print("Failed to create pixel buffer")
            return nil
        }
        
        CVPixelBufferLockBaseAddress(buffer, .readOnly)
        let pxData = CVPixelBufferGetBaseAddress(buffer)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapContext = CGContext(data: pxData, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(buffer), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        UIGraphicsPushContext(bitmapContext!)
        bitmapContext!.draw(cgImage, in: CGRect(origin: .zero, size: size))
        UIGraphicsPopContext()
        
        CVPixelBufferUnlockBaseAddress(buffer, .readOnly)
        
        return buffer
    }
}

extension MLMultiArray {
    // Convert MLMultiArray to array of floats (assuming 1D array for simplicity)
    func toArray() -> [Float] {
        guard dataType == .float32 else { return [] }
        return (0..<count).map { self[$0].floatValue }
    }
}
*/

struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    var predictFish: (UIImage) -> Void
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator
        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
                // Call predictFish here
                parent.predictFish(image)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

/**
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
"**/
