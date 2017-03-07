
import Photos

let DefaultAlbumName = "TagMoment"

protocol PhotosLibraryServiceDelegate
{
	func defaultAblumReceived(_ album : PHAssetCollection)
	
}

class PhotosLibraryService: NSObject {
	fileprivate var assetCollectionPlaceholder : PHObjectPlaceholder?
	fileprivate var imageToSave : UIImage!
	
	func saveImageToAlbum(_ image : UIImage)
	{
		self.imageToSave = image;
		getOrCreateAlbum()
	}
	
	fileprivate func getOrCreateAlbum(){

		let fetchOptions = PHFetchOptions()
		fetchOptions.predicate = NSPredicate(format: "title = %@", DefaultAlbumName)
		let collection : PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
		//Check return value - If found, then get the first album out
		if let firstObject : PHAssetCollection = collection.firstObject
		{
			self.defaultAblumReceived(firstObject)
		} else {
			//If not found - Then create a new album
			PHPhotoLibrary.shared().performChanges({
				let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: DefaultAlbumName)
				self.assetCollectionPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
				}, completionHandler: { success, error in
					
					if (success && self.assetCollectionPlaceholder != nil) {
						
						let collectionFetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [self.assetCollectionPlaceholder!.localIdentifier], options: nil)

						if let firstObject : PHAssetCollection = collectionFetchResult.firstObject
						{
							self.defaultAblumReceived(firstObject)

						}
					}
			})
		}
	}
	
	fileprivate func defaultAblumReceived(_ album : PHAssetCollection)
	{
		self.saveImage(self.imageToSave, toAlbum: album)
	}

	
	fileprivate func saveImage(_ image : UIImage, toAlbum : PHAssetCollection){
		PHPhotoLibrary.shared().performChanges({
			let assetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
			let assetPlaceholder = assetRequest.placeholderForCreatedAsset
			let albumChangeRequest = PHAssetCollectionChangeRequest(for: toAlbum)
			albumChangeRequest!.addAssets([assetPlaceholder!] as NSArray)
			}, completionHandler: { success, error in
				print("added image to album")
				self.cleanup()
		})
	}
	
	fileprivate func cleanup()
	{
		self.imageToSave = nil
		self.assetCollectionPlaceholder = nil
	}
}

