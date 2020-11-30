//
//  RatingControl.swift
//  MyPlaces
//
//  Created by Дмитрий Данилин on 30.11.2020.
//

import UIKit

// @IBDesignable отображает созданный кодом контент в интерфейс билдере
@IBDesignable class RatingControl: UIStackView {

    // MARK: Properties
    // Делаем массив из кнопок для хранения рейтинга
    private var ratingButton = [UIButton]()
    
    // @IBInspectable позволяет отобразить в интерфейс билдере атрибуты настроек из кода
    // Объявляем новые свойства, которые будут отвечать за количество кнопок и их размер
    // При отображении в интерфейс билдере, необходимо явно указывать тип данных
    @IBInspectable var starSize: CGSize = CGSize(width: 44.0, height: 44.0) {
        // Настраиваем возможность менять значение из интерфейс билдера
        didSet {
            setupButtons()
        }
    }
    @IBInspectable var starCount: Int = 5 {
        // Настраиваем возможность менять значение из интерфейс билдера
        didSet {
            setupButtons()
        }
    }
    
    // Определяем рейтинг
    var rating = 0
    
    // MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    
    // MARK: Button Action
    @objc func ratingTapped(button: UIButton) {
        print("Нажалася")
    }
    
    // MARK: Private methods
    private func setupButtons() {
        // Удаляем старые созданные кнопки рейтинга через цикл
        for button in ratingButton {
            // Удаляем элементы из списка
            removeArrangedSubview(button)
            // Удаляем элементы из стеквью
            button.removeFromSuperview()
        }
        
        // Очищаем массив кнопок
        ratingButton.removeAll()
        
        // Создаём 5 кнопок с добавлением в массив кнопок рейтинга через цикл
        for _ in 1...starCount {
            // Создаём кнопку
            let button = UIButton()
            button.backgroundColor = .red
            
            //Создаём констреины
            // Отключаем автоматически сгенерированные констреины для кнопки
            button.translatesAutoresizingMaskIntoConstraints = false
            // Присаваиваем ширину и высоту кнопки, и активируем их
            button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
            
            // Настраиваем экшн для кнопки
            button.addTarget(self, action: #selector(ratingTapped(button:)), for: .touchUpInside)
            
            // Помещаем кнопку в стеквью
            addArrangedSubview(button)
            
            // Помещаем созданную кнопку в массив кнопок
            ratingButton.append(button)
        }
    }
}
