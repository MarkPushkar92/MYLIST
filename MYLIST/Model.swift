//
//  Model.swift
//  MYLIST
//
//  Created by Марк Пушкарь on 16.09.2022.
//

import Foundation

struct Place {
    var name: String
    var location: String
    var type: String
    var image: String
    
    
    static private let mockArray = [
         "Burger Heroes", "Kitchen", "Bonsai", "Дастархан",
         "Индокитай", "X.O", "Балкан Гриль", "Sherlock Holmes",
         "Speak Easy", "Morris Pub", "Вкусные истории",
         "Классик", "Love&Life", "Шок", "Бочка"
     ]
    
    static func getPlaces() -> [Place] {
        var places = [Place]()
        for place in mockArray {
            places.append(Place(name: place, location: "Unknown", type: "Restaurant", image: place))
        }
        return places
    }
}
