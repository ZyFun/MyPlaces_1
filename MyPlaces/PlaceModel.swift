//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by Дмитрий Данилин on 16.11.2020.
//

import UIKit

struct Place {
    var name: String
    var location: String?
    var type: String?
    var image: UIImage?
    var restaurantImage: String?
    
    static let restaurantNames = ["Farsh", "Бургер Кинг", "Макдональдc", "Якитория", "Burger Heroes"]
    
    static func getPlaces() -> [Place] {
        var places = [Place]()
        
        for place in restaurantNames {
            places.append(Place(name: place, location: "Москва", type: "Ресторан", image: nil, restaurantImage: place))
        }
        
        return places
    }
}
