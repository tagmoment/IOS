//
//  TagTextProvider.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 7/27/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import Foundation

class TagTextProvider {
	static var currentEmojiStringIndex = NSNotFound
	static var currentWordStringIndex = NSNotFound
	static var currentTypingStringIndex = NSNotFound
	
	static var currentWord : String? = nil
	static var currentEmoji : String? = nil
	static var currentTyping : String? = nil
	static var currentString : String? = nil
	
	
	static var emojisContainer = ["\u{e20c}", "\u{e412}", "\u{e106}", "\u{e056}", "\u{e420}", "\u{e022}", "\u{e418}", "\u{e056}", "\u{e403}", "\u{e411}", "\u{e402}", "\u{e404}", "\u{e40d}", "\u{e00e}", "\u{e405}", "\u{e40a}", "\u{e04a}", "\u{e443}", "\u{e112}", "\u{e105}", "\u{e326}", "\u{e058}", "\u{e40e}", "\u{e214}", "\u{e449}", "\u{e034}", "\u{e10e}",
		"\u{e425}", "\u{e415}", "\u{e41f}", "\u{e42a}", "\u{e42b}", "\u{e015}" , "\u{e018}", "\u{e31c}", "\u{e013}", "\u{e312}",
		"\u{e11d}", "\u{e048}", ] /*"\u{e057}"]*/

	
	static var TagsDataSourceWords = ["love", "menow", "cute", "photooftheday","happy","beautiful", "selfie", "girl", "picoftheday", "smile"," friends", "fun","fashion", "summer","food","amazing", "swag","style","family","life","lol", "pretty","sun","art","cool","funny","music","eyes","night", "beach","sky", "nice", "home", "lovit", "i", "dog", "tattoo", "good", "best"]
	
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
	
	class func addTextByRules(string : String) -> String
	{
		let input = removeSpaces(string)
		let isInputEmoji = contains(self.emojisContainer, input)
		let isInputSavedWord = contains(self.TagsDataSourceWords, input)
		
		if currentString == nil
		{
			self.currentEmoji = isInputEmoji ? input : self.currentEmoji
			currentEmojiStringIndex = isInputEmoji ? 0 : currentEmojiStringIndex
			
			self.currentWord = isInputSavedWord ? input : self.currentWord
			currentWordStringIndex = isInputSavedWord ? 0 : currentWordStringIndex
			
			self.currentTyping = !isInputEmoji && !isInputSavedWord ? input : self.currentTyping
			currentTypingStringIndex = !isInputEmoji && !isInputSavedWord ? 0 : self.currentTypingStringIndex
			currentString = input
			return currentString!
		}
		
		if (isInputEmoji)
		{
			if (self.currentEmoji != nil)
			{
				currentString = currentString?.stringByReplacingOccurrencesOfString(self.currentEmoji!, withString: input)
				currentEmoji = input
				return currentString!
			}
			
			currentEmoji = input
			currentString = currentString! + " " + currentEmoji!
			return currentString!
		}
		
		if (isInputSavedWord)
		{
			if (self.currentTyping != nil)
			{
				self.currentString = currentString?.stringByReplacingOccurrencesOfString(self.currentTyping!, withString: input)
				self.currentWord = input
				self.currentTyping = nil
				return self.currentString!
			}
			
			if (self.currentWord != nil)
			{
				self.currentString = currentString?.stringByReplacingOccurrencesOfString(self.currentWord!, withString: input)
				self.currentWord = input
				return self.currentString!
			}
			
			
			self.currentWord = input
			self.currentString = self.currentString! + " " + self.currentWord!
			return self.currentString!
		}
		
		if (!isInputEmoji && !isInputSavedWord)
		{
			if (self.currentWord != nil)
			{
				self.currentString = currentString?.stringByReplacingOccurrencesOfString(self.currentWord!, withString: input)
				self.currentTyping = input
				self.currentWord = nil
				return self.currentString!
			}
			
			if (self.currentTyping != nil)
			{
				let temp = self.currentTyping! + input
				self.currentString = currentString?.stringByReplacingOccurrencesOfString(self.currentTyping!, withString: temp)
				self.currentTyping = temp
				
				return self.currentString!
			}
			
			self.currentTyping = input
			self.currentString = self.currentString! + " " + self.currentTyping!
			return self.currentString!
		}
		
		return "PB"
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
	
	class func handleDeletion()
	{
		if (self.isCurrentCharSetSecondWord(currentWord))
		{
			if let word = currentWord
			{
				currentWord = nil
				if (count(word) == 1)
				{
					
					currentTyping = nil
					return;
				}
				
				currentTyping = word.substringToIndex(advance(word.startIndex, count(word) - 1));
				return;
			}
		}
		
		if (self.isCurrentCharSetSecondWord(currentTyping))
		{
			
			if let typing = currentTyping
			{
				if (count(typing) == 1)
				{
					currentTyping = nil
					return;
				}
				
				currentTyping = typing.substringToIndex(advance(typing.startIndex, count(typing) - 1));
			}

		}
		
		
		
	}
	
	class func isCurrentCharSetSecondWord(input : String!) -> Bool
	{
		if (input != nil)
		{
			let words = currentString!.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
			if (words.count == 1)
			{
				return true
			}
			
			if let range = self.currentString!.rangeOfString(input!)
			{
				if (distance(self.currentString!.startIndex, range.startIndex) != 0)
				{
					return true
				}
			}
		}
		
		return false
	}
	
	class func clear()
	{
		currentEmojiStringIndex = NSNotFound
		currentWordStringIndex = NSNotFound
		currentTypingStringIndex = NSNotFound
		
		currentWord = nil
		currentEmoji = nil
		currentTyping = nil
		currentString = nil
	}
	
	class func isReplacementStringAllowd(string : String) -> Bool
	{
		var allowedCharSet = NSCharacterSet.alphanumericCharacterSet().mutableCopy() as! NSMutableCharacterSet
		allowedCharSet.addCharactersInString("_")
		if let range = string.rangeOfCharacterFromSet(allowedCharSet)
		{
			if (currentTyping == nil && string.toInt() != nil)
			{
				return false
			}
			
			return true
			
		}
		
		return string.isEmpty //For back space.
	}
	
	
}