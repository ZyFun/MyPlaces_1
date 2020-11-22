//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by Дмитрий Данилин on 16.11.2020.
//

import RealmSwift

class Place: Object {
    @objc dynamic var name = ""
    @objc dynamic var location: String?
    @objc dynamic var type: String?
    @objc dynamic var imageData: Data?
    
    let restaurantNames = ["Farsh", "Бургер Кинг", "Макдональдc", "Якитория", "Burger Heroes"]
    
    func savePlaces() {
        
        for place in restaurantNames {
            // Присваиваем свойству изображение по названию файла из массива
            let image = UIImage(named: place)
            // Переводим изображение в тип data, для работы с изображениями в Realm, так как там тип image не поддерживается
            guard let imageData = image?.pngData() else { return } // все фото должны быть в формате png
            
            // Создаём экземпдяр модели
            let newPlace = Place()
            
            // Присваиваем переменным данные из массива
            newPlace.name = place
            newPlace.location = "Москва"
            newPlace.type = "Ресторан"
            newPlace.imageData = imageData
            
            // Сохраняем данные каждый цикл в нашу базу данных
            StorageManager.saveObject(newPlace)
            
        }
    }
}
