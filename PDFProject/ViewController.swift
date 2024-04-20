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
    
    var expensesArray = [ExpensesObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Step 1: Generate PDF Static Data
        //generateAndSharePDF()
        
       
        //Step2: Gendrate pdf based on Dynaic object Data:
        
        expensesArray.append(ExpensesObject(expanseName: "Food", amount: "$50.0"))
        expensesArray.append(ExpensesObject(expanseName: "Transportation", amount: "$30.0"))
        expensesArray.append(ExpensesObject(expanseName: "Accommodation", amount: "$100.0"))

        
        var expensesHTML = ""
        for expense in expensesArray {
            expensesHTML += "<div class='expense'><p class='expense-name'>Expense Name: \(expense.expanseName)</p><p class='amount'>Amount: \(expense.amount)</p></div>"
            expensesHTML += "<div class='divider'></div>"
        }
        
        
        let template = TemplateObject(template: "<html><head><style> .logo { display: block; margin: 0 auto; width: 200px; height: auto; } .divider { border-bottom: 1px solid black; margin-bottom: 10px; } .expense { display: flex; justify-content: space-between; } .expense-name { flex: 1; } .amount { flex: 1; text-align: right; } </style></head><body><br><br><img class='logo' src='https://kanini.com/wp-content/uploads/2022/06/Kanini-Logo.svg' alt='Company Logo'><h1>Expenses Report</h1><div class='divider'></div>\(expensesHTML)</body></html>")

        
        generateAndSharePDFDynamically(expenses: expensesArray, template: template)
        
        // generateAndSharePDFDynamically(expenses: expenses, template: template)
        
    }
    
    
    //Step2: Dynamic way
    func generateAndSharePDFDynamically(expenses: [ExpensesObject], template: TemplateObject) {
        guard let htmlString = generateHTML(from: expenses, using: template) else {
            print("Failed to generate HTML content")
            return
        }
        
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
            // Set the file name for the PDF
            activityViewController.setValue("Expense_Report.pdf", forKey: "subject")
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    func generateHTML(from expenses: [ExpensesObject], using template: TemplateObject) -> String? {

        var renderedHTML = ""
            do {
                let template = try Template(string: template.template)
                for expense in expenses {
                    let rendering = try template.render(expense)
                    renderedHTML += rendering
                }
                return renderedHTML
            } catch {
                print("Error rendering HTML: \(error)")
                return nil
            }
        
        
//        do {
//            let template = try Template(string: template.template)
//            let rendering = try template.render(["expenseName": expenses.expanseName, "amount": expenses.amount])
//            
//            // let rendering = try template.render(expenses)
//            return rendering
//        } catch {
//            print("Error rendering HTML: \(error)")
//            return nil
//        }
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
