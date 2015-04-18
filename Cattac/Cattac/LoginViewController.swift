/*
    Cattac's login view controller
*/

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginUsername: UITextField!
    @IBOutlet weak var loginPassword: UITextField!
    
    let ref = Firebase(url: "https://torrid-inferno-1934.firebaseio.com/")
    
    let connectionManager = ConnectionManager(typeOfService: "Firebase",
        urlProvided: Constants.Firebase.baseUrl)
    
    let backgroundMusicPlayer = MusicPlayer.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundMusicPlayer.playBackgroundMusic()
        
        connectionManager.readOnce("", onComplete: {
            snapshot in
            
            println(snapshot)
        })
        
//        ref.authUser("b@b.com", password: "bbb",
//            withCompletionBlock: {
//                error, authData in
//                if error != nil {
//                    // There was an error logging in to this account
//                } else {
//                    self.performSegueWithIdentifier("loginSegue", sender: nil)
//                    // We are now logged in
//                }
//        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func createAUser(anEmail: String, aPassword: String) {
        self.ref.createUser(anEmail, password: aPassword,
            withValueCompletionBlock: {
                error, result in
                if error != nil {
                    println("Error creating user")
                } else {
                    let uid = result["uid"] as? String
                    println("Successfully created user account with uid: \(uid)")
                }
        })
    }
    
    @IBAction func loginButtonPressed(sender: UIButton) {
        let email = loginUsername.text
        let password = loginPassword.text
        
        if (email.isEmpty || password.isEmpty) {
            println("email or password is empty")
            return
        }
        
        self.ref.authUser(email, password: password) {
            error, authData in
            if (error != nil) {
                if let errorCode = FAuthenticationError(rawValue: error.code) {
                    switch (errorCode) {
                    case .UserDoesNotExist:
                        self.createAUser(email, aPassword: password)
                        
                        self.ref.authUser(email, password: password) {
                            error, authData in
                            if (error != nil) {
                                // do nothing, so many errors just make the user click the login button again
                            } else {
                                let meowsRef = self.ref.childByAppendingPath("usersMeow").childByAppendingPath(self.ref.authData.uid)
                                
                                var defaultUserMeow = ["numberOfMeows" : Constants.defaultNumberOfMeows]
                                
                                meowsRef.setValue(defaultUserMeow)
                                
                                self.performSegueWithIdentifier("loginSegue", sender: nil)
                            }
                        }
                        
                        break
                    case .InvalidEmail:
                        println("Invalid Email")
                        
                        break
                    case .InvalidPassword:
                        println("Invalid Password")
                        
                        break
                    default:
                        break
                    }
                }
            } else {
                self.performSegueWithIdentifier("loginSegue", sender: nil)
            }
        }
    }
}