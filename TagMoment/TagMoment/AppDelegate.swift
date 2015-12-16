
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

	var window: UIWindow?


	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		
		TestFairy.begin("008e0e4a9e585f7bb42687114d30b36e864c2a4b")
		UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Fade)
		self.window = UIWindow(frame: UIScreen .mainScreen().bounds)
		self.window!.rootViewController = MainViewController(nibName: "MainViewController",bundle: nil)
		
		self.window!.makeKeyAndVisible()
		
		return true
	}

	func applicationDidBecomeActive(application: UIApplication) {
		SettingsHelper.registerSettingsIfNeeded()
	}

	

}

