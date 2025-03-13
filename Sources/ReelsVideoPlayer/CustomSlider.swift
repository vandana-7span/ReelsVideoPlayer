//
//  CustomSlider.swift
//  ReeScroll
//
//  Created by Vandana Modi on 18/02/25.
//

import SwiftUI
import AVKit

struct CustomSlider: UIViewRepresentable {
    @Binding var value: Float

    func makeUIView(context: Context) -> UISlider {
        let slider = UISlider()
        slider.minimumTrackTintColor = .white
        slider.maximumTrackTintColor = .gray
        
        // Remove the thumb by setting an invisible thumb image
         let transparentThumb = UIImage()
         slider.setThumbImage(transparentThumb, for: .normal)
         slider.setThumbImage(transparentThumb, for: .highlighted)
        
        slider.addTarget(context.coordinator, action: #selector(Coordinator.valueChanged(_:)), for: .valueChanged)
        return slider
    }

    func updateUIView(_ uiView: UISlider, context: Context) {
        uiView.value = value
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: CustomSlider
        init(_ parent: CustomSlider) { self.parent = parent }
        
        @MainActor @objc func valueChanged(_ sender: UISlider) {
            parent.value = sender.value
        }
    }
    
    // Helper function to create a circular thumb image with a given color
       private func createThumbImage(color: UIColor, size: CGSize) -> UIImage {
           let renderer = UIGraphicsImageRenderer(size: size)
           return renderer.image { context in
               let rect = CGRect(origin: .zero, size: size)
               context.cgContext.setFillColor(color.cgColor)
               context.cgContext.fillEllipse(in: rect)
           }
       }
}

// Helper Extension to Resize UIImage
extension UIImage {
    func resized(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
