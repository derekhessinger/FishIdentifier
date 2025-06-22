import SwiftUI

struct FishTrackingView: View {
    @EnvironmentObject var trackingManager: FishTrackingManager
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.2, green: 0.7, blue: 1.0)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    if trackingManager.caughtFish.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "fish")
                                .font(.system(size: 60))
                                .foregroundColor(.white)
                            
                            Text("No Fish Caught Yet!")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Use the Identify tab to take photos of fish and add them to your collection.")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                        }
                        .padding()
                    } else {
                        List {
                            ForEach(trackingManager.caughtFish) { fish in
                                FishTrackingRow(fish: fish)
                            }
                            .onDelete(perform: trackingManager.removeCaughtFish)
                        }
                        .listStyle(PlainListStyle())
                    }
                }
            }
            .navigationTitle("My Catches")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            print("FishTrackingView appeared with \(trackingManager.caughtFish.count) fish")
        }
    }
}

struct FishTrackingRow: View {
    let fish: CaughtFish
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        HStack(spacing: 12) {
            if let image = fish.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "fish")
                            .foregroundColor(.gray)
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(fish.species)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("\(String(format: "%.1f", fish.confidence * 100))% confidence")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(dateFormatter.string(from: fish.dateCaught))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

struct FishTrackingView_Previews: PreviewProvider {
    static var previews: some View {
        FishTrackingView()
    }
}