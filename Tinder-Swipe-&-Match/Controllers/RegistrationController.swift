//
//  RegistrationController.swift
//  Tinder-Swipe-&-Match
//
//  Created by Lucky on 18/04/2020.
//  Copyright © 2020 DmitriyYatsyuk. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD


class RegistrationController: UIViewController {
    
    //MARK: UI Components
    let selectPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Select Photo", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 32, weight: .heavy)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.heightAnchor.constraint(equalToConstant: 275).isActive = true
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(handleSelectPhoto), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill
        button.clipsToBounds = true
        return button
    }()
    
    @objc func handleSelectPhoto() {
        print("Select photo")
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        present(imagePickerController, animated: true)
        
    }
    
    let fullNameTextField: CustomTextField = {
        let textField = CustomTextField(padding: 16)
        textField.placeholder = "Enter full name"
        textField.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        textField.backgroundColor = .white
        return textField
    }()
    let emailTextField: CustomTextField = {
        let textField = CustomTextField(padding: 16)
        textField.placeholder = "Enter email"
        textField.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        textField.keyboardType = .emailAddress
        textField.backgroundColor = .white
        return textField
    }()
    let passwordTextFIeld: CustomTextField = {
        let textField = CustomTextField(padding: 16)
        textField.placeholder = "Enter password"
        textField.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        textField.isSecureTextEntry = false
        textField.backgroundColor = .white
        return textField
    }()
    
    // Activate register Button
    @objc fileprivate func handleTextChange(textField: UITextField) {
        
        if textField == fullNameTextField {
            registrationViewModel.fullName = textField.text
        } else if textField == emailTextField {
            registrationViewModel.email = textField.text
        } else {
            registrationViewModel.pw = textField.text
        }
    }
    
    let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Register", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
        //        button.backgroundColor = #colorLiteral(red: 0.7014197335, green: 0.05066127595, blue: 0.1985741373, alpha: 1)
        button.backgroundColor = .lightGray
        button.setTitleColor(.gray, for: .disabled)
        button.isEnabled = false
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.layer.cornerRadius = 22
        
        button.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        
        return button
    }()
    
    @objc fileprivate func handleRegister() {
        print("Register our User in Firebase Auth")
        self.handleTapDismiss()
        
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextFIeld.text else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { (res, err) in
            
            if let err = err {
                print(err)
                self.showHUDWithError(error: err)
                return
            }
            
            print("Successfully registered user:", res?.user.uid ?? "")
        }
    }
    
    fileprivate func showHUDWithError(error: Error) {
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Failed registration"
        hud.detailTextLabel.text = error.localizedDescription
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 3)
    }
    
    //MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGradientLayer()
        setupLayout()
        setupNotificationObserver()
        setupTapGesture()
        setupRegistrationViewModelObserver()
    }
    
    //MARK: Private
    
    let registrationViewModel = RegistrationViewModel()
    
    fileprivate func setupRegistrationViewModelObserver() {
        registrationViewModel.bindableIsFormValid.bind { [unowned self] (isFormValid) in
            
            guard let isFormValid = isFormValid else { return }
            
            self.registerButton.isEnabled = isFormValid
            
            self.registerButton.backgroundColor = isFormValid ? #colorLiteral(red: 0.7014197335, green: 0.05066127595, blue: 0.1985741373, alpha: 1) : .lightGray
            
            self.registerButton.setTitleColor(isFormValid ? .white : .gray, for: .normal)
        }
        
        registrationViewModel.bindableImage.bind { [unowned self] (img) in
        self.selectPhotoButton.setImage(img?.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        //        registrationViewModel.isFormValidObserver = { [unowned self] (isFormValid) in
        //            print("Form is changed, is it valid ?" ,isFormValid)
        //
        //            self.registerButton.isEnabled = isFormValid
        //
        //            self.registerButton.backgroundColor = isFormValid ? #colorLiteral(red: 0.7014197335, green: 0.05066127595, blue: 0.1985741373, alpha: 1) : .lightGray
        //
        //            self.registerButton.setTitleColor(isFormValid ? .white : .gray, for: .normal)
        //
        //            //            if isFormValid {
        //            //                self.registerButton.backgroundColor = #colorLiteral(red: 0.7014197335, green: 0.05066127595, blue: 0.1985741373, alpha: 1)
        //            //                self.registerButton.setTitleColor(.white, for: .normal)
        //            //            } else {
        //            //                self.registerButton.backgroundColor = .lightGray
        //            //                self.registerButton.setTitleColor(.gray, for: .normal)
        //            //            }
        //        }
        
//        registrationViewModel.imageObserver = { [unowned self] img in
        
//       self.selectPhotoButton.setImage(img?.withRenderingMode(.alwaysOriginal), for: .normal)
//        }
    }
    
    fileprivate func setupTapGesture() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapDismiss)))
    }
    
    @objc fileprivate func handleTapDismiss() {
        self.view.endEditing(true) // dismisses keyboard
    }
    
    
    fileprivate func setupNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self) // You'll have a retain cycle
    }
    
    @objc fileprivate func handleKeyboardHide() {
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.transform = .identity
        })
    }
    
    @objc fileprivate func handleKeyboardShow(notification: Notification) {
        
        // how to figure out how tall the keyboard actually is
        guard let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = value.cgRectValue
        //        print(keyboardFrame)
        
        // let's try to figure out how tall the gap is from the register buttom to the bottom of the screen
        let bottomSpace = view.frame.height - overallStackView.frame.origin.y - overallStackView.frame.height
        //        print(bottomSpace)
        
        let difference = keyboardFrame.height - bottomSpace
        self.view.transform = CGAffineTransform(translationX: 0, y: -difference - 8)
    }
    
    lazy var verticalStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [
            fullNameTextField,
            emailTextField,
            passwordTextFIeld,
            registerButton
        ])
        sv.axis = .vertical
        sv.distribution = .fillEqually
        sv.spacing = 8
        return sv
    }()
    
    lazy var overallStackView = UIStackView(arrangedSubviews: [
        selectPhotoButton,
        verticalStackView
    ])
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        //        traitCollection.horizontalSizeClass
        if self.traitCollection.verticalSizeClass == .compact {
            overallStackView.axis = .horizontal
        } else {
            overallStackView.axis = .vertical
        }
    }
    
    fileprivate func setupLayout() {
        
        view.addSubview(overallStackView)
        
        overallStackView.axis = .vertical
        
        selectPhotoButton.widthAnchor.constraint(equalToConstant: 275).isActive = true
        overallStackView.spacing = 8
        overallStackView.anchor(top: nil, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 0, left: 60, bottom: 0, right: 60))
        overallStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    let gradienLayer = CAGradientLayer()
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        gradienLayer.frame = view.bounds
    }
    
    fileprivate func setupGradientLayer() {
        let topColor = #colorLiteral(red: 1, green: 0.3592923934, blue: 0.3711785631, alpha: 1)
        let bottomColor = #colorLiteral(red: 1, green: 0, blue: 0.4635069241, alpha: 1)
        // Make sure to user cgColor
        gradienLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradienLayer.locations = [0, 1]
        view.layer.addSublayer(gradienLayer)
        gradienLayer.frame = view.bounds
    }
}

extension RegistrationController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as? UIImage
        registrationViewModel.bindableImage.value = image
        //        registrationViewModel.image = image
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}
