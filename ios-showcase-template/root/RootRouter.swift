//
//  RootRouter.swift
//  ios-showcase-template
//
//  Created by Wei Li on 08/11/2017.
//

import AGSAuth
import Foundation
import UIKit

/*
 The router for the root view module. It is responsible to load child modules and attach them to the view.
 It should call the child module's corresponding builder class to build the child module, pass on the dependencies that are required.
 */
protocol RootRouter {
    var appComponents: AppComponents { get }
    var rootViewController: RootViewController { get }

    func launchFromWindow(window: UIWindow)
    func launchHomeView()
    func launchAuthenticationView()
    func launchStorageView()
    func launchDeviceTrustView()
    func launchAccessControlView()
    func launchPushView()
}

class RootRouterImpl: RootRouter {
    let navViewController: UINavigationController
    let rootViewController: RootViewController
    let appComponents: AppComponents

    var homeRouter: HomeRouter?
    var authenticationRouter: AuthenticationRouter?
    var storageRouter: StorageRouter?
    var deviceTrustRouter: DeviceTrustRouter?
    var accessControlRouter: AccessControlRouter?
    var pushRouter: PushRouter?

    init(navViewController: UINavigationController, viewController: RootViewController, appComponents: AppComponents) {
        self.navViewController = navViewController
        self.rootViewController = viewController
        self.appComponents = appComponents
    }

    func launchFromWindow(window: UIWindow) {
        window.rootViewController = self.navViewController
        window.makeKeyAndVisible()
    }

    func launchHomeView() {
        if self.homeRouter == nil {
            self.homeRouter = HomeBuilder().build()
        }
        self.rootViewController.presentViewController(self.homeRouter!.viewController, true)
    }

    func launchAuthenticationView() {
        if self.authenticationRouter == nil {
            self.authenticationRouter = AuthenticationBuilder(appComponents: self.appComponents).build()
        }
        self.rootViewController.presentViewController(self.authenticationRouter!.initialViewController(user: self.resolveCurrentUser()), true)
    }

    // Storage View
    func launchStorageView() {
        if self.storageRouter == nil {
            self.storageRouter = StorageBuilder(appComponents: self.appComponents).build()
        }
        self.rootViewController.presentViewController(self.storageRouter!.viewController, true)
    }

    // Device Trust View
    func launchDeviceTrustView() {
        if self.deviceTrustRouter == nil {
            self.deviceTrustRouter = DeviceTrustBuilder(appComponents: self.appComponents).build()
        }
        self.rootViewController.presentViewController(self.deviceTrustRouter!.viewController, true)
    }

    func launchAccessControlView() {
        let currentUser = self.resolveCurrentUser()
        if currentUser != nil {
            if self.accessControlRouter == nil {
                self.accessControlRouter = AccessControlBuilder(appComponents: self.appComponents).build()
            }
            let acVC = self.accessControlRouter!.viewController
            self.rootViewController.presentViewController(acVC, true)
            acVC.userIdentity = currentUser
        } else {
            launchAuthenticationView()
        }
    }

    func launchPushView() {
        if self.pushRouter == nil {
            self.pushRouter = PushBuilder().build()
        }
        self.rootViewController.presentViewController(self.pushRouter!.viewController, true)
    }

    func resolveCurrentUser() -> User? {
        let authService = self.appComponents.resolveAuthService()
        return try! authService.currentUser()
    }
}
