import UIKit

struct ToDoItem: Codable {
    var title: String
    var isCompleted: Bool
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var toDoList: [ToDoItem] = []
    let userDefaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self

        if let savedData = userDefaults.data(forKey: "ToDoList"),
           let savedList = try? JSONDecoder().decode([ToDoItem].self, from: savedData) {
            toDoList = savedList
        }
    }

    func saveToDoList() {
        if let encodedData = try? JSONEncoder().encode(toDoList) {
            userDefaults.set(encodedData, forKey: "ToDoList")
        }
    }

    @IBAction func addButtonTapped(_ sender: Any) {
        showAddAlert()
    }
    

    func showAddAlert() {
        let alertController = UIAlertController(title: "Add ToDo", message: nil, preferredStyle: .alert)

        alertController.addTextField { textField in
            textField.placeholder = "Enter a new ToDo"
        }

        let addAction = UIAlertAction(title: "Add", style: .default) { _ in
            if let newToDo = alertController.textFields?.first?.text, !newToDo.isEmpty {
                let newItem = ToDoItem(title: newToDo, isCompleted: false)
                self.toDoList.append(newItem)
                self.saveToDoList()
                self.tableView.reloadData()
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(addAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoList.count
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCell", for: indexPath)

        let item = toDoList[indexPath.row]

        cell.textLabel?.text = item.title

        let switchView = UISwitch()
        switchView.isOn = item.isCompleted
        switchView.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)

        cell.accessoryView = switchView

        if item.isCompleted {
            let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue]
            cell.textLabel?.attributedText = NSAttributedString(string: item.title, attributes: attributes)
        } else {
            let attributes: [NSAttributedString.Key: Any] = [:]
            cell.textLabel?.attributedText = NSAttributedString(string: item.title, attributes: attributes)
        }

        return cell
    }
    

    @objc func switchChanged(_ sender: UISwitch) {
        if let cell = sender.superview as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
            toDoList[indexPath.row].isCompleted = sender.isOn
            saveToDoList()
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            toDoList.remove(at: indexPath.row)
            saveToDoList()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

}

