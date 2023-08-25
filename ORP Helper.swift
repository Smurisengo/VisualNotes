//
//  ORP Helper.swift
//  VisualNotes
//
//  Created by Santiago Murisengo on 11/8/2023.
//

import Vision
import UIKit

class ObjectRecognitionProcessor {
    func recognizeObjects(in image: UIImage, completion: @escaping ([String]?) -> Void) {
        guard let model = try? VNCoreMLModel(for: MobileNet().model),  let cgImage = image.cgImage
        else {
            completion(nil)
            return
        }

        let request = VNCoreMLRequest(model: model) { request, error in
            if let error = error {
                print("Error recognizing objects: \(error)")
                completion(nil)
            } else {
                let results = request.results as? [VNClassificationObservation]
                let recognizedObjects = results?.compactMap { $0.identifier }.prefix(1) // Top 5 objects
                completion(Array(recognizedObjects ?? [])) // Convert the slice to an array
            }
        }

        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try requestHandler.perform([request])
        } catch {
            print("Failed to perform object recognition: \(error)")
            completion(nil)
        }
    }
}
