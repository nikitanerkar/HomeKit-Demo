//
//  LightBulbInterfaceController.swift
//  HomeKitWatch
//
//  Created by Khaos Tian on 1/3/15.
//  Copyright (c) 2015 Oltica. All rights reserved.
//

import WatchKit
import Foundation
import HomeKit

class LightBulbInterfaceController: WKInterfaceController {

    @IBOutlet weak var powerSwitch: WKInterfaceSwitch!
    @IBOutlet weak var brightnessSlider: WKInterfaceSlider!
    @IBOutlet weak var colorsQuickGroup: WKInterfaceGroup!
    
    var currentService:HMService!
    
    var powerChar: HMCharacteristic!
    var brightnessChar: HMCharacteristic!
    var saturationChar: HMCharacteristic!
    var hueChar: HMCharacteristic!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        
        if let context = context as? HMService {
            self.currentService = context
            
            if let name = self.currentService.accessory.name {
                self.setTitle("\(name) - Light")
            }
            
            for charactertistic in self.currentService.characteristics as [HMCharacteristic] {
                switch charactertistic.characteristicType {
                case HMCharacteristicTypePowerState:
                    self.powerChar = charactertistic
                    powerSwitch.setOn(self.powerChar.value as Bool)
                    powerSwitch.setHidden(false)
                case HMCharacteristicTypeBrightness:
                    self.brightnessChar = charactertistic
                    brightnessSlider.setValue(self.brightnessChar.value as Float)
                    brightnessSlider.setHidden(false)
                case HMCharacteristicTypeSaturation:
                    self.saturationChar = charactertistic
                case HMCharacteristicTypeHue:
                    self.hueChar = charactertistic
                    colorsQuickGroup.setHidden(false)
                default:
                    NSLog("Unhandled Char:\(charactertistic)")
                }
            }
        }
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func didChangePowerState(value: Bool) {
        powerChar.writeValue(value, completionHandler: {
            error in
            if let error = error {
                NSLog("Failed updating power state:\(error)")
            }
        })
    }

    @IBAction func didChangeBrightness(value: Float) {
        brightnessChar.writeValue(value, completionHandler: {
            error in
            if let error = error {
                NSLog("Failed updating brightness state:\(error)")
            }
        })
    }
    
    func updateColor(color: UIColor) {
        var HSBA = [CGFloat](count: 4, repeatedValue: 0.0)
        color.getHue(&HSBA[0], saturation: &HSBA[1], brightness: &HSBA[2], alpha: &HSBA[3])
        
        if let hueChar = self.hueChar {
            let hueValue = NSNumber(integer: Int(Float(HSBA[0]) * hueChar.metadata.maximumValue.floatValue))
            hueChar.writeValue(hueValue, completionHandler:
                {
                    error in
                    if let error = error {
                        NSLog("Failed to update Hue \(error)")
                    }
                }
            )
        }
        
        if let brightChar = self.brightnessChar {
            let brightValue = NSNumber(integer: Int(Float(HSBA[2]) * brightChar.metadata.maximumValue.floatValue))
            brightChar.writeValue(brightValue, completionHandler:
                {
                    error in
                    if let error = error {
                        NSLog("Failed to update Brightness \(error)")
                    }
                }
            )
        }
        
        if let satChar = self.saturationChar {
            let satValue = NSNumber(integer: Int(Float(HSBA[1]) * satChar.metadata.maximumValue.floatValue))
            satChar.writeValue(satValue, completionHandler:
                {
                    error in
                    if let error = error {
                        NSLog("Failed to update Saturation \(error)")
                    }
                }
            )
        }
    }
    
    @IBAction func setLightColorWhite() {
        self.updateColor(UIColor.whiteColor())
    }
    
    @IBAction func setLightColorYellow() {
        self.updateColor(UIColor.yellowColor())
    }
    
    @IBAction func setLightColorBlue() {
        self.updateColor(UIColor.blueColor())
    }
    
}