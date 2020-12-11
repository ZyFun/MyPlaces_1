//
//  MainViewController.swift
//  MyPlaces
//
//  Created by Дмитрий Данилин on 12.11.2020.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var reversedSortingBBI: UIBarButtonItem!
    
    // Объявляем экземпляр класса searchController
    // Используя параметр nil, результаты поиска будут отображаться в том же окне
    // Для этого необходимо подписать текущий класс под протокол UISearchResultsUpdating
    private let searchController = UISearchController(searchResultsController: nil)
    // Массив для отображения отфильрованных записей
    private var filteredPlaces: Results<Place>!
    // Создаём вспомагательное свойство для строки поиска. Должна возвращать значение true если строка поиска пустая
    private var searchBarIsEmpty: Bool {
        // Безопасно пытаемся извлечь значение
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    // Еще одно вспомогательное свойство для отслеживания воода текста в поисковую строку
    private var isFiltering: Bool {
        // Поисковая строка активирована и не является пустой
        return searchController.isActive && !searchBarIsEmpty
    }
    // Объект типа Results это аналог массива Swift
    // Results это автообновляемый тип контейнера, который возвращает запрашиваемые объекты
    // Результаты всегда отображают текущее состояние хранилища в текущем потоке в том числе и во время записи транзакций
    // Этот объектр позволяет работать с данными в реальном времени
    // Данный объект можно использовать так же как массив
    // создаём экземпляр модели
    private var places: Results<Place>!
    // Вспомогательное свойство для обратной сортировки, по умолчанию сортировка делается по возростанию
    private var ascenfingSorted = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Инициализируем переменную с объектами базы данных и делаем запрос этих объектов из базы данных
        places = realm.objects(Place.self) // Place.self мы пишем, потому что подразумеваем не саму модель данных, а именно тип Place
        
        
        //Настройка searchController
        // Указываем на то, что получателем информации об изменении текста в поисковой строке должен быть наш класс
        searchController.searchResultsUpdater = self
        // Позволяет взяимодействовать с новым вью контроллером как с основным и получать доступ к редактированию или удалению. По умолчанию это отключено.
        searchController.obscuresBackgroundDuringPresentation = false
        // Присваиваем плейсхолдер для отображения в строке поиска
        searchController.searchBar.placeholder = "Найти"
        // Интрегрируем строку поиска в navigationBar
        navigationItem.searchController = searchController
        // Отпускаем строку поиска при переходе на другой экран
        definesPresentationContext = true

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source
    
    // Метод для отображения количества ячеек
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Логика отображения данных в случае поиска данных пользователем если поисковая строка активна
        if isFiltering {
            // Отображаем количество элементов массива filteredPlaces
            return filteredPlaces.count
        }
        return places.count
    }

    // Метод для работы с контентом ячейки
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell // кастим объекты ячейки к классу
        
        // Присваиваем значение в зависимости от активации строки поиска. Либо это будет результат поиска, либо данные из базы данных без фильтрации
        let place = isFiltering ? filteredPlaces[indexPath.row] : places[indexPath.row]

        cell.nameLabel.text = place.name // Заполняем таблицу именами
        cell.locationLabel.text = places[indexPath.row].location // Заполняем таблицу локациями заведений
        cell.typeLabel.text = place.type // Заполняем таблицу типами заведений
        cell.imageOfPlace.image = UIImage(data: place.imageData!) // Заполняем таблицу изображениями принудительно извлекая их, потому что они никогда не будут пустыми

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
    
    // Отменяем выделение ячейки при возврате назад без сохранения
    // TODO почему то не работает
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Создаём метод для удаления строки
    // Этим методом можно либо удалять, либо добавлять строки
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
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

    // MARK: - Navigation

    // Подготовка перехода на другой экран
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Подготовка информации по идентификатору сегвея
        if segue.identifier == "showDetail" {
            // Извлекаем значение индекса из выбранной ячейки, если оно есть
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            // Извлекаем объект по этому индексу в зависимости от активированного или нет поля поиска
            let place = isFiltering ? filteredPlaces[indexPath.row] : places[indexPath.row]
            // Создаём экземпляр вью контроллера на который передаём значение, выбирая контроллер назначения принудительно извлекая опционал
            let newPlaceVC = segue.destination as! NewPlaceTableViewController
            // Обращаемся к экземпляру контроллера и его свойству, в которое будем передавать значение и присваиваем ему извлеченный по индексу объект
            newPlaceVC.currentPlace = place
        }
    }

    // MARK: - Action
    
    // Включаем возможность выхода из открывшегося окна обратно на MainView с сохранением данных
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        // Возвращаем данные полученные с контроллера на котором мы были ранее
        guard let newPlaceVC = segue.source as? NewPlaceTableViewController else { return }
        
        // Вызываем метод сохранения данных внесенных изменений
        newPlaceVC.savePlace()
        // Перезагружаем окно для обновления данных
        tableView.reloadData()
    }
    @IBAction func sortSelection(_ sender: UISegmentedControl) {
        // Вызываем метод сортировки
        sorting()
    }
    @IBAction func reversedSorting(_ sender: Any) {
        // Меняем значение на противоположное
        ascenfingSorted.toggle()
        
        // Меняем значение изображения (переворачиваем стрелочки)
        if ascenfingSorted {
            // Если значение по умолчанию, используем стрелки вниз
            reversedSortingBBI.image = #imageLiteral(resourceName: "AZ")
        } else {
            // Если значение не по умолчанию, меняем значение стрелок вверх
            reversedSortingBBI.image = #imageLiteral(resourceName: "ZA")
        }
        
        sorting()
    }
    
    // Метод смены способа сортировки
    private func sorting() {
        // Если выбран 1 сегмент (0)
        if segmentedControl.selectedSegmentIndex == 0 {
            // то сортируем массив по дате в порядке возрастания или убывания, в зависимости от значения ascenfingSorted
            places = places.sorted(byKeyPath: "date", ascending: ascenfingSorted)
        } else {
            // иначе (выбран второй сегмент) сортируем по имени
            places = places.sorted(byKeyPath: "name", ascending: ascenfingSorted)
        }
        
        // Обновляем данные в таблице
        tableView.reloadData()
    }
}
//  MARK: - SearchBar
// Настройка фильтрации поиска
extension MainViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // Вызываем метод фильтрации, и подставляем в параметр значение поисковой строки
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    // метод для фильтрации контента в соответствии с поисковым запросом
    private func filterContentForSearchText (_ searchText: String) {
        // Заполняем коллекцию отфильтрованными объектами из основного массива. Поиск выполняется по двум полям, адресу и имени заведения
        // Поиск не должен зависеть от регистра символов "CONTAINS[c]"
        // Выражение означает что мы должны будем волнять поиск по полям name и lokation и фильтровать данные по значению параметра searchText в независимости от регистра символов
        // Надо разобраться подробнее в документации, как работает такая фильтрация
        filteredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText, searchText)
        
        // Обновляем значения табличного представления
        tableView.reloadData()
    }
}
