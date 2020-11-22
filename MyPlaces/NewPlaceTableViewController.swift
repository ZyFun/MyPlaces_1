//
//  NewPlaceTableViewController.swift
//  MyPlaces
//
//  Created by Дмитрий Данилин on 17.11.2020.
//

import UIKit

class NewPlaceTableViewController: UITableViewController {

    var imageIsChanged = false
    
    @IBOutlet weak var placeImageIV: UIImageView!
    @IBOutlet weak var saveButtonBBI: UIBarButtonItem!
    @IBOutlet weak var placeNameTF: UITextField!
    @IBOutlet weak var placeLocationTF: UITextField!
    @IBOutlet weak var placeTypeTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Отключаем разлиновку TableVIew ниже имеющихся ячеек
        tableView.tableFooterView = UIView()
        
        // Делаем кнопку сохранения не активной для того, чтобы позже сдеать её активной после заполнения необходимых TF
        saveButtonBBI.isEnabled = false
        // Создаём отслеживание заполение TF placeName, для активации кнопки сохранения
        placeNameTF.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
    }
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let cameraIcon = #imageLiteral(resourceName: "camera")
            let photoIcon = #imageLiteral(resourceName: "photo")
            // Создаём алерт контроллер (выползающее меню снизу) для добавления фото
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let camera = UIAlertAction(title: "Camera", style: .default) { _ in
                self.chooseImagePicker(source: .camera)
            }
            
            // Устанавливаем иконку для экземпляра контроллера
            camera.setValue(cameraIcon, forKey: "image")
            // Смещаем текст к левой границе
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let photo = UIAlertAction(title: "Photo", style: .default) { _ in
                self.chooseImagePicker(source: .photoLibrary)
            }
            
            // Устанавливаем иконку для экземпляра контроллера
            photo.setValue(photoIcon, forKey: "image")
            // Смещаем текст к левой границе
            photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            
            // Добавляем в контроллер созданные экшены
            actionSheet.addAction(camera)
            actionSheet.addAction(photo)
            actionSheet.addAction(cancel)
            
            // Вызываем созданный контроллер
            present(actionSheet, animated: true)
        } else {
            view.endEditing(true)
        }
    }
    
    // Метод для созранения новых объектов
    func saveNewPlace() {
        
        var image: UIImage?
        
        // если зображение было изменено пользователем, то присваимаем пользовательское изображение.
        if imageIsChanged {
            image = placeImageIV.image
        } else {
            image = #imageLiteral(resourceName: "imagePlaceholder")
        }
        
        // Создаём вспомагательное свойство image для конвертации в imageData
        let imageData = image?.pngData()
        
        // Присваиваем все введенные свойства для подготовки к сохранению в базу данных
        let newPlace = Place(name: placeNameTF.text!, location: placeLocationTF.text, type: placeTypeTF.text, imageData: imageData )
        
        //Сохраняем все введенные значения в базу данных
        StorageManager.saveObject(newPlace)
        
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
}

// MARK: - Text field delegate

extension NewPlaceTableViewController: UITextFieldDelegate {
    
    // Скрываем клавиатуру по нажатию Done
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Отслеживаем изменения для активации кнопки сохранения
    @objc private func textFieldChanged() {
        if placeNameTF.text?.isEmpty == false { // Проверяем пустое ли поле
            saveButtonBBI.isEnabled = true // Если поле не пустое, активируем кнопку
        } else {
            saveButtonBBI.isEnabled = false // Если пустое, кнопка не активна
        }
    }
}

// MARK: - Работа с изображениями
extension NewPlaceTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        // Проверяем доступность источника выбора изображений
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker = UIImagePickerController()
            // Назначаем imagePicker делегатом функции imagePickerController. Протокол: UINavigationControllerDelegate
            imagePicker.delegate = self
            // Включаем возможность редактировать выбранное изображение
            imagePicker.allowsEditing = true
            // Определяем тип источника выбранного изображения
            imagePicker.sourceType = source
            present(imagePicker, animated: true)
        }
    }
    
    // Добавляем метод, позваляющий добавить выбранное изображение протокол: UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Присваиваем свойство отредактированного изображения
        placeImageIV.image = info[.editedImage] as? UIImage
        // Масштабируем изображение по содержимому
        placeImageIV.contentMode = .scaleAspectFill
        // Обрезаем по границе изображения
        placeImageIV.clipsToBounds = true
        // Меняем свойство выбранного выбрал ли пользователь изображение, чтобы не менять выбранную картинку
        imageIsChanged = true
        // Закрываем контроллер
        dismiss(animated: true)
    }
}
