//
//  NewPlaceTableViewController.swift
//  MyPlaces
//
//  Created by Дмитрий Данилин on 17.11.2020.
//

import UIKit

class NewPlaceTableViewController: UITableViewController {

    @IBOutlet weak var imageOfPlace: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
            // Отключаем разлиновку TableVIew ниже имеющихся ячеек
            tableView.tableFooterView = UIView()
        }
    }
}

// MARK: - Text field delegate

extension NewPlaceTableViewController: UITextFieldDelegate {
    
    // Скрываем клавиатуру по нажатию Done
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
        imageOfPlace.image = info[.editedImage] as? UIImage
        // Масштабируем изображение по содержимому
        imageOfPlace.contentMode = .scaleAspectFill
        // Обрезаем по границе изображения
        imageOfPlace.clipsToBounds = true
        // Закрываем контроллер
        dismiss(animated: true)
    }
}
