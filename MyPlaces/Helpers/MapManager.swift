//
//  MapManager.swift
//  MyPlaces
//
//  Created by Дмитрий Данилин on 11.12.2020.
//

import UIKit
import MapKit

class MapManager {
    // Создаём экземпляр класса, для настройки и управления геолокациями
    let locationManager = CLLocationManager()
    
    // Свойство для передачи координат при построении маршрута к заведению
    private var placeCoordinate: CLLocationCoordinate2D?
    // Параметр дял указания радиуса при центровки геопозиции на пользователе. Тип должен быть Double
    private let regionInMeters = 1000.00
    // Массив для хранения маршрутов и их очистки при построении новых
    private var directionsArray: [MKDirections] = []
    
    // Работаем над маркером, для отображения заведения на карте
    func setupPlacemark(place: Place, mapView: MKMapView) {
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
            annotation.title = place.name
            // Задаём описание типа точки
            annotation.subtitle = place.type
            
            // Безопасно извлекаем данные местоположения, для определения местоположения точки
            guard let placemarkLocation = placemark?.location else { return }
            
            // Привязываем описание к точке на карте
            annotation.coordinate = placemarkLocation.coordinate
            // Передаём координаты новому свойству класса для передачи их в настройку прокладки маршрута
            self.placeCoordinate = placemarkLocation.coordinate
            
            // Задаём видимую область карты таким образом, чтобы на ней было видно все созданные аннотации
            mapView.showAnnotations([annotation], animated: true)
            // Выделяем выбранный объект на карте
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    // Метод для проверки, включены ли службы геолокации
    func checkLocationServices(mapView: MKMapView, segueID: String, closure: () -> ()) {
        if CLLocationManager.locationServicesEnabled() {
            // Задаём точность определения геопозиции
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkLokationAuthorization(mapView: mapView, segueID: segueID)
            closure()
        } else {
            // Данный метод позволяет отложить запуск показа контроллера на определенное время, что позволит отоброзить его после загрузки вью
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Определение геолокации отключено", message: "Перейдите в настройки и разрешите приложению использовать геоданные: Настройки -> Концидециальность -> Службы геопозиции")
            }
        }
    }
    
    // Метод для проверки статуса на разрешение использования геопозиции пользователя
    func checkLokationAuthorization(mapView: MKMapView, segueID: String) {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse: // Разрешается отслеживание в момент использования приложения
            mapView.showsUserLocation = true
            // Центруемся на пользователе если переход был по сегвею для добавления адреса
            if segueID == "getAddress" { showUserLocation(mapView: mapView) }
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
    
    // Фокус карты на местоположении пользователя
    func showUserLocation(mapView: MKMapView) {
        // Проверяем координаты пользователя
        if let location = locationManager.location?.coordinate {
            // Если координаты получены, определяем регион для позиционирования карты с центровкой на месте положения пользователя, указывая радиус в метрах
            let region = MKCoordinateRegion(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            // Устанавливаем регион для отображения на экране
            mapView.setRegion(region, animated: true)
        }
    }
    
    // Строим маршрут от мкстоположения пользователя до заведения
    func getDirections(for mapView: MKMapView, previosLocation: (CLLocation) -> ()) {
        // Определяем координаты местоположения пользователя, и выходим из метода с ошибкой, если определить не удалось
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Ошибка", message: "Местоположение не определено")
            return
        }
        
        // Включаем режим постоянного отслеживания местоположения пользователя
        locationManager.startUpdatingLocation()
        // Передаём первоначальные координаты в свойство для отслеживания местоположения
        previosLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
        
        // Выполняем запрос на прокладку маршрута, подставляя в параметр текущее местоположения пользователя. И если что то пойдет не так, выводим сообщение об ошибке
        guard let request = createDirectionsRequest(from: location) else {
            showAlert(title: "Ошибка", message: "Что-то пошло не так. Местоназнаения не найдено")
            return
        }
        
        // Если всё прошло успешно, создаём маршрут на основе сведений, котррые у нас есть в запросе
        let directions = MKDirections(request: request)
        
        // Удаляем предыдущие маршруты, вызывая созданный метод
        resetMapView(withNew: directions, mapView: mapView)
        
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
                mapView.addOverlay(route.polyline) // Свойство polyline представляет собой подробную геометрию маршрута
                // Фокусируем карту так, чтобы весь маршрут был виден
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
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
    func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
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
    
    // Специальный метод для условый, при которых будет вызываться метод showUserLocation при построении маршрута
    func startTrackingUserLocation(for mapView: MKMapView, and location: CLLocation?, clousure: (_ currentLocation: CLLocation) -> ()) {
        // Убеждаемся, что местоположение пользователя было определено и остлеживание работает
        guard let location = location else { return }
        // определяем текущие координаты центра отображаемой области
        let center = getCenterLocation(for: mapView)
        // Определяем расстояние до центра текущей области от предыдущей точки (более 50 метров)
        guard center.distance(from: location) > 50 else { return }
        
        // Задаём координаты предыдущему местоположению пользователя
        clousure(center)
    }
    
    // Cброса маршрута перед постройкой новых
    func resetMapView(withNew directions: MKDirections, mapView: MKMapView) {
        // Удаляем с карты текущий маршрут
        mapView.removeOverlays(mapView.overlays)
        // Добавляем в массив текущие маршруты
        directionsArray.append(directions)
        // Перебираем все значения массива и отменяем у каждого элемента маршрут
        let _ = directionsArray.map { $0.cancel() }
        // Удаляем все элементы из массива
        directionsArray.removeAll()
    }
    
    // Функция для определения адреса, который находится в цетре экрана
    // Принимает параметр с mapView , и возвращает координаты
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        // Определяем координату широты, которая соответствует центру боласти карты
        let latitude = mapView.centerCoordinate.latitude
        // Определяем координату долготы, которая соответствует центру боласти карты
        let longitude = mapView.centerCoordinate.longitude
        
        // Возвращаем необходимые параметры
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    // Создаём функцию для вызова алерт контроллера
    func showAlert(title: String, message: String) {
        // Создаём алерт контроллер
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        // Конфигурируем кнопку действия
        let okAction = UIAlertAction(title: "Ok", style: .default)
        
        // Добавляем в алерт контроллер кнопку
        alert.addAction(okAction)
        
        // Создаём экземпляр класса, для показа окна с предупреждениями на главном окне устройства (bounds определяет окно по границе экрана)
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        // TODO: Что то делаем, зачем не объяснили. Разобраться позже
        alertWindow.rootViewController = UIViewController()
        // Определяем позиционирование окна с предупреждением, относительно других окон (определяем поверх окон)
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        // Делаем окно ключевым и видимым
        alertWindow.makeKeyAndVisible()
        // Вызываем это окно в качестве Alert Controller
        alertWindow.rootViewController?.present(alert, animated: true)
    }
}
