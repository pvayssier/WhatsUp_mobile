//
//  UIWindow+Motion.swift
//
//
//  Created by Paul VAYSSIER on 15/04/2024.
//

import SwiftUI

public extension NSNotification.Name {
    static let deviceDidShakeNotification = NSNotification.Name("MyDeviceDidShakeNotification")
}

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        NotificationCenter.default.post(name: .deviceDidShakeNotification, object: event)
    }
}
