//
//  NewPlaceViewController.swift
//  MYLIST
//
//  Created by Марк Пушкарь on 16.09.2022.
//

import Foundation
import UIKit

class NewPlaceViewController: UIViewController, UIGestureRecognizerDelegate {
    
    //MARK: PROPERTIES
    
    var currentPlace: Place?
    
    private var name: String?
    private var location: String?
    private var type: String?
    
    private var imageIsChanged = false
    
    private var header = NewPlaceHeaderView()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .white
        tableView.toAutoLayout()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(NewPlaceTableViewCell.self, forCellReuseIdentifier: cellID)
        return tableView
    }()
    
    private let cellID = "cellID"
    
    private let saveButton  = UIBarButtonItem(title: "Save", style: .plain, target: nil, action: #selector(saveButtonPressed))
   
    //MARK: FUNCS
    
    @objc func handleTapOnHeader() {
        let cameraImage = UIImage(named: "camera")
        let photoLibImage = UIImage(named: "photo")
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "Camera", style: .default) { _ in
            self.chooseImagePicker(source: .camera)
        }
        camera.setValue(cameraImage, forKey: "image")
        camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        let photo = UIAlertAction(title: "Photo", style: .default) { _ in
            self.chooseImagePicker(source: .photoLibrary)
        }
        photo.setValue(photoLibImage, forKey: "image")
        photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        actionSheet.addAction(camera)
        actionSheet.addAction(photo)
        actionSheet.addAction(cancel)
        present(actionSheet, animated: true)
    }
    
    @objc func saveButtonPressed() {
        print("save button pressed")
        let place: Place
        var image: UIImage?
        if imageIsChanged {
            image = header.image.image
        } else {
            image = UIImage(named: "imagePlaceholder")
        }
        let imageData = image?.pngData()
        place = Place(name: name ?? "name's not set", location: location, type: type, imageData: imageData)
        
        if currentPlace != nil {
            try! realm.write({
                currentPlace?.name = place.name
                currentPlace?.location = place.location
                currentPlace?.type = place.type
                currentPlace?.imageData = imageData
            })
        } else {
            StorageManager.saveObject(place)
        }
        navigationController?.popToRootViewController(animated: true)
    }
    
    private func setUpEditingScreen() {
        if currentPlace != nil {
            setupNavigationBarForEditingScreen()
            imageIsChanged = true
            guard let image = currentPlace?.imageData else { return }
            header.image.contentMode = .scaleAspectFit
            header.image.image = UIImage(data: image)
        }
    }
    
    private func setupNavigationBarForEditingScreen() {
        title = currentPlace?.name
        saveButton.isEnabled = true
    }

    //MARK: LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setUpEditingScreen()
    }
}

//MARK: EXTENSIONS TABLEVIEW DATA SOURCE

extension NewPlaceViewController: UITableViewDataSource {
         
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! NewPlaceTableViewCell
        cell.textField.delegate = self
        cell.textField.tag = indexPath.row
        if currentPlace != nil {
            switch indexPath.row {
                case 0:
                cell.textField.text = currentPlace?.name
                case 1:
                cell.textField.text = currentPlace?.location
                case 2:
                cell.textField.text = currentPlace?.type
                default:
                break
            }
        } else {
            switch indexPath.row {
                case 0:
                cell.textField.placeholder = "Enter location name"
                cell.textField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
                case 1:
                cell.textField.placeholder = "Enter location"
                case 2:
                cell.textField.placeholder = "Enter location type"
                default:
                break
            }
        }
        return cell
    }
    
//MARK: EXTENSIONS TABLEVIEW DATA SOURCE (HEADER)
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerview = header
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapOnHeader))
        tapRecognizer.delegate = self
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.numberOfTouchesRequired = 1
        headerview.addGestureRecognizer(tapRecognizer)
        return headerview
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 220
    }
}

//MARK: EXTENSIONS TABLEVIEW DELEGATE

extension NewPlaceViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}


//MARK: EXTENSION FOR KEYGOARD AND TEXTFIELDS

extension NewPlaceViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func textFieldChanged(textField: UITextField) {
        if textField.text?.isEmpty == false {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.addTarget(self, action: #selector(valueChanged), for: .editingChanged)
    }
    
    @objc func valueChanged(_ textField: UITextField){
        switch textField.tag {
        case 0:
            name = textField.text
            print("name: \(String(describing: name))")
        case 1:
            location = textField.text
            print("location: \(String(describing: location))")
        case 2:
            type = textField.text
            print("type: \(String(describing: type))")
        default:
            break
        }
    }

    
    // KEYBOARD ADJUSTING
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            tableView.contentInset = .zero
        } else {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        tableView.scrollIndicatorInsets = tableView.contentInset
    }
}

//MARK: EXTENSION WORKING WITH IMAGES

extension NewPlaceViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            present(imagePicker, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as? UIImage
        header.image.image = image
        header.image.clipsToBounds = true
        header.image.contentMode = .scaleAspectFill
        imageIsChanged = true
        tableView.reloadData()
        dismiss(animated: true)
    }
}

//MARK: EXTENSION (PRIVATE)

private extension NewPlaceViewController {
    func setupViews() {
        view.addSubview(tableView)
        view.backgroundColor = .systemBackground
        let constraints = [
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        navigationItem.rightBarButtonItem = saveButton
        tableView.keyboardDismissMode = .interactive
        saveButton.isEnabled = false
        
        //KEYBOARD NOTIFICATIONS

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
}

