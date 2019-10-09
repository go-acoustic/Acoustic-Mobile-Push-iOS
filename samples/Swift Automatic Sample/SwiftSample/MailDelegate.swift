/*
 * Copyright © 2015, 2019 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */


import UIKit
import MessageUI

class MailDelegate : NSObject, MFMailComposeViewControllerDelegate, MCEActionProtocol
{
    var mailController: MFMailComposeViewController?
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        switch(result)
        {
        case .cancelled:
            print("Mail send was canceled")
            break
        case .saved:
            print("Mail was saved as draft")
            break
        case .sent:
            print("Mail was sent")
            break
        case .failed:
            print("Mail send failed")
            break
        @unknown default:
            print("Unknown mail status")
            break
        }
        controller.dismiss(animated: true) { () -> Void in
            
        }
    }
    
    @objc
    func sendEmail(action: NSDictionary)
    {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            print("Custom action with value \(action["value"] ?? "")")
            if !MFMailComposeViewController.canSendMail()
            {
                let alert = UIAlertController(title: "Cannot send mail", message: "Please verify that you have a mail account setup.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default))
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true)
                return
            }
            
            if let value = action["value"] as? NSDictionary
            {
                let subject = value["subject"] as! String?
                let body = value["body"] as! String?
                let recipient = value["recipient"] as! String?
                
                if subject != nil && body != nil && recipient != nil
                {
                    self.mailController = MFMailComposeViewController.init()
                    self.mailController!.mailComposeDelegate=self
                    self.mailController!.setSubject(subject!)
                    self.mailController!.setToRecipients([recipient!])
                    self.mailController!.setMessageBody(body!, isHTML: false)
                    
                    UIApplication.shared.keyWindow?.rootViewController?.present(self.mailController!, animated: true, completion: { () -> Void in
                    })
                    return
                }
            }
            
            let alert = UIAlertController(title: "Cannot send mail", message: "Incorrect package contents.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default))
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true)
        }
    }
    
}
