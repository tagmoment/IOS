
import Foundation

enum Metrics : UInt{
	case FlashState = 1
	case CameraState = 3
	case TimerState = 4
}

enum ReportingFlashState : Int{
	case Off = 0
	case On = 1
	case Auto = 2
}

enum ReportingCameraState: Int{
	case Back = 0
	case Front = 1
}

enum ReportingTimerState: Int{
	case Off = 0
	case Three = 3
	case Five = 5
}


extension MainViewController
{
	func reportCameraCapture(first: Bool)
	{
		let flashState = ReportingFlashState(rawValue: self.navigationView.currentFlashState.rawValue)!
		let cameraState = self.frontCamSessionView != nil ? ReportingCameraState.Front : ReportingCameraState.Back
		let timerState =  ReportingTimerState(rawValue: self.navigationView.timerStateImages[self.navigationView.currentTimerIndex].1.rawValue)!
		
		
		let tracker = GAI.sharedInstance().defaultTracker
		
		tracker.set(GAIFields.customMetricForIndex(Metrics.FlashState.rawValue), value: "\(flashState.rawValue)")
		tracker.set(GAIFields.customMetricForIndex(Metrics.CameraState.rawValue), value: "\(cameraState.rawValue)")
		tracker.set(GAIFields.customMetricForIndex(Metrics.TimerState.rawValue), value: "\(timerState.rawValue)")

		
		let captureAction = first ? "Capture 1" : "Capture 2"
		GoogleAnalyticsReporter.reportEvent("Capture", action: captureAction, label: nil, value: nil)
	}
}

