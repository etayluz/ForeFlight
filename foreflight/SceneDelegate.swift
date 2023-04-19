//
//  SceneDelegate.swift
//  foreflight
//
//  Created by Etay Luz on 4/17/23.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let airportListVC = storyboard.instantiateViewController(withIdentifier: "AirportListVC") as! AirportListVC
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let persistentStoreCoordinator = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.persistentStoreCoordinator

        let coreDataService = CoreDataService()
        coreDataService.context = context
        coreDataService.persistentStoreCoordinator = persistentStoreCoordinator
        
        let fetchReportSerivce = FetchReportService(coreDataService: coreDataService)
        
        airportListVC.coreDataService = coreDataService // inject the service into the view controller
        airportListVC.fetchReportService = fetchReportSerivce // inject the service into the view controller
        
        if let windowScene = scene as? UIWindowScene {
             let window = UIWindow(windowScene: windowScene)
             window.rootViewController = airportListVC // Your RootViewController in here
             // Get reports from Core Data
             
             self.window = window
             window.makeKeyAndVisible()
         }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

