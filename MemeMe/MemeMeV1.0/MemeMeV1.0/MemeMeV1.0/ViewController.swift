//
//  ViewController.swift
//  MemeMeV1.0
//
//  Created by Jordan  on 10/27/16.
//  Copyright © 2016 Jordan . All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //Set our outlets
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var bottomToolBar: UIToolbar!
    @IBOutlet weak var topToolBar: UIToolbar!
    @IBOutlet weak var actionButton: UIBarButtonItem!
    
    struct Meme {
        var topTextField: String?
        var bottomTextField: String?
        var originalImage: UIImage?
        let memedImage: UIImage!
    }
    
    //Store attributes for text fields
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.black,
        NSForegroundColorAttributeName : UIColor.white,
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : -3.0,
    ] as [String : Any]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set the defautl text for top and bottom fields
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        
        //Don't show top and bottom fields until image is chosen
        topTextField.isHidden = true
        bottomTextField.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Check to see if the camera should be enabled
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
        
        //Set the top and bottom text field attributes
        topTextField.defaultTextAttributes = memeTextAttributes
        topTextField.textAlignment = .center
        bottomTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.textAlignment = .center
        
        //Subscribe to keyboard notifications to raise view
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //Unsub from the keyboard notifications
        self.unsubscribeFromKeyboardNotifications()
    }
    
    @IBAction func shareAction(_ sender: Any) {
        let newMeme = generateMemedImage()
        
        let activityViewController = UIActivityViewController(activityItems: [newMeme], applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
        
        activityViewController.completionWithItemsHandler = { activity, success, items, error in
            if success {
                self.save(inputMeme: newMeme)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func save(inputMeme: UIImage) {
        //Create the meme
        let meme = Meme( topTextField: topTextField.text!, bottomTextField: bottomTextField.text, originalImage: imagePickerView.image, memedImage: inputMeme)
    }
    
    func generateMemedImage() -> UIImage {
        
        // TODO: Hide toolbar and navbar
        topToolBar.isHidden = true
        bottomToolBar.isHidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame,
                                     afterScreenUpdates: true)
        let memedImage : UIImage =
            UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // TODO:  Show toolbar and navbar       
        topToolBar.isHidden = false
        bottomToolBar.isHidden = false
        
        return memedImage
    }
    

    //Get the image when the Album button is clicked
    @IBAction func pickAnImageFromAlbum(_ sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
        //Also enable the action button
        self.actionButton.isEnabled = true
    }
   
    //Take a new image with the camera
    @IBAction func pickAnImageFromCamera (sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        present(imagePicker, animated: true, completion: nil)
        //Also enable the action button
        self.actionButton.isEnabled = true

    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.image = image
            
            //Show the top and bottom text now that the image will show
            self.topTextField.isHidden = false
            self.bottomTextField.isHidden = false
            }
        self.dismiss(animated: true, completion: nil)
        }
    
    func subscribeToKeyboardNotifications() {
        //For the view going up
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        //For the view to go back down
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        //Unsub from view going up
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        //Unsub from view going back down
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        //Account for the space the keyboard will take up
        if bottomTextField.isFirstResponder {
            view.frame.origin.y =  -getKeyboardHeight(notification: notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        //Set view back to original state
        view.frame.origin.y = 0.0
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
}

