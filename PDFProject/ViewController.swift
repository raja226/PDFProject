//
//  ViewController.swift
//  PDFProject
//
//  Created by Administrator on 20/04/24.
//

import UIKit
import Mustache
//import PDFKit
//import WebKit

struct ExpensesObject:Codable
{
    var expanseName:String
    var amount: String
}

struct TemplateObject: Codable
{
    var template: String
}

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        generateAndSharePDF()
        
        // Example data
        let expenses = ExpensesObject(expanseName: "Food", amount: "$50.0")
        let template = TemplateObject(template: "<html><body><h1>Rajasekhar Expense Report</h1><p>Expense Name: {{ expenseName }}</p><p>Amount: {{ amount }}</p></body></html>")
        
        //generateAndSharePDF(expenses: expenses, template: template)

    }
    
    func generateAndSharePDF() {

        let htmlString = "<html><body><h1>Rajasekhar Expense Report</h1><p>Expense Name: Food</p><p>Amount: $50.0</p></body></html>"
        
        // Create a WebView
        let webView = UIWebView(frame: self.view.bounds)
        
        // Load HTML content
        webView.loadHTMLString(htmlString, baseURL: nil)
        
        // Wait for WebView to finish loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // Convert WebView content to PDF
            guard let pdfData = self.createPDFData(from: webView) else {
                print("Failed to generate PDF data")
                return
            }
            
            // Present a share sheet to share the PDF
            let activityViewController = UIActivityViewController(activityItems: [pdfData], applicationActivities: nil)
            activityViewController.setValue("Expense_Report.pdf", forKey: "subject")

            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    func createPDFData(from webView: UIWebView) -> Data? {
            guard let pdfData = webView.createPDF() else {
                return nil
            }
            return pdfData as Data
        }
}

extension UIWebView {
    
    func createPDF() -> NSData? {
            let originalBounds = self.bounds
            let fittedSize = self.sizeThatFits(CGSize(width: self.bounds.size.width, height: CGFloat.greatestFiniteMagnitude))
            self.bounds = CGRect(x: 0, y: 0, width: fittedSize.width, height: fittedSize.height)
            
            let pdfData = NSMutableData()
            
            UIGraphicsBeginPDFContextToData(pdfData, self.bounds, nil)
            UIGraphicsBeginPDFPage()
            guard let pdfContext = UIGraphicsGetCurrentContext() else { return nil }
            self.layer.render(in: pdfContext)
            UIGraphicsEndPDFContext()
            
            self.bounds = originalBounds
            
            return pdfData
        }
}
