//
//  Gallery.swift
//  Scover
//
//  Created by Kirill Kozhuhar on 27/06/2017.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

class Gallery: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private let mCallback: (UIImage)->Void
    private weak var mRoot: UIViewController?
    
    init(root: UIViewController, callback: @escaping (UIImage)->Void) {
        mRoot = root
        mCallback = callback
    }
    
    func show() {
        guard let types = UIImagePickerController.availableMediaTypes(for: .photoLibrary) else { return }
        
        let gallery: ()->Void = {
            let picker: UIImagePickerController = UIImagePickerController()
            picker.allowsEditing = false
            picker.delegate      = self
            picker.sourceType    = .photoLibrary
            picker.mediaTypes    = types
            self.mRoot?.present(picker, animated: true)
        }
        
        if (UIImagePickerController.isCameraDeviceAvailable(.front) || UIImagePickerController.isCameraDeviceAvailable(.rear)) {
            let alert: UIAlertController = UIAlertController(title: "ADD_PHOTO_MSG".loc, message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ADD_PHOTO_CAMERA".loc, style: .default, handler: { (_) in
                let picker: UIImagePickerController = UIImagePickerController()
                picker.delegate          = self
                picker.allowsEditing     = false
                picker.sourceType        = UIImagePickerControllerSourceType.camera
                picker.cameraCaptureMode = .photo
                picker.modalPresentationStyle = .fullScreen
                self.mRoot?.present(picker,animated: true,completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "ADD_PHOTO_GALLERY".loc, style: .default, handler: { (_) in
                gallery()
            }))
            alert.addAction(UIAlertAction(title: "ADD_PHOTO_CANCEL".loc, style: .cancel, handler: nil))
            mRoot?.present(alert, animated: true)
        } else {
            gallery()
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate methods
    // -------------------------------------------------------------------------
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.presentingViewController?.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.presentingViewController?.dismiss(animated: true)
        if let image = (info[UIImagePickerControllerOriginalImage] as? UIImage)?.resize(size: CGSize(width: 400, height: 400)) {
            mCallback(image)
        }
    }

}
