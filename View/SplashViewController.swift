//
//  ViewController.swift
//
//
//  Created by Tolga Polat on 15.07.2023.
//

import UIKit
import Alamofire
import FirebaseRemoteConfig

class ViewController: UIViewController {
    let remoteConfig = RemoteConfig.remoteConfig()
    let backgroundImage = UIImage(named: "movie")
    
    //- MARK: LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchRemoteConfig()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkInternetConnection()
    }
    
    //- MARK: FUNCS
    
    func setupUI() {
        let fullScreenView = UIView(frame: view.bounds)
        fullScreenView.backgroundColor = .blue
        view.addSubview(fullScreenView)
       
        let backgroundImageView = UIImageView(frame: fullScreenView.bounds)
        backgroundImageView.image = backgroundImage
        backgroundImageView.contentMode = .scaleAspectFill
        fullScreenView.addSubview(backgroundImageView)
        
        let label = UILabel(frame: CGRect(x: 0, y: view.bounds.height/8, width: view.bounds.width, height: 50))
        label.backgroundColor = .white
        label.font = UIFont.systemFont(ofSize: 24)
        label.textAlignment = .center
        label.textColor = .black
        fullScreenView.addSubview(label)

        if let configValue = remoteConfig["loading_text"].stringValue, !configValue.isEmpty {
            label.text = configValue
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                self?.navigateToHomePage()
            }
        } else {
            label.text = "Ana Görünüm"
        }
    }
    
    func checkInternetConnection() {
        AF.request("https://www.apple.com").response { response in
            if let error = response.error {
                self.showAlert(title: "UYARI", message: "İNTERNET YOK")
                print("İnternet bağlantısı yok: \(error)")
            } else {
                // self.showAlert(title: "Uyarı", message: "İnternet var")
                print("İnternet bağlantısı mevcut")
            }
        }
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Tamam", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func fetchRemoteConfig() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        
        remoteConfig.fetch(withExpirationDuration: 0) { [weak self] (status, error) in
            if status == .success, error == nil {
                self?.remoteConfig.activate()
                self?.setupUI()
            } else {
                print("Remote Config fetch failed: \(error?.localizedDescription ?? "")")
            }
        }
    }
    
    func navigateToHomePage() {
        let homePageVC = HomePageViewController()
        homePageVC.modalPresentationStyle = .fullScreen
        
        let transition = CustomTransitionAnimator()
        homePageVC.transitioningDelegate = self
        present(homePageVC, animated: true, completion: nil)
    }
}

extension ViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomTransitionAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
}



