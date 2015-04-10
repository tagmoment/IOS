
import Foundation
import CoreImage

class TMFilterBase{
	var iconName : String
	var filtersProtected : [CIFilter] {
		get{
			return []
		}
	}
	lazy var filters : [CIFilter] = self.filtersProtected
	lazy var parameters : [String : [FilterParameterProtocol]] = {
		var tempParams = [String : [FilterParameterProtocol]]()
		self.createFilterParameters(&tempParams)
		return tempParams;
	}()
	
	lazy var constantParams : [String : [FilterParameterProtocol]] =
	{
		var tempParams = [String : [FilterParameterProtocol]]()
		self.createConstantFilterParameters(&tempParams)
		return tempParams;

	}()
	
	
	init()
	{
		iconName = ""
	}
	

	func applyFilterValue(value : Float)
	{
		for filter in filters
		{
			
			let name = filter.name()
			
			
			let params = self.parameters[name]
			let defaultParams = self.constantParams[name];
			
			if let myDefaultParams = defaultParams
			{
				
				for myDefaultParam in myDefaultParams
				{
					filter.setValue(myDefaultParam.normalizedValueFromPercent(value), forKey: myDefaultParam.key)
				}
				continue
			}
			
			if let myParams = params
			{
				for parameter in myParams
				{
					filter.setValue(parameter.normalizedValueFromPercent(value), forKey: parameter.key)
				}
			}
		}
	}
	
	func supportsChangingValues() -> Bool
	{
		return true
	}
	
	func outputImage() -> CIImage!
	{
		if (filters.count == 0)
		{
			return nil
		}
		
		for i in 1..<filters.count
		{
			self.filters[i].setValue(self.filters[i-1].outputImage!, forKey: kCIInputImageKey)
		}
		
		return self.filters[filters.count - 1].outputImage
	}
	
	func createFilterParameters(inout outParams : [String : [FilterParameterProtocol]])
	{
		for filter in filters
		{
			println("working on filter " + filter.name());
			var inputNames = (filter.inputKeys() as [String]).filter { (parameterName) -> Bool in
				return (parameterName as String) != "inputImage"
			}
			
			let attributes = filter.attributes()!
			
			let filterParams = inputNames.map { (inputName: String) -> FilterParameterProtocol in
				let attribute = attributes[inputName] as [String : AnyObject]
				// strip "input" from the start of the parameter name to make it more presentation-friendly
				println("working on attribue " + inputName);
				println("attribute \(attribute)" )
				let classType = attribute[kCIAttributeClass] as String
				if (classType == "CIColor")
				{
					return FilterImageParameter(key: inputName)
				}
				if (classType == "CIVector")
				{
					return FilterVectorParameter(key: inputName)
				}
				else
				{
					let minValue = attribute[kCIAttributeSliderMin] as Float
					let maxValue = attribute[kCIAttributeSliderMax] as Float
//					let defaultValue = attribute[kCIAttributeDefault] as Float
				
					return FilterScalarParameter(minValue: minValue, maxValue: maxValue, key: inputName)
				}
			}
			
			outParams.updateValue(filterParams, forKey: filter.name())
		}
	}
	
	func createConstantFilterParameters(inout outParams : [String : [FilterParameterProtocol]])
	{
	}
	
	func inputImage(inputImage : CIImage!)
	{
		if (self.filters.count != 0)
		{
			self.filters[0].setValue(inputImage, forKey: kCIInputImageKey)
		}
		
	}
}

