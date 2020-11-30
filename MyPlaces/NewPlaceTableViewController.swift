//
//  NewPlaceTableViewController.swift
//  MyPlaces
//
//  Created by Дмитрий Данилин on 17.11.2020.
//

import UIKit

class NewPlaceTableViewController: UITableViewController {
    
    // Объект для передачи выбранных записей из MainViewController в этот контроллер
    var currentPlace: Place!
    var imageIsChanged = false
    
    @IBOutlet weak var placeImageIV: UIImageView!
    @IBOutlet weak var saveButtonBBI: UIBarButtonItem!
    @IBOutlet weak var placeNameTF: UITextField!
    @IBOutlet weak var placeLocationTF: UITextField!
    @IBOutlet weak var placeTypeTF: UITextField!
    @IBOutlet weak var ratingControl: RatingControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Отключаем разлиновку TableVIew ниже имеющихся ячеек и в последней ячейке
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        
        // Делаем кнопку сохранения не активной для того, чтобы позже сдеать её активной после заполнения необходимых TF
        saveButtonBBI.isEnabled = false
        // Создаём отслеживание заполение TF placeName, для активации кнопки сохранения
        placeNameTF.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        // Отслеживаем передачу данных с одного контроллерана другой, и передаём значения если условия совпали
        setupEditScreen()
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
    
    // Метод для сохранения записей
    func savePlace() {
        
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
        let newPlace = Place(name: placeNameTF.text!, location: placeLocationTF.text, type: placeTypeTF.text, imageData: imageData, rating: Double(ratingControl.rating) )
        
        // Определяем в каком методе мы находимся, в режиме редактирования или в режиме добавления новой записи
        // Проверяем свойство на отсутствие значения
        if currentPlace != nil {
            // И если оно не пустое, меняем значение объекта на новое
            // Считываем данные из базы данных и перезаписываем их
            try! realm.write {
                currentPlace?.name = newPlace.name
                currentPlace?.location = newPlace.location
                currentPlace?.type = newPlace.type
                currentPlace?.imageData = newPlace.imageData
                currentPlace?.rating = newPlace.rating
            }
        } else {
            //Сохраняем все введенные значения в базу данных если объект новый
            StorageManager.saveObject(newPlace)
        }
    }
    
    // Метод для экрана редактирования записи
    private func setupEditScreen() {
        // Если currentPlace не имеет значения, то есть в него не было передано данных из MainViewController, то данные не заполняются, иначе данные передаются в поля для редактирования
        if currentPlace != nil {
            // Вызываем метод редактирования NavigationBar
            setupNavigationBar()
            // Писваиваем свойству добавление картинки значение true, чтобы оно не менялось на значение по умолчанию
            imageIsChanged = true
            
            // Создаём вспомогательное свойство и приводим значение data в значение image, чтобы подставить его в оутлет с типом image, и если что то пойдет не так, выходим из метода
            guard let data = currentPlace?.imageData, let image = UIImage(data: data) else { return }
            
            // Присваиваем полям переданные значения
            placeImageIV.image = image
            // Выравниваем изображение, иначе оно будет смотрется очень странно
            placeImageIV.contentMode = .scaleAspectFill // масштабирует изображение по содержимому ImageView
            placeNameTF.text = currentPlace?.name
            placeLocationTF.text = currentPlace?.location
            placeTypeTF.text = currentPlace?.type
            ratingControl.rating = Int(currentPlace.rating)
        }
    }
    
    // Изменение значений navigationBar для переноса данных с ячейки в поля редактирования
    private func setupNavigationBar() {
        // Убираем название у кнопки возврата, если получается извлеч объект, то
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        // Убираем кнопку cancel
        navigationItem.leftBarButtonItem = nil
        // Передаём в заголовок текущее название заведения
        title = currentPlace?.name
        // Активируем кнопку сохранения, так как отсутствия названия быть не может
        saveButtonBBI.isEnabled = true
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
