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
    
    // Определяем рейтинг
    var rating = 0 {
        didSet {
            // Вызываем для отработки метода и присваивания рейтинга
            updateButtonSelectionState()
        }
    }
    
    // Делаем массив из кнопок для хранения рейтинга
    private var ratingButtons = [UIButton]()
    
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
    
    // Устанавливаем цвет кнопки
    @objc func ratingTapped(button: UIButton) {
        // Определяем индекс кнопки, которой касается пользователь
        // Этот метод возвращает индекс первого выбранного элемента
        guard let index = ratingButtons.firstIndex(of: button) else { return }
        
        // Определяем рейтинг в соответствии с выбранной звездой
        let selectedRating = index + 1
        
        // Если рейтинг выбранной звезды совпадает с текущим рейтингом, то рейтинг обнудяется. Иначе присваивается рейтинг
        if selectedRating == rating {
            rating = 0
        } else {
            rating = selectedRating
        }
    }
    
    // MARK: Private methods
    private func setupButtons() {
        // Удаляем старые созданные кнопки рейтинга через цикл
        for button in ratingButtons {
            // Удаляем элементы из списка
            removeArrangedSubview(button)
            // Удаляем элементы из стеквью
            button.removeFromSuperview()
        }
        
        // Очищаем массив кнопок
        ratingButtons.removeAll()
        
        // Загружаем изображения для кнопок рейтинга
        // Определяем местоположение изображений, для отображения рисунков в интерфейс билдере
        let bundle = Bundle(for: type(of: self))
        // Задаём изображения. Последний параметр отвечает за то, чтобы убедится загружен ли правильный вариант изображения
        let filledStar = UIImage(named: "filledStar", in: bundle, compatibleWith: self.traitCollection)
        let emptyStar = UIImage(named: "emptyStar", in: bundle, compatibleWith: self.traitCollection)
        let highlightedStar = UIImage(named: "highlightedStar", in: bundle, compatibleWith: self.traitCollection)
        
        // Создаём 5 кнопок с добавлением в массив кнопок рейтинга через цикл
        for _ in 1...starCount {
            // Создаём кнопку
            let button = UIButton()
            // Устанавливаем изображение для кнопок рейтинга в зависимости от состояния (выделена, нажата и т.д.)
            // Обычное состояние когда нет никаких взаимодействий с кнопокой
            button.setImage(emptyStar, for: .normal)
            // Состояние при нажатии на кнопку (задаётся программно)
            button.setImage(filledStar, for: .selected)
            // Подсвечивается при прикосновении к кнопке
            button.setImage(highlightedStar, for: .highlighted)
            // Подсвечивается, даже если кнопка выделена, пока мы к ней прикасаемся
            button.setImage(highlightedStar, for: [.highlighted, .selected])
            
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
            ratingButtons.append(button)
        }
        // Вызываем для отображения в интерфейс билдере текущее состояние кнопок
        updateButtonSelectionState()
    }
    
    // Вспомогательный метод, для присваивания изображения звездам в соответствии с текущим рейтингом
    // При вызове этого метода, будет выполняться итерация по всем кнопкам и устанавливаться состояние каждой из них в соответствии с индексом и рейтингом
    private func updateButtonSelectionState() {
        // метод enuberated возвращает пару (объект и его индекс), для каждого элемента массива
        for (index, button) in ratingButtons.enumerated() {
            // присваиваем логическое значение true/false в зависимости от результатов выражения
            // Если индекс кнопки будет меньше рейтинга, то свойству будет присваиваться значение true и кнопка будет отображать заполненную звезду
            button.isSelected = index < rating
        }
    }
}
