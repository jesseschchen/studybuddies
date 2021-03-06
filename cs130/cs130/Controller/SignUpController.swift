//
//  SignUpController.swift
//  cs130
//
//  Created by Ram Yadav on 11/9/18.
//  Copyright © 2018 Ram Yadav. All rights reserved.
//
//reference: https://www.letsbuildthatapp.com/course/Instagram-Firebase

import UIKit
import Firebase

/// This view controller allows creation of a new user
class SignUpController: UIViewController {
    //create the email text filed
    let emailTextField: UITextField = {
        let email = UITextField(frame: .zero);
        email.backgroundColor = .white
        email.attributedPlaceholder = NSAttributedString(string: "Email",
                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        email.textColor = .black
        email.clearButtonMode = .whileEditing
        email.borderStyle = .roundedRect
        email.font = UIFont.systemFont(ofSize: 16)
        email.sizeToFit()
        email.translatesAutoresizingMaskIntoConstraints = false
        
        email.frame.size.height = 200
        return email
    }()
    
    
    //create the username text filed
    let userNameTextField: UITextField = {
        let username = UITextField();
        username.clearButtonMode = .whileEditing
        username.backgroundColor = .white
        username.attributedPlaceholder = NSAttributedString(string: "Username",
                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        username.textColor = .black
        username.borderStyle = .roundedRect
        username.font = UIFont.systemFont(ofSize: 16)
        username.sizeToFit()
        username.translatesAutoresizingMaskIntoConstraints = false
        return username
    }()
    
//    let universityName: UITextField = {
//        let name = UITextField();
//        name.clearButtonMode = .whileEditing
//        name.backgroundColor = .white
//        name.attributedPlaceholder = NSAttributedString(string: "Univeristy Name",
//                                                            attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
//        name.textColor = .black
//        name.borderStyle = .roundedRect
//        name.font = UIFont.systemFont(ofSize: 16)
//        name.sizeToFit()
//        name.translatesAutoresizingMaskIntoConstraints = true
//        return name
//    }()
    
    //create the password textfield
    let passwordTextField: UITextField = {
        let password = UITextField();
        password.clearButtonMode = .whileEditing
        password.backgroundColor = .white
        password.textColor = .black
        password.attributedPlaceholder = NSAttributedString(string: "Password",
                                                            attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
//        password.isSecureTextEntry = true
        
        password.borderStyle = .roundedRect
        password.font = UIFont.systemFont(ofSize: 16)
        password.sizeToFit()
        password.translatesAutoresizingMaskIntoConstraints = false
        return password
    }()
    
    //create the confirmpassword text field
    let confirmPasswordTextField: UITextField = {
        let password = UITextField();
        password.clearButtonMode = .whileEditing
        password.backgroundColor = .white
        password.textColor = .black
        password.attributedPlaceholder = NSAttributedString(string: "Confirm password",
                                                            attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
//        password.isSecureTextEntry = true
        
        password.borderStyle = .roundedRect
        password.font = UIFont.systemFont(ofSize: 16)
        password.sizeToFit()
        password.translatesAutoresizingMaskIntoConstraints = false
        return password
    }()
    
    //create the signUp button
    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        button.backgroundColor = APP_BLUE
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.isEnabled = true
        button.addTarget(self, action: #selector(signUpHandle), for: .touchUpInside)
        return button
    }()
    
    //crate the username label
    let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.backgroundColor = UIColor.rgb(red: 0, green: 120, blue: 175) //render background color
        label.textColor = .red
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    //change the barstyle color
    override var preferredStatusBarStyle: UIStatusBarStyle { //make bar color white
        return .lightContent
    }
    
    //handdle the signup for all the field
    @objc func signUpHandle() {
        guard let email = emailTextField.text, email.count > 0 else { self.userNameLabel.text = "Please fill out the form"; return}
        guard let username = userNameTextField.text, username.count > 0 else { self.userNameLabel.text = "Please fill out the form";  return}
        guard let password = passwordTextField.text, password.count > 0 else { self.userNameLabel.text = "Please fill out the form"; return}
        guard let confirmPassword = confirmPasswordTextField.text, confirmPassword.count > 0 else {self.userNameLabel.text = "Please fill out the form"; return}
        
        //confirm the match passwords
        if(password != confirmPassword) {
            print("Password doesn't matched! Try again!")
             self.userNameLabel.text = "Password doesn't match";
            return
        }
        
        //craete the user in the databse
        Firebase.Auth.auth().createUser(withEmail: email, password: password) { (user, err) in
            if let error = err {
                print("Account can not be created!", error)
                let get_error = self.errorHandler(err: error as NSError)
                self.userNameLabel.text = get_error
                return
            } else {
                //now store the credentials to our databse
                guard let uid = user?.uid else {return}
                let ref = Database.database().reference().child("users")
                let dictionary = [UsersAttributes.EMAIL: email, UsersAttributes.USERNAME: username, UsersAttributes.PASSWORD: password]
                let values = [uid: dictionary]
                
                ref.updateChildValues(values, withCompletionBlock: { (err, ref) in
                    if let error = err {
                        print("Error with creating account", error)
                        let get_error = self.errorHandler(err: error as NSError)
                        self.userNameLabel.text = get_error
                        return
                    } else {
                        print("Account succefully created!")
                        print("Succefully data saved!")
                        
                        //dismiss this view controller now
//                        self.dismiss(animated: true, completion: nil)
                        let loadUserController = LoadUserController()
                        let navController = UINavigationController(rootViewController: loadUserController)
                        self.present(navController, animated: true, completion: nil)
                    }
                })
            }
        }
        
    }
    
    //user to go back to loginPage
    let alreadyHaveAccountButtton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Already have an account? ", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        attributedTitle.append(NSAttributedString(string: "Sign In.", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: APP_BLUE]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(handleAlreadyHaveAccount), for: .touchUpInside)
        return button
    }()
    
    //go back to loginpage
    @objc func handleAlreadyHaveAccount() {
         self.userNameLabel.text = " ";
        navigationController?.popViewController(animated: true)
    }
    
    //it disable the keyboard appearing in the simulator
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { //disable keyboard appearing
        self.view.endEditing(true)
    }
    
    //when this view first appear, this function first called
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.rgb(red: 0, green: 120, blue: 175) //render background color
        setUpInputField()
        signUp()
        self.navigationItem.setHidesBackButton(true, animated: true)
        addErrorLabel()
        
    }
    
    //constrains for the error handler for all the textfield
    func addErrorLabel() {
        view.addSubview(userNameLabel)
        userNameLabel.anchor(left: view.leftAnchor, leftPadding: 40, right: view.rightAnchor, rightPadding: -40, top: nil, topPadding: 0, bottom: view.bottomAnchor, bottomPadding: -310, width: 0, height: 40)
    }
    
    //this is the stack view for all the above mentioned textfiled palced in the signup controller
    fileprivate func setUpInputField() {
        let stackView = UIStackView(arrangedSubviews: [emailTextField, userNameTextField, passwordTextField, passwordTextField, confirmPasswordTextField, signUpButton])
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 10
        view.addSubview(stackView)
        
        
        stackView.anchor(left: view.leftAnchor, leftPadding: 40, right: view.rightAnchor, rightPadding: -40, top: nil, topPadding: 0, bottom: nil, bottomPadding: 0, width: 0, height: 0)
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
    }

    //signup button display at the end of the signupview controller
    fileprivate func signUp() {
        view.addSubview(alreadyHaveAccountButtton) //always put this first and then only anchor
        alreadyHaveAccountButtton.anchor(left: view.leftAnchor, leftPadding: 12, right: view.rightAnchor, rightPadding: -12, top: nil, topPadding: 0, bottom: view.bottomAnchor, bottomPadding: -40, width: 0, height: 40)
    }
    
    //string of error codes
    struct LoginErrorCode {
        static let NETWORK_ERROR = "Network error occured"
        static let INVALID_EMAIL = "Invalid Email"
        static let WEAK_PASSWORD = "Weak Password,must be at least 6 character"
        static let WRONG_PASSWORD = "Invalid Username or Password"
        static let EMAIL_ALREADY_USE = "Email has already been used"
        static let USET_NOT_FOUND = "User not found"
        static let CREDENTIAL_IN_USE = "Email already exist"
    }
    
    //for the firebase error code, it converts error code to the string
    private func errorHandler(err: NSError)->String {
        var error = ""
        
        if let errorCode = AuthErrorCode(rawValue: err.code) {
            switch errorCode {
            case .networkError:
                error = (LoginErrorCode.NETWORK_ERROR);
                break;
            case .invalidEmail:
                error = (LoginErrorCode.INVALID_EMAIL);
                break;
            case .weakPassword:
                error = (LoginErrorCode.WEAK_PASSWORD);
                break;
            case .wrongPassword:
                error = (LoginErrorCode.WRONG_PASSWORD);
                break;
            case .emailAlreadyInUse:
                error = (LoginErrorCode.EMAIL_ALREADY_USE);
                break;
            case .userNotFound:
                error = (LoginErrorCode.USET_NOT_FOUND);
                break;
            case .credentialAlreadyInUse:
                error = (LoginErrorCode.CREDENTIAL_IN_USE);
                break;
            default:
                break;
            }
        }
        return error
    }
}
