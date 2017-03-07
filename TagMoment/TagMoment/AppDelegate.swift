
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

	var window: UIWindow?


	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		self.initializeGoogleAnalytics()
		TestFairy.begin("008e0e4a9e585f7bb42687114d30b36e864c2a4b")
		UIApplication.shared.setStatusBarHidden(true, with: UIStatusBarAnimation.fade)
		self.window = UIWindow(frame: UIScreen.main.bounds)
		self.window!.rootViewController = MainViewController(nibName: "MainViewController",bundle: nil)
		
		self.window!.makeKeyAndVisible()
		
		return true
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		SettingsHelper.registerSettingsIfNeeded()
	}
	
	fileprivate func initializeGoogleAnalytics()
	{
		// Configure tracker from GoogleService-Info.plist.
		var configureError:NSError?
		GGLContext.sharedInstance().configureWithError(&configureError)
		assert(configureError == nil, "Error configuring Google services: \(configureError)")
		
		// Optional: configure GAI options.
		let gai = GAI.sharedInstance()
		gai?.trackUncaughtExceptions = true  // report uncaught exceptions
		gai?.logger.logLevel = GAILogLevel.verbose  // remove before app release
	}
}

