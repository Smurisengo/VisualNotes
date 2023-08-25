import Vision
import UIKit

class OCRProcessor {
    func processImage(_ image: UIImage?, completion: @escaping (String?) -> Void) {
        guard var uiImage = image else {
            completion(nil)
            return
        }

        // Perform image preprocessing (brightness and contrast adjustments)
        uiImage = adjustBrightnessAndContrast(for: uiImage)

        guard let cgImage = uiImage.cgImage else {
            completion(nil)
            return
        }

        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                print("OCR Error: \(error)")
                completion(nil)
            } else {
                let observations = request.results as? [VNRecognizedTextObservation]
                let recognizedText = observations?.compactMap { $0.topCandidates(1).first?.string }.joined(separator: " ")
                completion(recognizedText)
            }
        }

        do {
            try requestHandler.perform([request])
        } catch {
            print("Failed to perform OCR: \(error)")
            completion(nil)
        }
    }

    // Helper function to adjust brightness and contrast of the image
    private func adjustBrightnessAndContrast(for image: UIImage) -> UIImage {
        // You can experiment with different values for brightness and contrast adjustments
        let brightness: CGFloat = 0.1
        let contrast: CGFloat = 1.2

        let context = CIContext(options: nil)
        let filter = CIFilter(name: "CIColorControls")!
        filter.setValue(CIImage(image: image), forKey: kCIInputImageKey)
        filter.setValue(brightness, forKey: kCIInputBrightnessKey)
        filter.setValue(contrast, forKey: kCIInputContrastKey)

        if let outputImage = filter.outputImage,
           let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            return UIImage(cgImage: cgImage)
        } else {
            return image
        }
    }
}
