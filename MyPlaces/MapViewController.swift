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
    // Объявляем свойство класса с типом протокола
    var MapViewControllerDelegate: MapViewControllerDelegate?
    var place = Place()
    // СОздаём идентификатор для переиспользования аннотаций одинакового типа
    let annotationID = "annotationID"
    // Создаём экземпляр класса, для настройки и управления геолокациями
    let locationManager = CLLocationManager()
    // Параметр дял указания радиуса при центровки геопозиции на пользователе. Тип должен быть Double
    let regionInMeters = 10_000.00
    // Свойство принимающее идентификатор сегвея. Необходимо для дальнейшего выбора, по какому сегвею бьл произведен переход на карту, и какая логика должна отработать (центровка на пользователе или центровка на показе места)
    var incomeSegueID = ""
    // Свойство для передачи координат при построении маршрута к заведению
    var placeCoordinate: CLLocationCoordinate2D?

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
        // Метод для работы с геопозицией
         checkLocationServices()
    }
    @IBAction func centerViewInUserLocation() {
        // Вызываем центровку карты на пользователе
        showUserLocation()
    }
    
    @IBAction func doneButtonPressed() {
        // Передаём в параметр метода getAddres адрес из лейбла
        MapViewControllerDelegate?.getAddres(addressLabel.text)
        // Закрываем карту
        dismiss(animated: true)
    }
    
    @IBAction func goButtonPressed() {
        // Строим маршрут
        getDirections()
    }
    
    @IBAction func closeVC() {
        // Метод закроет котроллер и выгрузит его из памяти
        dismiss(animated: true)
    }
    
    // Метод для определения, по какому сегвею был переход пользователем
    private func setupMapView() {
        
        // Скрываем кнопку навигации
        goButton.isHidden = true
        
        if incomeSegueID == "showPlace" {
            // Ставим маркер заведения на карте
            setupPlacemark()
            // Скрываем лишнее
            mapPinImage.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
            // Отображаем нужное
            goButton.isHidden = false
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
            // Передаём координаты новому свойству класса для передачи их в настройку прокладки маршрута
            self.placeCoordinate = placemarkLocation.coordinate
            
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
            if incomeSegueID == "getAddress" { showUserLocation() }
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
    
    // Метод отвечающий за прокладку маршрута
    private func getDirections() {
        // Определяем координаты местоположения пользователя, и выходим из метода с ошибкой, если определить не удалось
        guard let locdtion = locationManager.location?.coordinate else {
            showAlert(title: "Ошибка", message: "Местоположение не определено")
            return
        }
        
        // Выполняем запрос на прокладку маршрута, подставляя в параметр текущее местоположения пользователя. И если что то пойдет не так, выводим сообщение об ошибке
        guard let request = createDirectionRequest(from: locdtion) else {
            showAlert(title: "Ошибка", message: "Что-то пошло не так. Местоназнаения не найдено")
            return
        }
        
        // Если всё прошло успешно, создаём маршрут на основе сведений, котррые у нас есть в запросе
        let directions = MKDirections(request: request)
        
        // Запускаем расчет маршрута
        directions.calculate { (response, error) in
            // Пробуем извлеч ошибку
            if let error = error {
                print(error)
                return
            }
            // Если ошибки нет, извлекаем обработанный маршрут
            guard let response = response else {
                self.showAlert(title: "Ошибка", message: "Маршрут не доступен")
                return
            }
            // Объект response содержит в себе массив routes с маршрутами (этот массив может содержать в себе 1 или несколько объектов с типом MKRoute, каждый из которых представляет возможный набор направлений для пользователя. Если не делать запрос на разрешение постройки нескольких маршрутов, то массив будет содержать всего 1 объект), делаем перебор массива, чтобы поработать с каждым маршрутом отдельно
            for route in response.routes {
                // Обращаемся к объекту карты, для наложения на неё объектов маршрута
                self.mapView.addOverlay(route.polyline) // Свойство polyline представляет собой подробную геометрию маршрута
                // Фокусируем карту так, чтобы весь маршрут был виден
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                // Работаем с дополнительной информацией к маршруту, расстояние и время в пути
                // Определяем расстояние. Дистанция определяется в метрах, по этому делим на 1000 и округляем до десятых "%.1f"
                let distance = String(format: "%.1f", route.distance / 1000)
                // Определяем время в пути (время определяется в секундах)
                let timeInterval = route.expectedTravelTime
                
                print("Расстояние до места: \(distance) км.")
                print("Время в пути составит: \(timeInterval) сек.")
            }
        }
    }
    
    // Метод для настройки запроса для построения маршрута. Принимаем координаты и возвращаем запрос
    private func createDirectionRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        // Извлекаем координаты точки места назначения
        guard let destinationCoordinate = placeCoordinate else { return nil }
        // Создаём местоположения точки для начала маршрута, которая соответствует меступолжения пользователя
        let startingLocation = MKPlacemark(coordinate: coordinate)
        // Создаём точку места назначения
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        
        // Создаём запрос на построение маршрута. Этот метод позволяет определить начальную и конечную точку маршрута, а так же планируемый вид транспорта
        let request = MKDirections.Request()
        // Определяем стартовую точку
        request.source = MKMapItem(placemark: startingLocation)
        // Определяем конечную точку
        request.destination = MKMapItem(placemark: destination)
        // задаём тип транспорта для построения маршрута
        request.transportType = .automobile
        // Строим несколько маршрутов, если есть альтернативные варианты
        request.requestsAlternateRoutes = true
        
        // Возвращаем данные для построения маршрута
        return request
    }
    
    // Функция для определения адреса, который находится в цетре экрана
    // Принимает параметр с mapView , и возвращает координаты
    private func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        // Определяем координату широты, которая соответствует центру боласти карты
        let latitude = mapView.centerCoordinate.latitude
        // Определяем координату долготы, которая соответствует центру боласти карты
        let longitude = mapView.centerCoordinate.longitude
        
        // Возвращаем необходимые параметры
        return CLLocation(latitude: latitude, longitude: longitude)
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
    
    // Получаем адрес в соответствии с полученными координатами с центра карты
    // Данный метод будет обновляться каждый раз, при смене отображаемого региона в центре карты. И каждый раз будем отображать адрес.
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // Принимаем координаты
        let center = getCenterLocation(for: mapView)
        // Создаём свойство для преобразования координат в название
        let geocoder = CLGeocoder()
        
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
        checkLokationAuthorization()
    }
}
