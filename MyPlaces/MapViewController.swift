//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Дмитрий Данилин on 04.12.2020.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    var place = Place()
    // СОздаём идентификатор для переиспользования аннотаций одинакового типа
    let annotationID = "annotationID"

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Назначаем делегатом сам класс
        mapView.delegate = self
        
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
