//
//  EmailController.swift
//  MyAwesomeProject
//
//  Created by Timothy Barnard on 06/02/2017.
//
//

#if os(Linux)
    import LinuxBridge
#else
    import Darwin
#endif

import PerfectSMTP

class EmailController {
    
    class func sendEmail() {
        
        // setup the mail server login information, *NOTE* please modify these information
        let client = SMTPClient(url: "smtp://smtp.gmx.com", username: "tester88@gmx.com", password:"Tester@1988")
        
        // draft an email
        var email = EMail(client: client)
        
        // set the subject
        email.subject = "hello"
        
        // set the sender
        email.from = Recipient(name: "Timothy Barnard", address: "tester88@gmx.com")
        
        // set the html content
        email.content = "<h1>Hello, world!</h1><hr><img src='http://www.perfect.org/images/perfect-logo-2-0.svg'>"
        
        // set the recipients (include the sender self)
        email.to.append(Recipient(address: "timbarnard.88@gmail.com"))
        //email.cc.append()
        
        // attach some files, *NOTE* please change to your local files instead.
        //email.attachments.append("/tmp/hello.txt")
        //email.attachments.append("/tmp/welcome.png")
        
        var wait = true
        do {
            try email.send { code, header, body in
                print("response code: \(code)")
                print("response header: \(header)")
                print("response body: \(body)")
                wait = false
            }//end send
        }catch(let err) {
            print("Failed to send: \(err)")
        }//end do
        while(wait) {
            sleep(5)
        }//end while
        print("done!")
    }
}
