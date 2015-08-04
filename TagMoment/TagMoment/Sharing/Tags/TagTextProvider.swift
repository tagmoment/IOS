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
	static var currentTyping = ""
	
	
	static var emojisContainer = ["\u{e20c}", "\u{e412}", "\u{e106}", "\u{e056}", "\u{e420}", "\u{e022}", "\u{e418}", "\u{e056}", "\u{e403}", "\u{e411}", "\u{e402}", "\u{e404}", "\u{e40d}", "\u{e00e}", "\u{e405}", "\u{e40a}", "\u{e04a}", "\u{e443}", "\u{e112}", "\u{e105}", "\u{e326}", "\u{e058}", "\u{e40e}", "\u{e214}", "\u{e449}", "\u{e034}", "\u{e10e}"]

	
	static var TagsDataSourceWords = ["love", "me", "cute", "photooftheday","happy","beautiful", "selfie", "girl", "picoftheday",
		"smile","friends","fun","fashion","summer","food","amazing","swag","style","family","life","lol","pretty","sun","art","cool","funny","music"]/*,"eyes","night","beach","sky"]*/
	
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
		let isInputSavedWord = contains(self.TagsDataSourceWords, input)
		if currentString.isEmpty
		{
			self.currentEmoji = isInputEmoji ? input : self.currentEmoji
			self.currentWord = isInputSavedWord ? input : self.currentWord
			return input
		}
		
		
		
		if !hasWord && !hasEmoji
		{
			return currentString + input
		}
		
		
		if (hasWord && isInputSavedWord)
		{
			let oldVal = self.currentWord
			self.currentWord = input
			if (oldVal.isEmpty) //We have an emoji
			{
				if self.currentTyping.isEmpty
				{
					return hasEmoji ? currentString + " " + input : input
				}
				else
				{
					let oldTypingVal = self.currentTyping
					self.currentTyping = ""
					return currentString.stringByReplacingOccurrencesOfString(oldTypingVal, withString: input)
				}
				
			}
			
			return currentString.stringByReplacingOccurrencesOfString(oldVal, withString: input)
		}
		
		if (!isInputSavedWord && !isInputEmoji)
		{
			if self.currentWord.isEmpty
			{
				if let range = currentString.rangeOfString(self.currentEmoji)
				{
					if (distance(currentString.startIndex, range.startIndex) != 0)
					{
						self.currentTyping += input
						return self.currentTyping + " " + self.currentEmoji
					}
					else
					{
						self.currentTyping += input
						return self.currentEmoji  + " " + self.currentTyping
					}
				}
					
				return currentString + input
			}
			
			return currentString.stringByReplacingOccurrencesOfString(self.currentWord, withString: input)
		}
		
		if (hasEmoji && isInputEmoji)
		{
			let oldVal = self.currentEmoji
			self.currentEmoji = input
			if (oldVal.isEmpty) //We have an emoji
			{
				return currentString + " " + input
			}
			
			return currentString.stringByReplacingOccurrencesOfString(oldVal, withString: input)
		}
		
		return "rule miss"
		
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