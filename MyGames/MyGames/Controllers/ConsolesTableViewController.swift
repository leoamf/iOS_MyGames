//
//  ConsolesTableViewController.swift
//  MyGames
//
//  Created by aluno on 21/07/18.
//  Copyright © 2018 aluno. All rights reserved.
//

import UIKit
import CoreData

class ConsolesTableViewController: UITableViewController {
    // esse tipo de classe oferece mais recursos para monitorar os dados
    var fetchedResultController:NSFetchedResultsController<Console>!
    // tip. podemos passar qual view vai gerenciar a busca. Neste caso a própria viewController (logo usei nil)
    let searchController = UISearchController(searchResultsController: nil)
    
    var consoleManager = ConsolesManager.shared
    override func viewDidLoad() {
        super.viewDidLoad()
        loadConsoles()
 
    }
    func loadConsoles(){
        consoleManager.loadConsoles(with: context)
        tableView.reloadData()
        
        // Coredata criou na classe model uma funcao para recuperar o fetch request
        let fetchRequest: NSFetchRequest<Console> = Console.fetchRequest()
        
        // definindo criterio da ordenacao de como os dados serao entregues
        let consoleNameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [consoleNameSortDescriptor]
        
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultController.delegate = self
        
        do {
            try fetchedResultController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         loadConsoles()
        // se ocorrer mudancas na entidade Console, a atualização automatica não irá ocorrer porque nosso NSFetchResultsController esta monitorando a entidade Game. Caso tiver mudanças na entidade Console precisamos atualizar a tela com a tabela de alguma forma: reloadData :)
        tableView.reloadData()
    }
    func showAlert(with console: Console?) {
        let title = console == nil ? "Adicionar" : "Editar"
        let alert = UIAlertController(title: title + " plataforma", message: nil, preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "Nome da plataforma"
            
            if let name = console?.name {
                textField.text = name
            }
        })
        
        alert.addAction(UIAlertAction(title: title, style: .default, handler: {(action) in
            let console = console ?? Console(context: self.context)
            console.name = alert.textFields?.first?.text
            do {
                try self.context.save()
                self.loadConsoles()
            } catch {
                print(error.localizedDescription)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        alert.view.tintColor = UIColor(named: "second")
        
        present(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return consoleManager.consoles.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let console = consoleManager.consoles[indexPath.row]
        cell.textLabel?.text = console.name
        
        if let image = console.cover as? UIImage {
            cell.imageView!.image =  resizeImage(image: image, targetSize: CGSize(width:60.0, height:60.0) )
        } else {
            cell.imageView!.image =  resizeImage(image: UIImage(named: "noCover")!, targetSize: CGSize(width:60.0, height:60.0) )
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! == "editConsole" {
            let vc = segue.destination as! AddEditPlataformaViewController
            
            if let consoles = fetchedResultController.fetchedObjects {
                vc.console = consoles[tableView.indexPathForSelectedRow!.row]
            }
            
        } else if segue.identifier! == "newConsole" {
            
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        // deselecionar atual cell
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            consoleManager.deleteConsole(index: indexPath.row, context: context)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

}

extension ConsolesTableViewController: NSFetchedResultsControllerDelegate {
    
    // sempre que algum objeto for modificado esse metodo sera notificado
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .delete:
            if let indexPath = indexPath {
                // Delete the row from the data source
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            break
        default:
            tableView.reloadData()
        }
    }
}

 
