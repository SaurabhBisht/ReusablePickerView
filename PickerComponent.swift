/* MIT License

Copyright (c) 2017 Saurabh Bisht

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

//  Created by Saurabh Bisht.
//  Copyright © 2017 Saurabh Bisht. All rights reserved.
//
*/


import Foundation
import UIKit

//IBDesignable class as reusable component
@IBDesignable class PickerViewComponent: UIView, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource{
    
    //Model data
    var modelData: [[String: [String: Any]]] = []
    //Picker data
    var pickerData : [String] = []
    var picker = UIPickerView()
    //Contains the picker data
    var currentData : [String] = []
    //Useful if you have multiple picker actions
    var currrentTf : UITextField!
    //Selected Key
    var selectedKey : String! = ""
    
    //Completion block definition
    var onDoneHandler : ((_ selectedItem: String) -> Void)?
    var onCancelHandler : (()-> Void)?
    var onTextEditingHandler : ((_ textField: UITextField) -> Void)?
    
    //ContraintView main
    //var topViewConstraint : Int
    
    var keyboardHeight: CGFloat?
    
    //UI assigned to variables
    //UITextField
    let txtForSelectedData : UITextField = {
        let tf = UITextField()
        tf.font = UIFont(name: "Arial", size: 16)
        tf.tag = 0
        tf.backgroundColor =  UIColor(red:238.00/255, green: 238.00/255, blue: 238.00/255, alpha: 1)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.tintColor = UIColor.clear
        tf.placeholder = "Select"
        return tf
    }()
    
    //UIImageView
    let imgForSelecting : UIImageView = {
        let imgView = UIImageView()
        imgView.backgroundColor = UIColor.green
        imgView.tag = 1
        imgView.image = UIImage(named: "backChevronBlack")
        imgView.backgroundColor = UIColor(red:238.00/255, green: 238.00/255, blue: 238.00/255, alpha: 1)
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()
    
    //UIlabel
    let lblForSelectedData : UILabel = {
        let lb = UILabel()
        lb.tag = 3
        lb.backgroundColor =  UIColor.clear
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    
    //override init for any changes while initialisation
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //IBInspectable properties
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    //On addsubview call to adjust subviews
    override func awakeFromNib() {
        super.awakeFromNib()
        addSubview(txtForSelectedData)
        addSubview(imgForSelecting)
        addSubview(lblForSelectedData)
        makeConstraint()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        self.txtForSelectedData.delegate = self
        picker.delegate = self
        picker.dataSource = self
        self.txtForSelectedData.inputView = picker
        self.backgroundColor =  UIColor(red:238.00/255, green: 238.00/255, blue: 238.00/255, alpha: 1)
        pickerViewToolbar()
    }
    
    //Set constrints to subviews
    func makeConstraint(){
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[v0(\(self.frame.width/11))]-8-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": imgForSelecting]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-12-[v0]-0-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": txtForSelectedData]))
         addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[v0]-0-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": lblForSelectedData]))
         addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[v0]-0-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": lblForSelectedData]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[v0]-0-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": txtForSelectedData]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[v0]-10-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": imgForSelecting]))
    }
    
//================================== Delegates and Datasource =======================================
    
    //textField delegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // for normal dictionary
        //pickerData = Array(modelData.keys)
        pickerData = []
        currrentTf = textField
        
        // For complex dictionary
        for (index, element) in modelData.enumerated() {
            print("Item \(index): \(element)")
            pickerData += Array(modelData[index].keys)
        }
        
        currentData = pickerData
        picker.reloadAllComponents()
        onTextEditingHandler?(textField)


        return true
    }
    
    //Picker datasource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currentData.count
    }
    
    //Picker delegates
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currentData[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currrentTf.text = currentData[row]
        selectedKey = currentData[row]
    }
    
//===================================Toolbar creation for cancel and done events===============================
    func pickerViewToolbar(){
        let toolbr = UIToolbar()
        toolbr.barStyle = .default
        toolbr.sizeToFit()
        let btnDone = UIBarButtonItem(title: "Done", style: .plain, target: self, action:#selector(doneClick))
        let btnDivider = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let btnCancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action:#selector(cancelClick))
        toolbr.setItems([btnDone, btnDivider, btnCancel], animated: false)
        self.txtForSelectedData.inputAccessoryView = toolbr
    }
    
    //Event for done
    func doneClick(){
            onDoneHandler?(selectedKey)
            currrentTf.resignFirstResponder()
    }
    //Event for cancel
    func cancelClick(){
        currrentTf.placeholder = "Select"
        onCancelHandler?()
        currrentTf.resignFirstResponder()
    }
    
    //Service
    func getData(input: String, completion: (_ result: String) -> Void) {
            completion("Done!")
    }
    // Animate to top
    func animateTop(view: UIView){
        
        //var viewH = view.frame.size.height
        let screenSize = UIScreen.main.bounds
        let diffHeight = screenSize.height - picker.frame.size.height
        
        if(view.frame.size.height > diffHeight){
        let scrollHeight = view.frame.size.height - diffHeight
        let top = CGAffineTransform(translationX: 0, y: -(scrollHeight))
        UIView.animate(withDuration: 0.4, delay: 0.0, options: [], animations: {
            view.transform = top
        }, completion: nil)
        }
    }
    //Animate to bottom
    func animateBottom(view: UIView){
        let top = CGAffineTransform(translationX: 0, y: 0)
        UIView.animate(withDuration: 0.4, delay: 0.0, options: [], animations: {
            view.transform = top
        }, completion: nil)
    }
    //Keyboard Height
    func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
        }
    }
}




