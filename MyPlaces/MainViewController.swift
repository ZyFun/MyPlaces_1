//
//  MainViewController.swift
//  MyPlaces
//
//  Created by Дмитрий Данилин on 12.11.2020.
//

import UIKit
import RealmSwift

class MainViewController: UITableViewController {
    
    // Объект типа Results это аналог массива Swift
    // Results это автообновляемый тип контейнера, который возвращает запрашиваемые объекты
    // Результаты всегда отображают текущее состояние хранилища в текущем потоке в том числе и во время записи транзакций
    // Этот объектр позволяет работать с данными в реальном времени
    // Данный объект можно использовать так же как массив
    // создаём экземпляр модели
    var places: Results<Place>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Инициализируем переменную с объектами базы данных и делаем запрос этих объектов из базы данных
        places = realm.objects(Place.self) // Place.self мы пишем, потому что подразумеваем не саму модель данных, а именно тип Place
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    // Метод для отображения количества ячеек
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Предусматриваем возможный пустой массив
        return places.isEmpty ? 0:places.count
    }

    // Метод для работы с контентом ячейки
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell // кастим объекты ячейки к классу

        let place = places[indexPath.row]

        cell.nameLabel.text = place.name // Заполняем таблицу именами
        cell.locationLabel.text = places[indexPath.row].location // Заполняем таблицу локациями заведений
        cell.typeLabel.text = place.type // Заполняем таблицу типами заведений
        cell.imageOfPlace.image = UIImage(data: place.imageData!) // Заполняем таблицу изображениями принудительно извлекая их, потому что они никогда не будут пустыми
        
        cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2 // Скругляем углы у изображений. Угол радиуса должен равнятся половине высоты квадрата. Делим высоту строки на 2
        cell.imageOfPlace.clipsToBounds = true // Обрезаем изображение для скругления

        return cell
    }
    
    //MARK: - Table view delegate
    
//    // Метод позволяет настроить пользовательские действия, при свайпе ячейки с права на лево
//    // leadingSwipeActionsConfigurationForRowAt для действий с лева на право
//    // Этот метод используется для множества действий, по этому для нас он избыточен
//    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        // Создаём действие удаления строки
//        // style отображает цвет действия
//        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, _) in
//            // Создаём объект для удаления из массива
//            let place = self.places[indexPath.row]
//            // Вызываем действие удаления из базы
//            StorageManager.delitObject(place)
//            // Удаляем строку в приложении
//            tableView.deleteRows(at: [indexPath], with: .automatic)
//        }
//        // Передаём массив с контекстными действиями
//        return UISwipeActionsConfiguration(actions: [deleteAction])
//    }
    
    // Создаём метод для удаления строки
    // Этим методом можно либо удалять, либо добавлять строки
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        // Настраиваем стиль
        if editingStyle == .delete {
            // Создаём объект для удаления из массива
            let place = places[indexPath.row]
            // Вызываем действие удаления из базы
            StorageManager.delitObject(place)
            // Удаляем строку в приложении
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
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

    // Включаем возможность выхода из открывшегося окна обратно на MainView с сохранением данных
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        // Возвращаем данные полученные с контроллера на котором мы были ранее
        guard let newPlaceVC = segue.source as? NewPlaceTableViewController else { return }
        
        // Вызываем метод сохранения данных внесенных изменений
        newPlaceVC.saveNewPlace()
        // Перезагружаем окно для обновления данных
        tableView.reloadData()
    }
}
