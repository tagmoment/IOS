
import Foundation

enum Metrics : UInt{
	case flashState = 1
	case cameraState = 3
	case timerState = 4
}

enum ReportingFlashState : Int{
	case off = 0
	case on = 1
	case auto = 2
}

enum ReportingCameraState: Int{
	case back = 0
	case front = 1
}

enum ReportingTimerState: Int{
	case off = 0
	case three = 3
	case five = 5
}


extension MainViewController
{
	func reportCameraCapture(_ first: Bool)
	{
		let flashState = ReportingFlashState(rawValue: self.navigationView.currentFlashState.rawValue)!
		let cameraState = self.frontCamSessionView != nil ? ReportingCameraState.front : ReportingCameraState.back
		let timerState =  ReportingTimerState(rawValue: self.navigationView.timerStateImages[self.navigationView.currentTimerIndex].1.rawValue)!
		
		
		let tracker = GAI.sharedInstance().defaultTracker
		
		tracker?.set(GAIFields.customMetric(for: Metrics.flashState.rawValue), value: "\(flashState.rawValue)")
		tracker?.set(GAIFields.customMetric(for: Metrics.cameraState.rawValue), value: "\(cameraState.rawValue)")
		tracker?.set(GAIFields.customMetric(for: Metrics.timerState.rawValue), value: "\(timerState.rawValue)")

		
		let captureAction = first ? "Capture 1" : "Capture 2"
		GoogleAnalyticsReporter.reportEvent("Capture", action: captureAction, label: nil, value: nil)
	}
}

