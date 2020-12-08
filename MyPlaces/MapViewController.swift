//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Дмитрий Данилин on 04.12.2020.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    var place: Place!

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Вызываем метод для отображения объектов на карте
        setupPlacemark()
    }
    @IBAction func closeVC() {
        // Метод закроет котроллер и выгрузит его из памяти
        dismiss(animated: true)
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
}
