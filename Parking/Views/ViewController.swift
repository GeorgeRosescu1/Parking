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
    
    @IBOutlet weak var findSpotButton: UIButton!
    @IBOutlet weak var coverView: UIView!
    @IBOutlet weak var busyStateLabel: UILabel!
    @IBOutlet weak var spotStatusLabel: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    var mediaMP3Player: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        serial = BluetoothSerial(delegate: self)
        findSpotButton.layer.cornerRadius = 4
        findSpotButton.layer.shadowOpacity = 0.3
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadView), name: NSNotification.Name(rawValue: "reloadStartViewController"), object: nil)        
    }
    
    
    
    @objc func reloadView() {
        serial.delegate = self
        
        if serial.isReady {
            findSpotButton.isHidden = true
            coverView.isHidden = true
        } else if serial.centralManager.state == .poweredOn {
            findSpotButton.isHidden = false
            coverView.isHidden = false
            spotStatusLabel.isHidden = true
        } else {
            findSpotButton.isHidden = false
            coverView.isHidden = false
            spotStatusLabel.isHidden = true
        }
    }
    
    func serialDidReceiveString(_ message: String) {
        spotStatusLabel.isHidden = false
        if message == "t" {
            let lockSoundPath = Bundle.main.path(forResource: "lock.mp3", ofType: nil)!
            let lockSoundUrl = URL(fileURLWithPath: lockSoundPath)
            
            do {
                self.mediaMP3Player = try AVAudioPlayer(contentsOf: lockSoundUrl)
                self.mediaMP3Player?.play()
            } catch {
                print("Error")
            }
            backgroundImage.image = #imageLiteral(resourceName: "full")
            spotStatusLabel.text = "Busy"
        } else {
            let startSoundPath = Bundle.main.path(forResource: "start.mp3", ofType: nil)!
            let startSoundUrl = URL(fileURLWithPath: startSoundPath)
            
            do {
                self.mediaMP3Player = try AVAudioPlayer(contentsOf: startSoundUrl)
                self.mediaMP3Player?.play()
            } catch {
                print("Error")
            }
            backgroundImage.image = #imageLiteral(resourceName: "empty")
            spotStatusLabel.text = "Empty"
        }
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
