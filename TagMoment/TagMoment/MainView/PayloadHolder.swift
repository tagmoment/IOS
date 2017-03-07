
import Foundation

class PayloadHolder {
	var canvasImage : UIImage?
	var maskImage : UIImage?
	var maskName : String?
	
	func cacheImage(_ image : UIImage)
	{
		if canvasImage == nil
		{
			canvasImage = image
			return
		}
		
		maskImage = image
	}
}
