
import Photos

let DefaultAlbumName = "TagMoment"

protocol PhotosLibraryServiceDelegate
{
	func defaultAblumReceived(album : PHAssetCollection)
	
}

class PhotosLibraryService: NSObject {
	private var assetCollectionPlaceholder : PHObjectPlaceholder?
	private var imageToSave : UIImage!
	
	func saveImageToAlbum(image : UIImage)
	{
		self.imageToSave = image;
		getOrCreateAlbum()
	}
	
	private func getOrCreateAlbum(){

		let fetchOptions = PHFetchOptions()
		fetchOptions.predicate = NSPredicate(format: "title = %@", DefaultAlbumName)
		let collection : PHFetchResult = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: fetchOptions)
		//Check return value - If found, then get the first album out
		if let _: AnyObject = collection.firstObject
		{
			self.defaultAblumReceived(collection.firstObject as! PHAssetCollection)
		} else {
			//If not found - Then create a new album
			PHPhotoLibrary.sharedPhotoLibrary().performChanges({
				let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollectionWithTitle(DefaultAlbumName)
				self.assetCollectionPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
				}, completionHandler: { success, error in
					
					if (success && self.assetCollectionPlaceholder != nil) {
						
						let collectionFetchResult = PHAssetCollection.fetchAssetCollectionsWithLocalIdentifiers([self.assetCollectionPlaceholder!.localIdentifier], options: nil)

						let firstObject = collectionFetchResult.firstObject;
						
						self.defaultAblumReceived(firstObject as! PHAssetCollection)
					}
			})
		}
	}
	
	private func defaultAblumReceived(album : PHAssetCollection)
	{
		self.saveImage(self.imageToSave, toAlbum: album)
	}

	
	private func saveImage(image : UIImage, toAlbum : PHAssetCollection){
		PHPhotoLibrary.sharedPhotoLibrary().performChanges({
			let assetRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(image)
			let assetPlaceholder = assetRequest.placeholderForCreatedAsset
			let albumChangeRequest = PHAssetCollectionChangeRequest(forAssetCollection: toAlbum)
			albumChangeRequest!.addAssets([assetPlaceholder!])
			}, completionHandler: { success, error in
				print("added image to album")
				self.cleanup()
		})
	}
	
	private func cleanup()
	{
		self.imageToSave = nil
		self.assetCollectionPlaceholder = nil
	}
}

