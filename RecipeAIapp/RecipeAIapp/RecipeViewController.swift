//
//  RecipeViewController.swift
//  RecipeAIapp
//
//  Created by Sajan on 12/6/18.
//  Copyright © 2018 Sajan. All rights reserved.
//

import UIKit

class RecipeViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    struct Recipes: Decodable {
        let recipe_id : String
    }
    struct Response: Decodable {
        let count : Int
        let recipes : [Recipes]
    }
    
    // Model for recipe
    struct Properties: Decodable {
        let ingredients : Array<String>
        let source_url : String
    }
    struct Recipe: Decodable {
        let recipe: Properties
    }
    
    var API_KEY = "cda576c5540698abd22f332642c03323"
    //query is loaded with whatever comes from segue
    var query = "eggs,bellpeppers,tomatoes,salt"
    var recipe_id_value = ""
    var url = ""
    var recipeQuery = ""
    var ingredients: [String] = []
    
    // semaphore with count equal to zero is useful for synchronizing completion of work, in our case the renewal of auth token
    let sema1 = DispatchSemaphore.init(value: 0)
    let sema2 = DispatchSemaphore.init(value: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //query = recipeQuery
        queryDatabase()
    }
    
    func queryDatabase(){
        let search_url = URL(string: "https://www.food2fork.com/api/search?key=" + API_KEY + "&q=" + query + "&sort=r&page=1")!
        
        let search_task = URLSession.shared.dataTask(with: search_url) { (data, response, error) in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "Response Error")
                return
            }
            do {
                let response = try JSONDecoder().decode(Response.self, from: data)
                self.recipe_id_value += response.recipes[0].recipe_id
            } catch let parsingError {
                print("Error", parsingError)
            }
            // Signal that we are done
            self.sema1.signal()
        }
        search_task.resume()
        // Now we wait until the response block will send send a signal
        sema1.wait()
        //print("Operation 1 - end")
        getRecipe()
    }
    
    func getRecipe(){
        
        let recipe_url = URL(string: "https://www.food2fork.com/api/get?key=" + API_KEY + "&rId=" + recipe_id_value)!
        
        let recipe_task = URLSession.shared.dataTask(with: recipe_url) { (data, response, error) in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "Response Error")
                return
            }
            do{
                let response = try JSONDecoder().decode(Recipe.self, from: data)
                self.ingredients = response.recipe.ingredients
                for elem in self.ingredients { print(elem) }
                self.url = response.recipe.source_url
                print(self.url)
            } catch let parsingError {
                print("Error", parsingError)
            }
            self.sema2.signal()
        }
        recipe_task.resume()
        sema2.wait()
        //print("Operation 2 - end")
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        if cell == nil{
            cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
        }
        
        
        return cell!
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
