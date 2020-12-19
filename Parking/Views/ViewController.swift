//
//  ViewController.swift
//  Parking
//
//  Created by George Rosescu on 23.11.2020.
//

import UIKit
import AVFoundation
import CoreBluetooth

class ViewController: UIViewController, BluetoothSerialDelegate {
    
    @IBOutlet weak var busyStateLabel: UILabel!
    @IBOutlet weak var emptyStateLabel: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    var image = 0
    var emptyLabelOriginalCoord = CGPoint()
    var busyLabelOriginalCoord = CGPoint()
    
    var mediaMP3Player: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        serial = BluetoothSerial(delegate: self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadView), name: NSNotification.Name(rawValue: "reloadStartViewController"), object: nil)
        
        emptyLabelOriginalCoord = emptyStateLabel.frame.origin
        busyLabelOriginalCoord = busyStateLabel.frame.origin
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let lockSoundPath = Bundle.main.path(forResource: "lock.mp3", ofType: nil)!
        let lockSoundUrl = URL(fileURLWithPath: lockSoundPath)
        
        let startSoundPath = Bundle.main.path(forResource: "start.mp3", ofType: nil)!
        let startSoundUrl = URL(fileURLWithPath: startSoundPath)
        
        let _ = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { (_) in
            if self.image % 2 != 0 {
                do {
                    self.mediaMP3Player = try AVAudioPlayer(contentsOf: lockSoundUrl)
                    self.mediaMP3Player?.play()
                } catch {
                    print("Error")
                }
                let image = #imageLiteral(resourceName: "full")
                self.basicAnimationWithImage(image, toShowLabel: self.busyStateLabel, toHideLabel: self.emptyStateLabel)
            } else {
                do {
                    self.mediaMP3Player = try AVAudioPlayer(contentsOf: startSoundUrl)
                    self.mediaMP3Player?.play()
                } catch {
                    print("Error")
                }
                let image = #imageLiteral(resourceName: "empty")
                self.basicAnimationWithImage(image, toShowLabel: self.emptyStateLabel, toHideLabel: self.busyStateLabel)
            }
            self.image += 1
        }
    }
    
    func basicAnimationWithImage(_ image: UIImage, toShowLabel: UILabel, toHideLabel: UILabel) {
        UIView.animate(withDuration: 0.7) {
            self.backgroundImage.image = image
            toHideLabel.frame.origin = CGPoint(x: toShowLabel.frame.origin.x, y: toShowLabel.frame.origin.y)
        } completion: { (true) in
            UIView.animate(withDuration: 0.3) {
                toShowLabel.isHidden = false
                toHideLabel.isHidden = true
                toHideLabel.frame.origin = toHideLabel === self.emptyStateLabel ? self.emptyLabelOriginalCoord : self.busyLabelOriginalCoord
                self.mediaMP3Player?.stop()
            }
        }
    }
    
    @objc func reloadView() {
        // in case we're the visible view again
        serial.delegate = self
        
        if serial.isReady {
           print("Ready")
            print(serial.connectedPeripheral)
        } else if serial.centralManager.state == .poweredOn {
            print("not")
        } else {
           print("a")
        }
    }
    
    func serialDidReceiveString(_ message: String) {
        print(message)
    }
    
    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud?.mode = MBProgressHUDMode.text
        hud?.labelText = "Disconnected"
        hud?.hide(true, afterDelay: 1.0)
    }
    
    func serialDidChangeState() {
        if serial.centralManager.state != .poweredOn {
            let hud = MBProgressHUD.showAdded(to: view, animated: true)
            hud?.mode = MBProgressHUDMode.text
            hud?.labelText = "Bluetooth turned off"
            hud?.hide(true, afterDelay: 1.0)
        }
        
    }
}
