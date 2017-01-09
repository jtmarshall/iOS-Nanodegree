//
//  ViewController.swift
//  MemeMeV1.0
//
//  Created by Jordan  on 10/27/16.
//  Copyright © 2016 Jordan . All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    //Set our outlets
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var bottomToolBar: UIToolbar!
    @IBOutlet weak var topToolBar: UIToolbar!
    @IBOutlet weak var actionButton: UIBarButtonItem!
    
    //Store attributes for text fields
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.black,
        NSForegroundColorAttributeName : UIColor.white,
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : -3.0,
    ] as [String : Any]
    //Increasing scope of new meme for new save function.
    var newMeme : UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Configure the top and bottom text fields
        self.configureTextFields(textField: topTextField)
        self.configureTextFields(textField: bottomTextField)
        
        //Set the default text for top and bottom fields
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //close the keyboard when hit 'enter'
        textField.resignFirstResponder()
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Check to see if the camera should be enabled
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
        
        //Subscribe to keyboard notifications to raise view
        self.subscribeToKeyboardNotifications()
    }
    
    func configureTextFields(textField: UITextField) {
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
        //Don't show top and bottom fields until image is chosen
        textField.isHidden = true
        //Set delegate of text fields
        textField.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //Unsub from the keyboard notifications
        self.unsubscribeFromKeyboardNotifications()
    }
    
    @IBAction func shareAction(_ sender: Any) {
        //set new meme
        let newMeme = generateMemedImage()
        
        let activityViewController = UIActivityViewController(activityItems: [newMeme], applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
        
        //save the meme on succuess
        activityViewController.completionWithItemsHandler = { activity, success, items, error in
            if success {
                self.save()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    //Save func from lesson
    func save() {
        // Create the meme
        let meme = Meme(top: topTextField.text!, bottom: bottomTextField.text!, image: imagePickerView.image, memedImage: newMeme)
        
        // Add it to the memes array in the Application Delegate
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(meme)
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
        pickAnImageFromSource(source: .photoLibrary)
    }
   
    //Take a new image with the camera
    @IBAction func pickAnImageFromCamera (sender: AnyObject) {
        pickAnImageFromSource(source: .camera)

    }
    
    func pickAnImageFromSource(source: UIImagePickerControllerSourceType) {
        // code to pick an image from source
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        //set source based on input
        imagePicker.sourceType = source
        self.present(imagePicker, animated: true, completion: nil)
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
        NotificationCenter.default.addObserver(self, selector: #selector(MemeEditorViewController.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        //For the view to go back down
        NotificationCenter.default.addObserver(self, selector: #selector(MemeEditorViewController.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
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
