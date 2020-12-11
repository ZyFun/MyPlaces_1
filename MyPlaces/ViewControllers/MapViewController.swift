//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Дмитрий Данилин on 04.12.2020.
//

import UIKit
import MapKit
import CoreLocation // Используется для определения местоположения пользователя

// Объявляем протокол для передачи данных по нажатию кнопки
protocol MapViewControllerDelegate {
    func getAddres(_ addres: String?)
}

class MapViewController: UIViewController {
    // Объявляем свойство для работы с менеджером карт. Нужно для вызова всех методов для работы с картами
    let mapManager = MapManager()
    // Объявляем свойство класса с типом протокола
    var MapViewControllerDelegate: MapViewControllerDelegate?
    var place = Place()
    
    // Создаём идентификатор для переиспользования аннотаций одинакового типа
    let annotationID = "annotationID"
    // Свойство принимающее идентификатор сегвея. Необходимо для дальнейшего выбора, по какому сегвею бьл произведен переход на карту, и какая логика должна отработать (центровка на пользователе или центровка на показе места)
    var incomeSegueID = ""

    // Создаём свойство для определения предыдущего местоположения пользователя
    var previosLocation: CLLocation? {
        // Фокусируемся на пользователе при изменении координат
        didSet {
            // Вызываем метод из mapManager для построения маршрута
            mapManager.startTrackingUserLocation(for: mapView, and: previosLocation) { (currentLocation) in
                self.previosLocation = currentLocation
                
                // Позиционируем карту по текущему местоположению с задержкой
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.mapManager.showUserLocation(mapView: self.mapView)
                }
            }
        }
    }

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapPinImage: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var goButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Присваиваем лейблу пустую строку
        addressLabel.text = ""
        // Назначаем делегатом сам класс
        mapView.delegate = self
        // Вызываем метод для отображения объектов на карте
        setupMapView()
    }
    
    @IBAction func centerViewInUserLocation() {
        // Вызываем центровку карты на пользователе
        mapManager.showUserLocation(mapView: mapView)
    }
    
    @IBAction func doneButtonPressed() {
        // Передаём в параметр метода getAddres адрес из лейбла
        MapViewControllerDelegate?.getAddres(addressLabel.text)
        // Закрываем карту
        dismiss(animated: true)
    }
    
    @IBAction func goButtonPressed() {
        // Строим маршрут вызывая метод с клоужером, который возвращает координаты текущего местоположения пользователя
        mapManager.getDirections(for: mapView) { (location) in
            self.previosLocation = location
        }
    }
    
    @IBAction func closeVC() {
        // Метод закроет котроллер и выгрузит его из памяти
        dismiss(animated: true)
    }
    
    // Метод для определения, по какому сегвею был переход пользователем
    private func setupMapView() {
        
        // Скрываем кнопку навигации
        goButton.isHidden = true
        
        // Проверяем доступность сервисов геолокации
        mapManager.checkLocationServices(mapView: mapView, segueID: incomeSegueID) {
            mapManager.locationManager.delegate = self
        }
        
        if incomeSegueID == "showPlace" {
            // Ставим маркер заведения на карте
            mapManager.setupPlacemark(place: place, mapView: mapView)
            // Скрываем лишнее
            mapPinImage.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
            // Отображаем нужное
            goButton.isHidden = false
        }
    }
    

    
//    // Метот настройки менеджера локации
//    private func setupLocationManager() {
//        // Назначаем класс делегатом, для отработки обновления разрешений геопозиции
//        locationManager.delegate = self
//        // Настраиваем точность определения местоположения пользователя
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//    }
    
   
    

    

    

    
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
    
    // Получаем адрес в соответствии с полученными координатами с центра карты
    // Данный метод будет обновляться каждый раз, при смене отображаемого региона в центре карты. И каждый раз будем отображать адрес.
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // Принимаем координаты
        let center = mapManager.getCenterLocation(for: mapView)
        // Создаём свойство для преобразования координат в название
        let geocoder = CLGeocoder()
        
        // Постоянно фокусируемся на пользователе, если мы переходим через обзор заведения и строим маршрут
        if incomeSegueID == "showPlace" && previosLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.mapManager.showUserLocation(mapView: self.mapView)
            }
        }
        
        // Освобождаем ресурсы связанные с геокодированием
        geocoder.cancelGeocode()
        
        // Преобразовуем координаты в название, получая массив меток, который соответствует переданным координатам
        geocoder.reverseGeocodeLocation(center) { (placemarks, error) in
            // Прверяем объект на наличие содержимого
            if let error = error {
                print(error)
                return
            }
            
            // Если ошибок нет, извлекаем массив меток
            guard let placemarks = placemarks else { return }
            
            // Извлекаем метку из массива
            let placemark = placemarks.first
            // Извлекаем название улицы и номер дома
            let streetName = placemark?.thoroughfare
            // Извлекаем номер дома
            let buildNumber = placemark?.subThoroughfare
            
            // Обновлять данные необходимо в основном потоке асинхронно
            DispatchQueue.main.async {
                // Проверяем адрес и номер дома для извлечения опционального значения
                if streetName != nil && buildNumber != nil {
                    // Передаём все значения в лейбл с адресом
                    self.addressLabel.text = "\(streetName!), \(buildNumber!)"
                    // Передаём только значение адреса если отсутствует номер дома
                } else if streetName != nil {
                    self.addressLabel.text = "\(streetName!)"
                } else {
                    // Передаём пустую строку, если данные отсутствуют
                    self.addressLabel.text = ""
                }
            }
        }
    }
    
    // Вызываем метод для наложения линии на маршрут
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        // Рендерим наложение линии
        let render = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        // Окрашиваем линию
        render.strokeColor = .blue
        return render
    }
}

// Расширение для обновления геопозиции после получения разрешения от пользователя на отследивание геопозиции
extension MapViewController: CLLocationManagerDelegate {
    // Данный метод вызывается при каждом изменении статуса приложения для использования служб геолокации
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        mapManager.checkLokationAuthorization(mapView: mapView, segueID: incomeSegueID)
    }
}
