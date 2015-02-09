
import Foundation
import CoreImage

protocol TMFilterInterface{
	
	
	var iconName : String { get }
	var filter : CIFilter { get }
	
	func applyFilterValue(value : Float)
	
	func supportsChangingValues() -> Bool
}