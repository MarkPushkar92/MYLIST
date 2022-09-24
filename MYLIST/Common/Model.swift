//
//  Model.swift
//  MYLIST
//
//  Created by Марк Пушкарь on 16.09.2022.
//

import UIKit

struct Place {
    var name: String
    var location: String?
    var type: String?
    var image: UIImage?
    var restarauntImage: String?
    
    
    static private let mockArray = [
         "Burger Heroes", "Kitchen", "Bonsai", "Дастархан",
         "Индокитай", "X.O", "Балкан Гриль", "Sherlock Holmes",
         "Speak Easy", "Morris Pub", "Вкусные истории",
         "Классик", "Love&Life", "Шок", "Бочка"
     ]
    
    static func getPlaces() -> [Place] {
        var places = [Place]()
        for place in mockArray {
            places.append(Place(name: place, location: "Unknown", type: "Restaurant", image: nil, restarauntImage: place))
        }
        return places
    }
}
