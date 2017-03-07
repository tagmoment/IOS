
import Foundation
import CoreImage

class FilterImageParameter : FilterParameterProtocol
{
	var key : String
	
	init(key : String)
	{
		self.key = key
	}
	
	func normalizedValueFromPercent(_ percent : Float) -> AnyObject
	{
		return CIColor(red: CGFloat(percent), green:  CGFloat(percent), blue:  CGFloat(percent), alpha: 1.0)
	}
}
