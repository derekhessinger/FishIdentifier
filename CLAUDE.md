# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

FishIdentifier is an iOS application that uses machine learning to identify fish species from photos. The app is built entirely in Swift using SwiftUI and integrates TensorFlow Lite for on-device ML inference.

## Architecture

### Core Components

**App Structure:**
- `FishIdentifierApp.swift` - Main app entry point that sets up the tab-based interface
- `MainTabView.swift` - Tab container with two main sections: "Identify" and "My Catches"

**Machine Learning Pipeline:**
- Uses a custom CoreML model (`Fish.mlmodel`) trained on MobileNetV3Large architecture
- Model achieves ~75% accuracy and classifies 14 North American fish species
- Input: 224x224 RGB images processed through CVPixelBuffer
- Output: MLMultiArray with confidence scores for each species

**Data Flow:**
1. User captures/selects image → `ImagePicker` → `ContentView.predictFish()`
2. Image resized to 224x224 → converted to CVPixelBuffer → passed to CoreML model
3. Model returns confidence scores → top 3 predictions displayed
4. User can save catch → `FishTrackingManager` → persistent storage

**Views:**
- `ContentView.swift` - Main fish identification interface with camera/photo selection
- `FishTrackingView.swift` - Lists saved fish catches with images and metadata
- `ImagePickerView.swift` - UIKit wrapper for camera and photo library access

**Models:**
- `CaughtFish.swift` - Data model for saved fish catches with persistent storage
- `FishTrackingManager.swift` - Singleton managing fish data persistence using UserDefaults + file system for images

### Key Architectural Patterns

**Persistence Strategy:**
- Fish metadata stored in UserDefaults as JSON
- Images saved to Documents/FishImages/ directory with UUID filenames
- Manual cleanup when fish records are deleted

**State Management:**
- Uses `@EnvironmentObject` for sharing `FishTrackingManager` across views
- `@Published` properties for reactive UI updates

## Common Development Commands

### Building and Running
```bash
# Open workspace (required for CocoaPods)
open FishIdentifier.xcworkspace

# Install/update dependencies
pod install
```

### Testing
```bash
# Run from Xcode - no CLI test commands configured
# Unit tests: FishIdentifierTests/
# UI tests: FishIdentifierUITests/
```

### Dependencies
- **TensorFlowLiteSwift** - ML model inference (via CocoaPods)
- **CoreML/Vision** - Apple's ML frameworks for model integration
- **AVFoundation** - Camera access and permissions

### Model Integration Notes
- CoreML model located at `FishIdentifier/Models/Fish.mlpackage/`
- Model expects 224x224 RGB input via CVPixelBuffer
- Class labels are hardcoded in `ContentView.swift:250-265`
- Image preprocessing handled by `Extensions.swift` UIImage extensions

### File Structure
```
FishIdentifier/
├── Models/           # CoreML model files
├── Views/           # SwiftUI view components  
├── Utilities/       # Extensions and helpers
├── Resources/       # Assets, screenshots
└── FishIdentifierApp.swift
```

### Data Collection Setup
- `data/` contains training images organized by species
- `model.ipynb` - Jupyter notebook for model training
- `data_collection.ipynb` - Data collection from iNaturalist API
- `image_scrape.py` - Image scraping utilities