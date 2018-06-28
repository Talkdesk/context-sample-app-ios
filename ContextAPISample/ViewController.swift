//
//  ViewController.swift
//  ContextAPISample
//
//  Copyright © 2018 Talkdesk. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - Constants

    // Talkdesk Callback API URL
    //
    // This should contain Talkdesk's Callback API endpoint.

    let callbackAPIURL = "https://api.talkdeskapp.com/calls/callback"

    // Talkdesk ID Auth Token
    //
    // This should be obtained via Talkdesk ID.

    let authToken = "<your token here>"

    // Talkdesk Phone Number
    //
    // This is the phone number that should perform the call. It must be a number in your account.

    let talkdeskPhoneNumber = "+1850000000"

    // MARK: - Ivars

    var isLoading = false

    // MARK: - Outlets

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var issueTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var reservationNumberTextField: UITextField!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var submitButton: UIButton!

    // MARK: - Action outlets

    // Action outlet for the Submit Button.

    @IBAction func didTapSubmitButton(_ sender: Any) {
        guard !isLoading,
            let request = buildRequest() else { return }

        isLoading = true
        activityIndicatorView.startAnimating()
        submitButton.isEnabled = false

        let task = URLSession.shared.dataTask(with: request, completionHandler: handleResponse)
        task.resume()
    }

    // MARK: - Request builders

    // This builds the request to be sent to the Callback API.

    func buildRequest() -> URLRequest? {
        guard let url = URL(string: callbackAPIURL) else { return nil }

        let encoder = JSONEncoder()
        do {
            let fields: [String: [ContextField]] = [
                "fields": buildContextFields()
            ]

            let requestBody = try encoder.encode(CallbackRequestBody(
                    talkdeskPhoneNumber: talkdeskPhoneNumber,
                    contactPhoneNumber: phoneNumberTextField?.text ?? "",
                    context: fields))

            var request: URLRequest = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
            request.httpBody = requestBody

            return request
        } catch {
            return nil
        }
    }

    // This builds the payload used in the request.

    struct CallbackRequestBody: Codable {
        let talkdeskPhoneNumber: String
        let contactPhoneNumber: String
        let context: [String: [ContextField]]

        enum CodingKeys: String, CodingKey {
            case talkdeskPhoneNumber = "talkdesk_phone_number"
            case contactPhoneNumber = "contact_phone_number"
            case context = "context"
        }
    }

    // This builds the context fields from the UI input fields.

    func buildContextFields() -> [ContextField] {
        return [
            ContextField(
                name: "issue",
                displayName: "Issue",
                tooltipText: "Issue",
                dataType: .text,
                value: issueTextField.text ?? ""
            ),
            ContextField(
                name: "name",
                displayName: "Name",
                tooltipText: "Name",
                dataType: .text,
                value: nameTextField.text ?? ""
            ),
            ContextField(
                name: "reservation_number",
                displayName: "Reservation Number",
                tooltipText: "Reservation Number",
                dataType: .text,
                value: reservationNumberTextField.text ?? ""
            )
        ]
    }

    // MARK: - Response handler

    func handleResponse(data: Data?, response: URLResponse?, error: Error?) {
        self.isLoading = false
        DispatchQueue.main.async { [unowned self] in
            self.submitButton.isEnabled = true
            self.activityIndicatorView.stopAnimating()
        }

        guard let data = data, error == nil else {
            print(error?.localizedDescription ?? "No data.")
            return
        }
        let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
        if let responseJSON = responseJSON as? [String: Any] {
            print(responseJSON)
        }
    }

}
