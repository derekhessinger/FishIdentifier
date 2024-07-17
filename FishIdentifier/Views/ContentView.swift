import SwiftUI
import AVFoundation
import UIKit

struct ContentView: View {
    @State private var showImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var selectedImage: UIImage?
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        ZStack {
            Color(red: 0.2, green: 0.7, blue: 1.0)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Text("FishIdentifier")
                    .font(.system(size: 36, weight: .bold, design: .default))
                    .italic()
                    .padding()

                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
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
                    selectedImage=nil
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
            ImagePicker(sourceType: self.sourceType, selectedImage: self.$selectedImage)
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
}

struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) private var presentationMode

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
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
