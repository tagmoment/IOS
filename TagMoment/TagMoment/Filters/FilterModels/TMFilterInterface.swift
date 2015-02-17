
import Foundation
import CoreImage

protocol TMFilterInterface{
	
	
	var iconName : String { get }
	var filters : [CIFilter] { get }
	
	func applyFilterValue(value : Float)
	
	func supportsChangingValues() -> Bool
	
	func outputImage() -> CIImage!
	
	func inputImage(inputImage : CIImage!)
	
}