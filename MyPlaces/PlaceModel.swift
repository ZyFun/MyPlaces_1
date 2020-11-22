//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by Дмитрий Данилин on 16.11.2020.
//

import RealmSwift

// описываем структуру данных в соответствии с документацией Realm
class Place: Object {
    @objc dynamic var name = ""
    @objc dynamic var location: String?
    @objc dynamic var type: String?
    @objc dynamic var imageData: Data?
    
    // Чтобы не приходилось прописывать все эти свойства в ручную, создадим инициализатор. Этот инициализатор не создаёт новый объект, а присваивает уже созданному объекту новые значения
    convenience init(name: String, location: String?, type: String?, imageData: Data?) {
        // Инициализируем свойства классов значениями по умолчанию
        self.init()
        // Присваиваем значения параметров свойствам класса
        self.name = name
        self.location = location
        self.type = type
        self.imageData = imageData
    }
}
