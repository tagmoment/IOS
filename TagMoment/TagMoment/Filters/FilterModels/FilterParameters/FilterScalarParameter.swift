
import Foundation

class FilterScalarParameter : FilterParameterProtocol
{
	var key : String
	let minValue : Float?
	let maxValue : Float?
	
	init(minValue: Float?, maxValue: Float?, key : String)
	{
		self.minValue = minValue
		self.maxValue = maxValue
		self.key = key
	}
	
	func normalizedValueFromPercent(percent : Float) -> AnyObject
	{
		if let min = minValue{
			if let max = maxValue
			{
				let range = max	- min
				let value = percent*range
				return value+min
			}
		}
		
		return 0
	}
}