//
//  StorageManager.swift
//  MyPlaces
//
//  Created by Дмитрий Данилин on 22.11.2020.
//

import RealmSwift

// Создаём объект для предоставления доступа к базе данных
let realm = try! Realm()

// Создаём класс для работы с базой данных
class StorageManager {
    // Создаём метод для сохранения данных
    static func saveObject(_ place: Place) {
        // Добавляем данные в базу
        try! realm.write {
            realm.add(place)
        }
    }
    
    // Метод для удаления объекта из базы
    static func delitObject(_ place: Place) {
        // Удаляем объект из базы данных
        try! realm.write {
            realm.delete(place)
        }
    }
}
