import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func sceneDidEnterBackground(_ scene: UIScene) {
        let defaults = UserDefaults.standard
        let highScore = defaults.integer(forKey: "highscore")

        if GameViewController.tempBestScore.temporaryBestScore >= highScore {
            defaults.set(GameViewController.tempBestScore.temporaryBestScore, forKey: "highscore")
        }

        if musicPlayer.paused {
            defaults.set(true, forKey: "musicIsPaused")
        }
    }
}
