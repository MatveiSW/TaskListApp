//
//  ViewController.swift
//  TaskListApp
//
//  Created by Vasichko Anna on 29.06.2023.
//

import UIKit

final class TaskListViewController: UITableViewController {
    
    enum AlertAction {
        case save
        case edit
    }
    
    private var selectedIndexPath: IndexPath?
    private let cellID = "task"
    private var taskList: [Task] = []
    
    private var storageManager = StorageManager.shared
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupNavigationBar()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        
        fetchData()
    }
    
    
    
    @objc private func addNewTask() {
        showAlert(withTitle: "New Task", andMessage: "What would you like to do?", action: .save)
        tableView.isEditing = false
    }
    
    private func fetchData() {
        let fetchRequest = Task.fetchRequest()
        
        do {
            taskList = try storageManager.persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
            
        }
    }
    
    private func save(_ taskName: String) {
        
        let task = Task(context: storageManager.persistentContainer.viewContext)
       
            
            task.title = taskName
            taskList.append(task)
            
            tableView.insertRows(
                at: [IndexPath(row: taskList.count - 1, section: 0)],
                with: .automatic
            )
            
            if storageManager.persistentContainer.viewContext.hasChanges {
                storageManager.saveContext()
            }
            
        
    }
    
    private func edit(_ taskName: String) {
        guard let indexPath = selectedIndexPath else { return }
        let selectedRow = taskList[indexPath.row]
        selectedRow.title = taskName

        tableView.reloadRows(
            at: [IndexPath(row: indexPath.row, section: 0)],
            with: .automatic
        )

        if storageManager.persistentContainer.viewContext.hasChanges {
            storageManager.saveContext()
        }
        
    }
    
    private func showAlert(withTitle title: String, andMessage message: String, action: AlertAction) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save Task", style: .default) { [unowned self] _ in
            guard let taskName = alert.textFields?.first?.text, !taskName.isEmpty else { return }
            save(taskName)
        }
        
        let editAction = UIAlertAction(title: "Edit Task", style: .default) { [unowned self] _ in
            guard let taskName = alert.textFields?.first?.text, !taskName.isEmpty else { return }
            edit(taskName)
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        if action == .save {
            alert.addAction(saveAction)
            alert.addAction(cancelAction)
            
            alert.addTextField { textField in
                textField.placeholder = "New Task"
            }
        } else {
            alert.addAction(editAction)
            alert.addAction(cancelAction)
            
            alert.addTextField { textField in
                textField.placeholder = "Edit Task"
            }
        }
        
        present(alert, animated: true)
    }
    
}

// MARK: - UITableViewDataSource
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedIndexPath = indexPath
        showAlert(withTitle: "Edit Task", andMessage: "What would you like to do?", action: .edit)
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        storageManager.persistentContainer.viewContext.delete(taskList[indexPath.row])
        storageManager.saveContext()
        
        taskList.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        
        }
    
}

// MARK: - Setup UI
private extension TaskListViewController {
    func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.backgroundColor = UIColor(named: "MainBlue")
        
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        navigationController?.navigationBar.tintColor = .white
        
    }
}

