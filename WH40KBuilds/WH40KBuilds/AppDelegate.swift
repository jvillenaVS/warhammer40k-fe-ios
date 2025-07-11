//
//  AppDelegate.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 10/7/25.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseMessaging
import UserNotifications
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print(" =========== AppDelegate ===========")
        FirebaseApp.configure()
        
        if let clientID = FirebaseApp.app()?.options.clientID {
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        } else {
            print("❌ ERROR: Firebase clientID not found.")
        }
        
        UNUserNotificationCenter.current().delegate = self
        
        // Solicitar permiso para notificaciones
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            } else {
                print("Permiso para notificaciones denegado: \(String(describing: error))")
            }
        }
        
        Messaging.messaging().delegate = self
        
        return true
    }
    
    // Registrar token APNs
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    // Manejar error registro APNs
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Error al registrar para notificaciones push: \(error.localizedDescription)")
    }
}

// MARK: - Extensiones para delegados

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // Mostrar notificaciones cuando la app está en primer plano
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler:
                                @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}

extension AppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else { return }
        print("✅ Firebase FCM token: \(fcmToken)")
        
        // Asegúrate que el usuario esté autenticado
        guard let user = Auth.auth().currentUser else {
            print("❌ No user logged in. Cannot save FCM token.")
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.uid)
        
        userRef.setData(["fcmToken": fcmToken], merge: true) { error in
            if let error = error {
                print("❌ Error saving FCM token: \(error.localizedDescription)")
            } else {
                print("✅ FCM token saved for user \(user.uid)")
            }
        }
    }
}
