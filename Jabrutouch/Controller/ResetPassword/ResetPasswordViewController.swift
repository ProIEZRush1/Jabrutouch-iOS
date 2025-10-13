//
//  ResetPasswordViewController.swift
//  Jabrutouch
//
//  Created by Claude Code on 12/10/2025.
//  Copyright © 2025 Ravtech. All rights reserved.
//
//  Programmatic UI Implementation - No Storyboard Required

import UIKit

class ResetPasswordViewController: UIViewController, UITextFieldDelegate {

    private var activityView: ActivityView?
    var resetToken: String = ""
    var userEmail: String?

    // MARK: - UI Components - Reset Password Container

    private let backgroundOverlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.15, green: 0.158, blue: 0.35, alpha: 0.32)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 31
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let exitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "multiply"), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Reset Password"
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 28)
        label.textAlignment = .center
        label.textColor = .black
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter your new password"
        label.font = UIFont(name: "SFProDisplay-Medium", size: 24)
        label.textAlignment = .center
        label.textColor = UIColor(red: 0.174, green: 0.17, blue: 0.338, alpha: 0.88)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let newPasswordView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGroupedBackground
        view.layer.cornerRadius = 25
        view.layer.borderColor = Colors.borderGray.cgColor
        view.layer.borderWidth = 1.0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let newPasswordTextField: TextFieldWithPadding = {
        let textField = TextFieldWithPadding()
        textField.placeholder = "New Password"
        textField.font = UIFont.systemFont(ofSize: 18)
        textField.isSecureTextEntry = true
        textField.textContentType = .newPassword
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.leadingPadding = 20
        textField.trailingPadding = 20
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let confirmPasswordView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGroupedBackground
        view.layer.cornerRadius = 25
        view.layer.borderColor = Colors.borderGray.cgColor
        view.layer.borderWidth = 1.0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let confirmPasswordTextField: TextFieldWithPadding = {
        let textField = TextFieldWithPadding()
        textField.placeholder = "Confirm Password"
        textField.font = UIFont.systemFont(ofSize: 18)
        textField.isSecureTextEntry = true
        textField.textContentType = .newPassword
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.leadingPadding = 20
        textField.trailingPadding = 20
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Reset Password", for: .normal)
        button.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 0.178, green: 0.168, blue: 0.663, alpha: 1)
        button.layer.cornerRadius = 18
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - UI Components - Success Container

    private let successContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 31
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let successExitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "multiply"), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let successTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Password Reset Successfully"
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 28)
        label.textAlignment = .center
        label.textColor = .black
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let successSubTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "You can now sign in with your new password"
        label.font = UIFont(name: "SFProDisplay-Medium", size: 24)
        label.textAlignment = .center
        label.textColor = UIColor(red: 0.174, green: 0.17, blue: 0.338, alpha: 0.88)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Go to Login", for: .normal)
        button.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 0.178, green: 0.168, blue: 0.663, alpha: 1)
        button.layer.cornerRadius = 18
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Constraints

    private var containerViewTopConstraint: NSLayoutConstraint!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupConstraints()
        setupActions()
        setShadows()

        self.newPasswordTextField.delegate = self
        self.confirmPasswordTextField.delegate = self
    }

    // MARK: - UI Setup

    private func setupUI() {
        view.backgroundColor = .clear

        // Add subviews
        view.addSubview(backgroundOverlayView)
        view.addSubview(containerView)
        view.addSubview(successContainerView)

        // Reset container subviews
        containerView.addSubview(exitButton)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subTitleLabel)
        containerView.addSubview(newPasswordView)
        containerView.addSubview(confirmPasswordView)
        containerView.addSubview(resetButton)

        newPasswordView.addSubview(newPasswordTextField)
        confirmPasswordView.addSubview(confirmPasswordTextField)

        // Success container subviews
        successContainerView.addSubview(successExitButton)
        successContainerView.addSubview(successTitleLabel)
        successContainerView.addSubview(successSubTitleLabel)
        successContainerView.addSubview(loginButton)
    }

    private func setupConstraints() {
        // Background overlay - full screen
        NSLayoutConstraint.activate([
            backgroundOverlayView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundOverlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundOverlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundOverlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Container view positioning
        containerViewTopConstraint = containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 94)
        NSLayoutConstraint.activate([
            containerViewTopConstraint,
            containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 17),
            containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -17),
            containerView.heightAnchor.constraint(equalToConstant: 520)
        ])

        // Success container - same position as main container
        NSLayoutConstraint.activate([
            successContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 94),
            successContainerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 17),
            successContainerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -17),
            successContainerView.heightAnchor.constraint(equalToConstant: 420)
        ])

        // MARK: Reset Container Contents

        // Exit button
        NSLayoutConstraint.activate([
            exitButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            exitButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -23),
            exitButton.widthAnchor.constraint(equalToConstant: 18),
            exitButton.heightAnchor.constraint(equalToConstant: 18)
        ])

        // Title label
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 50),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            titleLabel.heightAnchor.constraint(equalToConstant: 60)
        ])

        // Subtitle label
        NSLayoutConstraint.activate([
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 25),
            subTitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            subTitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20)
        ])

        // New password view
        NSLayoutConstraint.activate([
            newPasswordView.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: 25),
            newPasswordView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 18.5),
            newPasswordView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -18.5),
            newPasswordView.heightAnchor.constraint(equalToConstant: 50)
        ])

        // New password text field
        NSLayoutConstraint.activate([
            newPasswordTextField.topAnchor.constraint(equalTo: newPasswordView.topAnchor, constant: 5),
            newPasswordTextField.leadingAnchor.constraint(equalTo: newPasswordView.leadingAnchor),
            newPasswordTextField.trailingAnchor.constraint(equalTo: newPasswordView.trailingAnchor),
            newPasswordTextField.bottomAnchor.constraint(equalTo: newPasswordView.bottomAnchor)
        ])

        // Confirm password view
        NSLayoutConstraint.activate([
            confirmPasswordView.topAnchor.constraint(equalTo: newPasswordView.bottomAnchor, constant: 28),
            confirmPasswordView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 18.5),
            confirmPasswordView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -18.5),
            confirmPasswordView.heightAnchor.constraint(equalToConstant: 50)
        ])

        // Confirm password text field
        NSLayoutConstraint.activate([
            confirmPasswordTextField.topAnchor.constraint(equalTo: confirmPasswordView.topAnchor, constant: 5),
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: confirmPasswordView.leadingAnchor),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: confirmPasswordView.trailingAnchor),
            confirmPasswordTextField.bottomAnchor.constraint(equalTo: confirmPasswordView.bottomAnchor)
        ])

        // Reset button
        NSLayoutConstraint.activate([
            resetButton.topAnchor.constraint(equalTo: confirmPasswordView.bottomAnchor, constant: 36),
            resetButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 18.5),
            resetButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -18.5),
            resetButton.heightAnchor.constraint(equalToConstant: 65)
        ])

        // MARK: Success Container Contents

        // Success exit button
        NSLayoutConstraint.activate([
            successExitButton.topAnchor.constraint(equalTo: successContainerView.topAnchor, constant: 20),
            successExitButton.trailingAnchor.constraint(equalTo: successContainerView.trailingAnchor, constant: -23),
            successExitButton.widthAnchor.constraint(equalToConstant: 18),
            successExitButton.heightAnchor.constraint(equalToConstant: 18)
        ])

        // Success title label
        NSLayoutConstraint.activate([
            successTitleLabel.topAnchor.constraint(equalTo: successContainerView.topAnchor, constant: 60),
            successTitleLabel.leadingAnchor.constraint(equalTo: successContainerView.leadingAnchor, constant: 20),
            successTitleLabel.trailingAnchor.constraint(equalTo: successContainerView.trailingAnchor, constant: -20)
        ])

        // Success subtitle label
        NSLayoutConstraint.activate([
            successSubTitleLabel.topAnchor.constraint(equalTo: successTitleLabel.bottomAnchor, constant: 25),
            successSubTitleLabel.leadingAnchor.constraint(equalTo: successContainerView.leadingAnchor, constant: 20),
            successSubTitleLabel.trailingAnchor.constraint(equalTo: successContainerView.trailingAnchor, constant: -20)
        ])

        // Login button
        NSLayoutConstraint.activate([
            loginButton.topAnchor.constraint(equalTo: successSubTitleLabel.bottomAnchor, constant: 50),
            loginButton.leadingAnchor.constraint(equalTo: successContainerView.leadingAnchor, constant: 18.5),
            loginButton.trailingAnchor.constraint(equalTo: successContainerView.trailingAnchor, constant: -18.5),
            loginButton.heightAnchor.constraint(equalToConstant: 65)
        ])
    }

    private func setupActions() {
        exitButton.addTarget(self, action: #selector(exitButtonPressed), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetButtonPressed), for: .touchUpInside)
        successExitButton.addTarget(self, action: #selector(exitButtonPressed), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginButtonPressed), for: .touchUpInside)
    }

    private func setShadows() {
        let shadowOffset = CGSize(width: 0.0, height: 20)
        let shadowColor = UIColor(red: 0.16, green: 0.17, blue: 0.39, alpha: 0.5)
        Utils.dropViewShadow(view: containerView, shadowColor: shadowColor, shadowRadius: 31, shadowOffset: shadowOffset)
        Utils.dropViewShadow(view: successContainerView, shadowColor: shadowColor, shadowRadius: 31, shadowOffset: shadowOffset)
    }

    // MARK: - Actions

    @objc private func exitButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc private func resetButtonPressed() {
        // Validate new password is not empty
        guard let newPassword = self.newPasswordTextField.text, !newPassword.isEmpty else {
            Utils.showAlertMessage("Please enter a new password", title: "Password Required", viewControler: self)
            return
        }

        // Validate password length
        guard newPassword.count >= 6 else {
            Utils.showAlertMessage("Password must be at least 6 characters", title: "Password Too Short", viewControler: self)
            return
        }

        // Validate confirmation password
        guard let confirmPassword = self.confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            Utils.showAlertMessage("Please confirm your password", title: "Confirmation Required", viewControler: self)
            return
        }

        // Validate passwords match
        guard newPassword == confirmPassword else {
            Utils.showAlertMessage("Passwords do not match", title: "Password Mismatch", viewControler: self)
            return
        }

        self.showActivityView()
        self.confirmResetPassword(newPassword)
    }

    @objc private func loginButtonPressed() {
        // Dismiss and navigate to login screen
        self.dismiss(animated: true, completion: nil)
    }

    private func showSuccessContainer() {
        UIView.animate(withDuration: 0.3) {
            self.containerView.isHidden = true
            self.successContainerView.isHidden = false
        }
    }

    // MARK: - API Call

    private func confirmResetPassword(_ newPassword: String) {
        LoginManager.shared.confirmResetPassword(token: self.resetToken, newPassword: newPassword) { (result) in
            self.removeActivityView()
            switch result {
            case .success(let response):
                if response.success {
                    print("✅ Password reset successful: \(response.message)")
                    self.showSuccessContainer()
                } else {
                    let title = Strings.error
                    let message = response.message
                    Utils.showAlertMessage(message, title: title, viewControler: self)
                }
            case .failure(let error):
                let title = Strings.error
                let message = error.localizedDescription
                Utils.showAlertMessage(message, title: title, viewControler: self)
            }
        }
    }

    // MARK: - ActivityView

    private func showActivityView() {
        DispatchQueue.main.async {
            if self.activityView == nil {
                self.activityView = Utils.showActivityView(inView: self.view, withFrame: self.view.frame, text: nil)
            }
        }
    }

    private func removeActivityView() {
        DispatchQueue.main.async {
            if let view = self.activityView {
                Utils.removeActivityView(view)
            }
        }
    }

    // MARK: - UITextFieldDelegate

    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3) {
            self.containerViewTopConstraint.constant = 20
            self.view.layoutIfNeeded()
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == newPasswordTextField {
            self.confirmPasswordTextField.becomeFirstResponder()
        } else {
            UIView.animate(withDuration: 0.3) {
                self.containerViewTopConstraint.constant = 94
                self.view.layoutIfNeeded()
            }
            textField.resignFirstResponder()
        }
        return true
    }
}
