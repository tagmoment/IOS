
import Foundation
import CoreImage

protocol TMFilterInterface{
	
	
	var iconName : String { get }
	var filters : [CIFilter] { get }
	
	func applyFilterValue(_ value : Float)
	
	func supportsChangingValues() -> Bool
	
	func outputImage() -> CIImage!
	
	func inputImage(_ inputImage : CIImage!)
	
}
