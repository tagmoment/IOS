//
//  SharingViewController.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 2/22/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import UIKit

class SharingViewController: UIViewController {

	@IBOutlet weak var shareButton: UIButton!
	@IBOutlet weak var saveImageButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        var bgImage = shareButton.imageForState(UIControlState.Normal)
		bgImage = bgImage?.resizableImageWithCapInsets(UIEdgeInsets(top: 0, left: 44.0, bottom: 0, right: 0))
		shareButton.setImage(bgImage, forState: UIControlState.Normal)
		bgImage = saveImageButton.imageForState(UIControlState.Normal)
		bgImage = bgImage?.resizableImageWithCapInsets(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 44.0))
		saveImageButton.setImage(bgImage, forState: UIControlState.Normal)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
