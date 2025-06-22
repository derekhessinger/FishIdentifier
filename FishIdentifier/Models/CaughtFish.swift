import Foundation
import UIKit

struct CaughtFish: Identifiable, Codable {
    let id = UUID()
    let species: String
    let confidence: Double
    let dateCaught: Date
    let imageFileName: String?
    
    init(species: String, confidence: Double, imageFileName: String? = nil) {
        self.species = species
        self.confidence = confidence
        self.dateCaught = Date()
        self.imageFileName = imageFileName
    }
    
    var image: UIImage? {
        guard let imageFileName = imageFileName else { return nil }
        return FishTrackingManager.loadImage(fileName: imageFileName)
    }
}

class FishTrackingManager: ObservableObject {
    static let shared = FishTrackingManager()
    
    @Published var caughtFish: [CaughtFish] = []
    private let userDefaults = UserDefaults.standard
    private let caughtFishKey = "CaughtFishKey"
    
    private init() {
        print("FishTrackingManager singleton init() called")
        loadCaughtFish()
    }
    
    func addCaughtFish(species: String, confidence: Double, image: UIImage?) {
        print("Adding fish: \(species)")
        let fileName: String?
        if let image = image {
            let newFileName = "\(UUID().uuidString).jpg"
            FishTrackingManager.saveImage(image, fileName: newFileName)
            fileName = newFileName
            print("Saved image with filename: \(newFileName)")
        } else {
            fileName = nil
        }
        
        let fish = CaughtFish(species: species, confidence: confidence, imageFileName: fileName)
        
        DispatchQueue.main.async {
            print("Before adding: \(self.caughtFish.count) fish")
            self.caughtFish.insert(fish, at: 0) // Add to beginning for most recent first
            print("After adding: \(self.caughtFish.count) fish")
            self.saveCaughtFish()
        }
    }
    
    func removeCaughtFish(at indexSet: IndexSet) {
        // Delete associated image files
        for index in indexSet {
            if let fileName = caughtFish[index].imageFileName {
                FishTrackingManager.deleteImage(fileName: fileName)
            }
        }
        caughtFish.remove(atOffsets: indexSet)
        saveCaughtFish()
    }
    
    private func saveCaughtFish() {
        if let encoded = try? JSONEncoder().encode(caughtFish) {
            userDefaults.set(encoded, forKey: caughtFishKey)
            userDefaults.synchronize()
            print("Saved \(caughtFish.count) fish to UserDefaults")
        }
    }
    
    private func loadCaughtFish() {
        if let data = userDefaults.data(forKey: caughtFishKey),
           let decoded = try? JSONDecoder().decode([CaughtFish].self, from: data) {
            caughtFish = decoded
            print("Loaded \(caughtFish.count) fish from UserDefaults")
        } else {
            print("No fish data found in UserDefaults")
        }
    }
    
    // MARK: - Static Image Storage Methods
    
    static func saveImage(_ image: UIImage, fileName: String) {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else { return }
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fishImagesPath = documentsPath.appendingPathComponent("FishImages")
        
        // Create directory if it doesn't exist
        try? FileManager.default.createDirectory(at: fishImagesPath, withIntermediateDirectories: true, attributes: nil)
        
        let filePath = fishImagesPath.appendingPathComponent(fileName)
        try? imageData.write(to: filePath)
    }
    
    static func loadImage(fileName: String) -> UIImage? {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fishImagesPath = documentsPath.appendingPathComponent("FishImages")
        let filePath = fishImagesPath.appendingPathComponent(fileName)
        
        guard let imageData = try? Data(contentsOf: filePath) else { return nil }
        return UIImage(data: imageData)
    }
    
    static func deleteImage(fileName: String) {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fishImagesPath = documentsPath.appendingPathComponent("FishImages")
        let filePath = fishImagesPath.appendingPathComponent(fileName)
        
        try? FileManager.default.removeItem(at: filePath)
    }
}
