//
//  CustomTableViewCell.swift
//  MyPlaces
//
//  Created by Дмитрий Данилин on 13.11.2020.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    @IBOutlet weak var imageOfPlace: UIImageView! {
        didSet {
            imageOfPlace.layer.cornerRadius = imageOfPlace.frame.size.height / 2 // Скругляем углы у изображений. Угол радиуса должен равнятся половине высоты квадрата. Делим высоту строки на 2
            imageOfPlace.clipsToBounds = true // Обрезаем изображение для скругления
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
}
