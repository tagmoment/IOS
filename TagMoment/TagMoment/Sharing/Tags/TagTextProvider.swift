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
		"\u{e425}", "\u{e415}", "\u{e42a}", "\u{e42b}", "\u{e015}" , "\u{e018}", "\u{e31c}", "\u{e013}", "\u{e312}",
		"\u{e11d}", "\u{e41f}",  "\u{e04b}", "\u{e049}", "\u{e14c}", "\u{e12f}",
		"\u{e10f}", "\u{e01d}", "\u{e11a}", "\u{e32e}", "\u{e41d}",  "\u{e419}",
		"\u{e003}", "\u{e303}", "\u{e326}", "\u{e033}", "\u{e047}", "\u{e045}",
		"\u{e33a}", "\u{e34b}", "\u{e252}", "\u{e13e}", "\u{e502}"]

	
	static var TagsDataSourceWords = ["CPT", "love", "menow", "cute", "photooftheday","happy","beautiful", "selfie", "girl", "picoftheday", "smile"," friends", "fun","fashion", "summer","food","amazing", "swag","style","family","life","lol", "pretty","sun","art","cool","funny","music","eyes","night", "beach","sky", "nice", "home", "lovit", "dog", "tattoo", "good", "best", "blessed",
		"peace", "boyfriend", "she", /*"snow", "christmas", "sweet", "yummy", "school",
		"sea", "coffee", "sunset", "sunshine", "cat", "light", "dark", "work", "haha",
		"party", "crazy", "laugh", "excited"*/ ]
	
	class func removeSpaces(_ inputString : String) -> String
	{
		return inputString.replacingOccurrences(of: " ", with: "")
	}
	
	class func addHashTagIfNeeded(_ inputString : String) -> String
	{
		if ((inputString.range(of: "#")) != nil || inputString.isEmpty)
		{
			return inputString
		}
		
		return "#" + inputString
	}
	
	class func addAllHashtags(_ inputString : String) -> String
	{
		var resultString = ""

		let words = inputString.components(separatedBy: CharacterSet.whitespaces)
		for word in words
		{
			resultString += resultString.isEmpty ? addHashTagIfNeeded(word) : " " + addHashTagIfNeeded(word)
		}
		
		return resultString
	}
	
	class func addTextByRules(_ string : String) -> String
	{
		let input = removeSpaces(string)
		let isInputEmoji = self.emojisContainer.contains(input)
		let isInputSavedWord = self.TagsDataSourceWords.contains(input)
		
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
				currentString = currentString?.replacingOccurrences(of: self.currentEmoji!, with: input)
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
				self.currentString = currentString?.replacingOccurrences(of: self.currentTyping!, with: input)
				self.currentWord = input
				self.currentTyping = nil
				return self.currentString!
			}
			
			if (self.currentWord != nil)
			{
				self.currentString = currentString?.replacingOccurrences(of: self.currentWord!, with: input)
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
				self.currentString = currentString?.replacingOccurrences(of: self.currentWord!, with: input)
				self.currentTyping = input
				self.currentWord = nil
				return self.currentString!
			}
			
			if (self.currentTyping != nil)
			{
				let temp = self.currentTyping! + input
				self.currentString = currentString?.replacingOccurrences(of: self.currentTyping!, with: temp)
				self.currentTyping = temp
				
				return self.currentString!
			}
			
			self.currentTyping = input
			self.currentString = self.currentString! + " " + self.currentTyping!
			return self.currentString!
		}
		
		return "PB"
	}
	
	class func fixEmojiSpaceIfNeeded(_ newString: String, currentString: String) -> String
	{
		
		
		var resultString = ""
		var foundEmoji = false
		let words = currentString.components(separatedBy: CharacterSet.whitespaces)
		
		for word in words
		{
			
			if (self.emojisContainer.contains(word))
			{
				foundEmoji = true
			}
			
			resultString += word
		}
		
		if (foundEmoji)
		{
			return self.emojisContainer.contains(newString) ? resultString : resultString + " " + newString
		}
		
		if (!self.emojisContainer.contains(newString) || currentString.isEmpty)
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
				if (word.characters.count == 1)
				{
					
					currentTyping = nil
					return;
				}
				
				currentTyping = word.substring(to: word.characters.index(word.startIndex, offsetBy: word.characters.count - 1));
				return;
			}
		}
		
		if (self.isCurrentCharSetSecondWord(currentTyping))
		{
			
			if let typing = currentTyping
			{
				if (typing.characters.count == 1)
				{
					currentTyping = nil
					return;
				}
				
				currentTyping = typing.substring(to: typing.characters.index(typing.startIndex, offsetBy: typing.characters.count - 1));
			}

		}
		
		
		
	}
	
	class func isCurrentCharSetSecondWord(_ input : String!) -> Bool
	{
		if (input != nil)
		{
			let words = currentString!.components(separatedBy: CharacterSet.whitespaces)
			if (words.count == 1)
			{
				return true
			}
			
			if let range = self.currentString!.range(of: input!)
			{
				if (self.currentString!.characters.distance(from: self.currentString!.startIndex, to: range.lowerBound) != 0)
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
	
	class func isReplacementStringAllowd(_ string : String) -> Bool
	{
		let allowedCharSet = (CharacterSet.alphanumerics as NSCharacterSet).mutableCopy() as! NSMutableCharacterSet
		allowedCharSet.addCharacters(in: "_")
		if string.rangeOfCharacter(from: allowedCharSet as CharacterSet) != nil
		{
			if (currentTyping == nil && Int(string) != nil)
			{
				return false
			}
			
			return true
			
		}
		
		return string.isEmpty //For back space.
	}
	
	
}
