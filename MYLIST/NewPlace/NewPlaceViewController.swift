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
    
    private let nameTextField = UITextField()
    private let locationTextField = UITextField()
    private let typeTextField = UITextField()
    
    private func setupTextFields() {
        let textfields = [nameTextField, locationTextField, typeTextField]
        textfields.forEach {
            $0.delegate = self
        }
    }

    static var rating: Double = 0.0
    
    private var imageIsChanged = false
    
    private var header = NewPlaceHeaderView()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .white
        tableView.toAutoLayout()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(NewPlaceTableViewCell.self, forCellReuseIdentifier: cellID)
        tableView.register(RatingViewCell.self, forCellReuseIdentifier: "rating")
        return tableView
    }()
    
    private let cellID = "cellID"
    
    private let saveButton  = UIBarButtonItem(title: "Save", style: .plain, target: nil, action: #selector(saveButtonPressed))
   
    //MARK: FUNCS
    
    @objc private func locationButtonPressedFromTextField() {
        let mapVC = MapViewController()
        mapVC.place.name = nameTextField.text ?? ""
        mapVC.place.location = locationTextField.text
        mapVC.place.type = typeTextField.text
        mapVC.place.imageData = header.image.image?.pngData()
        mapVC.marker.isHidden = false
        mapVC.addressLabel.isHidden = false
        mapVC.doneButton.isHidden = false
        mapVC.mapViewControllerDelegate = self
        present(mapVC, animated: true)
        print("go to map")
    }
    
    @objc private func locationButtonPressed() {
        let mapVC = MapViewController()
        mapVC.place.name = nameTextField.text ?? ""
        mapVC.place.location = locationTextField.text
        mapVC.place.type = typeTextField.text
        mapVC.place.imageData = header.image.image?.pngData()
        mapVC.getDirectionsbutton.isHidden = false
        navigationController?.pushViewController(mapVC, animated: true)
        print("go to map")
    }
    
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
        
        place = Place(name: nameTextField.text ?? "", location: locationTextField.text, type: typeTextField.text, imageData: imageData, rating: NewPlaceViewController.rating)

        if currentPlace != nil {
            try! realm.write({
                currentPlace?.name = place.name
                currentPlace?.location = place.location
                currentPlace?.type = place.type
                currentPlace?.imageData = imageData
                currentPlace?.rating = place.rating
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
            header.image.backgroundColor = .systemBackground
            header.image.image = UIImage(data: image)
            NewPlaceViewController.rating = currentPlace?.rating ?? 0.0
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
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "rating", for: indexPath) as! RatingViewCell
            cell.rating = Int(NewPlaceViewController.rating)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! NewPlaceTableViewCell
            if currentPlace != nil {
                switch indexPath.row {
                    case 0:
                    cell.textField = nameTextField
                    cell.textField!.text = currentPlace?.name
                    case 1:
                    cell.textField = locationTextField
                    cell.textField!.text = currentPlace?.location
                    cell.selectLocationbutton.isHidden = false
                    cell.selectLocationbutton.addTarget(self, action: #selector(locationButtonPressedFromTextField), for: .touchUpInside)
                    case 2:
                    cell.textField = typeTextField
                    cell.textField!.text = currentPlace?.type
                    default:
                    break
                }
            } else {
                switch indexPath.row {
                    case 0:
                    cell.textField = nameTextField
                    cell.textField!.placeholder = "Enter location name"
                    cell.textField!.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
                    case 1:
                    cell.textField = locationTextField
                    cell.textField!.placeholder = "Enter location"
                    case 2:
                    cell.textField = typeTextField
                    cell.textField!.placeholder = "Enter location type"
                    default:
                    break
                }
            }
            setupTextFields()
            cell.setupViews()
            return cell
        }
    }
    
//MARK: EXTENSIONS TABLEVIEW DATA SOURCE (HEADER)
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerview = header
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapOnHeader))
        tapRecognizer.delegate = self
        tapRecognizer.numberOfTapsRequired = 2
        tapRecognizer.numberOfTouchesRequired = 1
        headerview.addGestureRecognizer(tapRecognizer)
        return headerview
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 220
    }
    
    //MARK: EXTENSIONS TABLEVIEW DATA SOURCE (FOOTTER)
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = FooterView()
        footer.button.addTarget(self, action: #selector(locationButtonPressed), for: .touchUpInside)
        return footer
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 100
    }
}

//MARK: EXTENSIONS TABLEVIEW DELEGATE

extension NewPlaceViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 3 {
            return 100
        } else {
            return 50
        }
    }
}

//MARK: EXTENSION FOR KEYGOARD AND TEXTFIELDS

extension NewPlaceViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func textFieldChanged(textField: UITextField) {
        if nameTextField.text?.isEmpty == false {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
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
        nameTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        //KEYBOARD NOTIFICATIONS

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
}

extension NewPlaceViewController: MapViewControllerDelegate {
    func getAddress(address: String?) {
        locationTextField.text = address
    }
}
