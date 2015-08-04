//
//  TagTextProvider.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 7/27/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import Foundation

class TagTextProvider {
	static var currentEmojiStringIndex = 0
	static var currentWordStringIndex = 0
	
	static var currentWord = ""
	static var currentEmoji = ""
	
	static var emojisContainer = ["\u{e20c}", "\u{e412}", "\u{e106}", "\u{e056}", "\u{e420}", "\u{e022}", "\u{e418}", "\u{e056}", "\u{e403}", "\u{e411}", "\u{e402}", "\u{e404}"]
	
	
	class func removeSpaces(inputString : String) -> String
	{
		return inputString.stringByReplacingOccurrencesOfString(" ", withString: "")
	}
	
	class func addHashTagIfNeeded(inputString : String) -> String
	{
		if ((inputString.rangeOfString("#")) != nil || inputString.isEmpty)
		{
			return inputString
		}
		
		return "#" + inputString
	}
	
	class func addAllHashtags(inputString : String) -> String
	{
		var resultString = ""

		let words = inputString.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
		for word in words
		{
			resultString += resultString.isEmpty ? addHashTagIfNeeded(word) : " " + addHashTagIfNeeded(word)
		}
		
		return resultString
	}
	
	class func addTextByRules(input : String,currentString : String,  hasEmoji : Bool, hasWord : Bool) -> String
	{
		let isInputEmoji = contains(self.emojisContainer, input)
		if currentString.isEmpty
		{
			self.currentEmoji = isInputEmoji ? input : self.currentEmoji
			self.currentWord = !isInputEmoji ? input : self.currentWord
			return input
		}
		
		if !hasWord && !hasEmoji
		{
			return input
		}
		
		
		
		if (hasWord && !isInputEmoji)
		{
			let oldVal = self.currentWord
			self.currentWord = input
			if (oldVal.isEmpty) //We have an emoji
			{
				return currentString + " " + input
			}
			
			return currentString.stringByReplacingOccurrencesOfString(oldVal, withString: input)
		}
		
		if (hasEmoji && isInputEmoji)
		{
			let oldVal = self.currentEmoji
			self.currentEmoji = input
			if (oldVal.isEmpty) //We have an emoji
			{
				return currentString + " " + input
			}
			self.currentEmoji = input
			return currentString.stringByReplacingOccurrencesOfString(oldVal, withString: input)
		}
		
		let indexToReplace = isInputEmoji ? self.currentEmojiStringIndex : self.currentWordStringIndex
		let stringToReplace = isInputEmoji ? self.currentEmoji : self.currentWord
		
		return currentString.stringByReplacingOccurrencesOfString(stringToReplace, withString: input)
		
	}
	
	class func fixEmojiSpaceIfNeeded(newString: String, currentString: String) -> String
	{
		
		
		var resultString = ""
		var foundEmoji = false
		let words = currentString.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
		
		for word in words
		{
			
			if (contains(self.emojisContainer, word))
			{
				foundEmoji = true
			}
			
			resultString += word
		}
		
		if (foundEmoji)
		{
			return contains(self.emojisContainer, newString) ? resultString : resultString + " " + newString
		}
		
		if (!contains(self.emojisContainer, newString) || currentString.isEmpty)
		{
			return newString
		}
		
		
		return resultString + " " + newString
		
	}
	
	
}