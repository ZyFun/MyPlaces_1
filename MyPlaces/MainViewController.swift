//
//  MainViewController.swift
//  MyPlaces
//
//  Created by Дмитрий Данилин on 12.11.2020.
//

import UIKit

class MainViewController: UITableViewController {
    
    let places = Place.getPlaces() //[Place(name: "Farsh", location: "Москва", type: "Ресторан", image: "Farsh")]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell // кастим объекты ячейки к классу

        cell.nameLabel.text = places[indexPath.row].name // Заполняем таблицу именами
        cell.locationLabel.text = places[indexPath.row].location // Заполняем таблицу локациями заведений
        cell.typeLabel.text = places[indexPath.row].type // Заполняем таблицу типами заведений
        cell.imageOfPlace.image = UIImage(named: places[indexPath.row].image) // Заполняем таблицу изображениями заведений
        cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2 // Скругляем углы у изображений. Угол радиуса должен равнятся половине высоты квадрата. Делим высоту строки на 2
        cell.imageOfPlace.clipsToBounds = true // Обрезаем изображение для скругления

        return cell
    }
    
    //MARK: - Table view delegate
    
//    // Метод возвращает конкретную высоту строки
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 85
//    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    // Включаем возможность выхода из открывшегося окна обратно на MainView
    @IBAction func cancelAction(_ segue: UIStoryboardSegue) {}
}
