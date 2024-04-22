//
//  Haptic.swift
//  LoadControl
//
//  Created by Trần T. Dũng on 22/4/24.
//

import UIKit

public final class Haptic {
    public static func soft(intensity: CGFloat = 1) {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.prepare()
        generator.impactOccurred(intensity: intensity)
    }
    
    public static func light(intensity: CGFloat = 1) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred(intensity: intensity)
    }
    
    public static func medium(intensity: CGFloat = 1) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred(intensity: intensity)
    }
    
    public static func heavy(intensity: CGFloat = 1) {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred(intensity: intensity)
    }
    
    public static func rigid(intensity: CGFloat = 1) {
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.prepare()
        generator.impactOccurred(intensity: intensity)
    }
}
