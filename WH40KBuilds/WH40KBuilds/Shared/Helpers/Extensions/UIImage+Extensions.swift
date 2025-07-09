//
//  UIImage+Extensions.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 9/7/25.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit

extension UIImage {
    func applyBlur(radius: CGFloat) -> UIImage? {
        let context = CIContext()
        let ciInput = CIImage(image: self)

        let filter = CIFilter.gaussianBlur()
        filter.inputImage = ciInput
        filter.radius = Float(radius)

        guard
            let output = filter.outputImage?.cropped(to: ciInput!.extent),
            let cgImage = context.createCGImage(output, from: output.extent)
        else { return nil }

        return UIImage(cgImage: cgImage,
                       scale: scale,
                       orientation: imageOrientation)
    }
}
