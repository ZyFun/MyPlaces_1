//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Дмитрий Данилин on 04.12.2020.
//

import UIKit
import MapKit
import CoreLocation // Используется для определения местоположения пользователя

class MapViewController: UIViewController {
    var place = Place()
    // СОздаём идентификатор для переиспользования аннотаций одинакового типа
    let annotationID = "annotationID"
    // Создаём экземпляр класса, для настройки и управления геолокациями
    let locationManager = CLLocationManager()
    // Параметр дял указания радиуса при центровки геопозиции на пользователе. Тип должен быть Double
    let regionInMeters = 10_000.00
    // Свойство принимающее идентификатор сегвея. Необходимо для дальнейшего выбора, по какому сегвею бьл произведен переход на карту, и какая логика должна отработать (центровка на пользователе или центровка на показе места)
    var incomeSegueID = ""

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapPinImage: UIImageView!
    @IBOutlet weak var adressLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Назначаем делегатом сам класс
        mapView.delegate = self
        // Вызываем метод для отображения объектов на карте
        setupMapView()
        // Метод для работы с геопозицией
         checkLocationServices()
    }
    @IBAction func centerViewInUserLocation() {
        // Вызываем центровку карты на пользователе
        showUserLocation()
    }
    
    @IBAction func doneButtonPressed() {
    }
    
    @IBAction func closeVC() {
        // Метод закроет котроллер и выгрузит его из памяти
        dismiss(animated: true)
    }
    
    // Метод для определения, по какому сегвею был переход пользователем
    private func setupMapView() {
        if incomeSegueID == "showPlace" {
            // Ставим маркер заведения на карте
            setupPlacemark()
            // Скрываем лишнее
            mapPinImage.isHidden = true
            adressLabel.isHidden = true
            doneButton.isHidden = true
        }
    }
    
    // Работаем над маркером, для отображения заведения на карте
    private func setupPlacemark() {
        // Извлекаем адрес заведения, если его нет, то и нет смысла что либо дальше делать
        guard let location = place.location else { return }
        
        // Экземпляр класса, для преобразования к примеру названия удицы в данные широты и долготы, для отображения объекта на карте
        let geocoder = CLGeocoder()
        // Отображает заведение на карте, по адресу, переданному в этот метод
        geocoder.geocodeAddressString(location) { (placemarks, error) in
            // Проверяем, есть ли в объекте error какие либо данные
            if let error = error {
                print(error)
                return
            }
            // Если ошибки нет, извлекаем опционал из объекта placemarks, создавая новый массив из значения placemarks
            guard let placemarks = placemarks else { return }
            
            // получаем первое значение из массива. Это сама точка для отображения на карте
            let placemark = placemarks.first
            
            // Экземпляр класса, для создания описания точки
            let annotation = MKPointAnnotation()
            // Задаём имя точке
            annotation.title = self.place.name
            // Задаём описание типа точки
            annotation.subtitle = self.place.type
            
            // Безопасно извлекаем данные местоположения, для определения местоположения точки
            guard let placemarkLocation = placemark?.location else { return }
            
            // Привязываем описание к точке на карте
            annotation.coordinate = placemarkLocation.coordinate
            
            // Задаём видимую область карты таким образом, чтобы на ней было видно все созданные аннотации
            self.mapView.showAnnotations([annotation], animated: true)
            // Выделяем выбранный объект на карте
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    // Метод для проверки, включены ли службы геолокации
    private func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLokationAuthorization()
        } else {
            // Данный метод позволяет отложить запуск показа контроллера на определенное время, что позволит отоброзить его после загрузки вью
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Определение геолокации отключено", message: "Перейдите в настройки и разрешите приложению использовать геоданные: Настройки -> Концидециальность -> Службы геопозиции")
            }
        }
    }
    
    // Метот настройки менеджера локации
    private func setupLocationManager() {
        // Назначаем класс делегатом, для отработки обновления разрешений геопозиции
        locationManager.delegate = self
        // Настраиваем точность определения местоположения пользователя
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // Метод для проверки статуса на разрешение использования геопозиции пользователя
    private func checkLokationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse: // Разрешается отслеживание в момент использования приложения
            mapView.showsUserLocation = true
            // Центруемся на пользователе если переход был по сегвею для добавления адреса
            if incomeSegueID == "getAdress" { showUserLocation() }
            break
        case .denied: // Приложению отказано использовать геолокацию или когда служба геолокации отключена в настройках
            // Данный метод позволяет отложить запуск показа контроллера на определенное время, что позволит отоброзить его после загрузки вью
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Ваша локация не определена", message: "Перейдите в настройки и разрешите приложению использовать геоданные: Настройки -> MyPlaces -> Геопозиция")
            }
            break
        case .notDetermined: // Статус не определен. Возвращается если пользователь еще не сделал выбор, может ли приложение использовать службы геолокации
            // Запрос на использование местоположения. Появляется в момент использования приложения
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted: // Возвращается, если приложение не авторизовано для использования служб геолокации
            // TODO: Поеазать алерт контроллер
            break
        case .authorizedAlways: // Возвращается, когда приложению разрешено использовать геолокацию постоянно
            break
        @unknown default:
            print("Новый неизвестный кейс")
        }
    }
    
    private func showUserLocation() {
        // Проверяем координаты пользователя
        if let location = locationManager.location?.coordinate {
            // Если координаты получены, определяем регион для позиционирования карты с центровкой на месте положения пользователя, указывая радиус в метрах
            let region = MKCoordinateRegion(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            // Устанавливаем регион для отображения на экране
            mapView.setRegion(region, animated: true)
        }
    }
    
    // Создаём функцию для вызова алерт контроллера
    private func showAlert(title: String, message: String) {
        // Создаём алерт контроллер
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        // Конфигурируем кнопку действия
        let okAction = UIAlertAction(title: "Ok", style: .default)
        
        // Добавляем в алерт контроллер кнопку
        alert.addAction(okAction)
        // Показываем алерт контроллер
        present(alert, animated: true)
    }
    
}

// Расширяем возможности работы с картами
extension MapViewController: MKMapViewDelegate {
    // Метод отвечает за аннотатии.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Отключаем отображение аннотации, если маркером является текущее положение пользователя
        guard !(annotation is MKUserLocation) else { return nil }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationID) as? MKPinAnnotationView // приведение нужно для отображения булавочки у метки
        
        // Проверяем, можем ли мы переиспользовать аннотацию, чтобы не создавать новую
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationID)
            // Отображаем аннотатцию в виде баннера
            annotationView?.canShowCallout = true
        }
        
        //безопасно извлекаем опционал с изображением
        if let imageData = place.imageData {
            // Создаём новое свойство для отображения изображения на баннере пина
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50)) // ставим ширину и высоту по 50 поинтов, потому что высота самого баннера составляет 50 поинтов
            // Скругляем углы
            imageView.layer.cornerRadius = 10
            // Обрезаем по границам
            imageView.clipsToBounds = true
            // Помещаем само изображение в баннер
            imageView.image = UIImage(data: imageData)
            // Размещаем изображение с правой стороны на баннере
            annotationView?.rightCalloutAccessoryView = imageView
        }
        
        return annotationView
    }
}

// Расширение для обновления геопозиции после получения разрешения от пользователя на отследивание геопозиции
extension MapViewController: CLLocationManagerDelegate {
    // Данный метод вызывается при каждом изменении статуса приложения для использования служб геолокации
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLokationAuthorization()
    }
}
