//
//  NewPlaceTableViewController.swift
//  MyPlaces
//
//  Created by Дмитрий Данилин on 17.11.2020.
//

import UIKit

class NewPlaceTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
        } else {
            view.endEditing(true)
            // Отключаем разлиновку TableVIew ниже имеющихся ячеек
            tableView.tableFooterView = UIView()
        }
    }
}

// MARK: - Text field delegate

extension NewPlaceTableViewController: UITextFieldDelegate {
    
    // Скрываем клавиатуру по нажатию Done
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
