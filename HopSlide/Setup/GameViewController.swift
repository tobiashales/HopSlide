//
//  GameViewController.swift
//  HopSlide
//
//  Created by Tobias Hales on 4/7/18.
//  Copyright © 2024 TobiasHales. All rights reserved.

// Updated by Tobias Hales on 8/21/24
//


import UIKit
import SpriteKit
import GameplayKit
import Firebase
import AVFoundation
import GoogleMobileAds
import UserNotifications
import GameKit


let defaults = UserDefaults.standard

class GameViewController: UIViewController, GADFullScreenContentDelegate {

    struct tempBestScore {
        static var temporaryBestScore = 0
    }
    
    //Create Interstitial Ad Variable
    var interstitial: GADInterstitialAd!
    
    //Connect banner size in storyboard to swift file
    @IBOutlet weak var BannerView: GADBannerView!
   
    override func viewDidLoad() {

        //Create and load interstitial ad
        createAndLoadInterstitial()

        //Run Load Ads Function
        loadAds()
        
       
        

        //----------------------------------------------When view loads------------------------------------
        super.viewDidLoad()
        
        //Run Functions
        createScene()
        authenticateLocalPlayer()
       
       
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func createScene() {
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "MenuScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            
            
            //-------------------------------------------View Preferences----------------------------------------------
            view.preferredFramesPerSecond = 120
            view.ignoresSiblingOrder = false
            view.showsFPS = false
            view.showsNodeCount = false
        }
    }
    
    
    func createAndLoadInterstitial() {
            let request = GADRequest()
            GADInterstitialAd.load(withAdUnitID: "ca-app-pub-2060667001343293/6350801146", request: request) { [weak self] (ad, error) in
                if let error = error {
                    print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                    return
                }
                self?.interstitial = ad
                self?.interstitial?.fullScreenContentDelegate = self // Set the delegate
            }
        }

    @objc func presentInterstitial() {
        if let ad = interstitial {
            ad.present(fromRootViewController: self)
            createAndLoadInterstitial() // Optionally reload the interstitial after presenting
        } else {
            print("Ad wasn't ready")
        }
    }
    
    
    //Load Banner Ads
    func loadAds() {
        //Load ads
        BannerView.adUnitID = "ca-app-pub-2060667001343293/5946529974"
        BannerView.rootViewController = self
        BannerView.load(GADRequest())
    }
    
    
    
    @objc func authenticateLocalPlayer() {
        let localPlayer = GKLocalPlayer.local
        localPlayer.authenticateHandler = { (viewController, error) in
            if let vc = viewController {
                // Present the view controller so the player can log in
                self.present(vc, animated: true, completion: nil)
            } else if error != nil {
                print("Error occurred during authentication: \(error!.localizedDescription)")
            } else {
                print("Player is either already authenticated or not able to authenticate.")
            }
        }
    }


    
    
    
    
}
