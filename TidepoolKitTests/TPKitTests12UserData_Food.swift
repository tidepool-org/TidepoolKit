//
//  TPKitTests12UserData_Food.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import XCTest
import TidepoolKit

class TPKitTests12UserData_Food: TPKitTestsBase {

    func createCarbItem(_ net: Double) -> TPDataFood? {
        let newId = UUID.init().uuidString
        let origin = TPDataOrigin(id: newId, name: "org.tidepool.tidepoolKitTest", type: .service, payload: nil)!
        let foodSample = TPDataFood(time: Date(), carbohydrate: net)
        foodSample?.origin = origin
        XCTAssertNotNil(foodSample, "\(#function) failed to create food sample!")
        NSLog("created TPDataFood: \(foodSample!)")
        return foodSample
    }
    
    func test15CreateCarbDataItem() {
        let foodSample = createCarbItem(30)
        XCTAssertNotNil(foodSample, "\(#function) failed to create food sample!")
        let asDict = foodSample!.rawValue
        NSLog("serialized as dictionary: \(asDict)")
    }
    
    func test16PostCarbDataItem() {
        let expectation = self.expectation(description: "post of user carb data completed")
        let tpKit = getTpKitSingleton()
        // first, ensure we are logged in, and then ...
        NSLog("\(#function): next calling ensureLogin...")
        ensureDataset() {
            dataset, session in
            XCTAssert(tpKit.isLoggedIn())

            let foodSample = self.createCarbItem(30)
            XCTAssertNotNil(foodSample, "\(#function) failed to create food sample!")

            tpKit.putData(samples: [foodSample!], into: dataset) {
                result  in
                expectation.fulfill()
                switch result {
                case .failure:
                    NSLog("\(#function) failed user data upload!")
                    XCTFail()
                case .success:
                    NSLog("\(#function) upload succeeded!")
                }
            }
        }
        // Wait 20.0 seconds until expectation has been fulfilled (sometimes staging takes almost 10 seconds). If not, fail.
        waitForExpectations(timeout: 20.0, handler: nil)
    }

    func createCookieIngredient(count: Double) -> TPDataIngredient {
        let result = TPDataIngredient(
                amount: TPDataAmount(value: count, units: "cookies"),
                brand: "Maxine's Heavenly",
                code: "8 53026 00504 3",
                ingredients: [
                    TPDataIngredient(
                        ingredients: [
                            TPDataIngredient(name: "oats")!,
                            TPDataIngredient(name: "oat flour")!,
                            TPDataIngredient(name: "oat fiber")!],
                        name: "Gluten Free Oat Blend")!,
                    TPDataIngredient(name: "Palm Fruit Oil")!,
                    TPDataIngredient(
                        ingredients: [
                            TPDataIngredient(name: "dry roasted peanuts")!],
                        name: "Peanut Butter")!,
                    TPDataIngredient(
                        ingredients: [
                            TPDataIngredient(name: "cane sugar")!,
                            TPDataIngredient(name: "unsweetened chocolate")!,
                            TPDataIngredient(name: "cocoa butter")!],
                        name: "Semi-sweet Chocolate Chunks")!,
                    TPDataIngredient(name: "Organic Coconut Sugar")!,
                    TPDataIngredient(name: "Organic Coconut Nectar")!,
                    TPDataIngredient(name: "Organic Coconut White Rice Flour")!,
                    TPDataIngredient(name: "Dates")!,
                    TPDataIngredient(name: "Arrowroot Flour")!,
                    TPDataIngredient(name: "Dry Roasted Peanuts")!,
                    TPDataIngredient(name: "Water")!,
                    TPDataIngredient(name: "Flaxseed")!,
                    TPDataIngredient(name: "Organic Gum Acacia")!,
                    TPDataIngredient(name: "Sunflower Lecithin")!,
                    TPDataIngredient(name: "Sea Salt")!,
                    TPDataIngredient(name: "Baking Soda")!
              ],
                name: "Peanut Butter Chocolate Chip Cookies",
                nutrition: TPDataNutrition(energy: TPDataEnergy(value: 120*count, units: .calories), carbohydrate: TPDataCarbohydrate(net: 14*count, dietaryFiber: 2*count, sugars: 6*count, total: 14*count), fat: TPDataFat(total: 7*count), protein: TPDataProtein(total: 2*count)))
        return result!
    }
    
    func createFoodItem() -> TPDataFood? {
        let carbs = TPDataCarbohydrate(net: 100, dietaryFiber: 10, sugars: 10, total: 100)
        let energy = TPDataEnergy(value: 50, units: .kilocalories)
        let fat = TPDataFat(total: 10)
        let protein = TPDataProtein(total: 15)
        let nutrition = TPDataNutrition(energy: energy, carbohydrate: carbs, fat: fat, protein: protein)
        XCTAssertNotNil(nutrition, "\(#function) failed to create nutrition struct!")
        // add ingredients
        let cookies = createCookieIngredient(count: 2)
        let ingredients = [
            cookies,
            TPDataIngredient(amount: TPDataAmount(value: 1, units: "pint"), name: "milk")!]
        let foodSample = TPDataFood(time: Date(), name: "cookies and milk", meal: .other, mealOther: "brunch", nutrition: nutrition!, ingredients: ingredients)
        XCTAssertNotNil(foodSample, "\(#function) failed to create food sample!")
        // add in origin...
        let newOriginId = UUID.init().uuidString
        let origin = TPDataOrigin(id: newOriginId, name: "org.tidepool.tidepoolKitTest", type: .service, payload: nil)!
        foodSample.origin = origin
        // add in location...
        let latitude = TPDataLatitude(43.0745000)
        let longitude = TPDataLongitude(-73.1547300)
        let elevation = TPDataElevation(value: 50.0, units: .meters)
        let hAccuracy = TPDataHorizontalAccuracy(value: 1.0, units: .meters)
        let vAccuracy = TPDataVerticalAccuracy(value: 1.0, units: .meters)
        let gps = TPDataGPS(latitude: latitude, longitude: longitude, elevation: elevation, floor: nil, horizontalAccuracy: hAccuracy, verticalAccuracy: vAccuracy)
        let location = TPDataLocation(name: "Arlington, Vermont", gps: gps)
        foodSample.location = location
        // add in association
        let association = TPDataAssociation(type: .url, url: "http://food-and-drink-pictures.blogspot.com/2010/04/chocolate-chip-cookies-with-milk.html", reason: "testing")
        foodSample.associations = [association!]
        NSLog("created TPDataFood: \(foodSample)")
        return foodSample
    }

    func test17CreateFoodDataItem() {
        let food = createFoodItem()
        XCTAssertNotNil(food, "\(#function) failed to create food sample!")
        let food1 = food!
        let food1Dict = food1.rawValue
        NSLog("serialized as dictionary: \(food1Dict)")
        // test round trip serialization
        let food2 = TPDataFood(rawValue: food1Dict)!
        XCTAssertTrue(stringAnyDictDiff(a1: food1Dict, a2: food2.rawValue))
        // test copy...
        let food3 = TPDataFood(time: food2.time!, name: food2.name, brand: food2.brand, code: food2.code, meal: food2.meal, mealOther: food2.mealOther, amount: food2.amount, nutrition: food2.nutrition, ingredients: food2.ingredients)
        food3.origin = food1.origin
        food3.location = food1.location
        food3.associations = food1.associations
        XCTAssertTrue(stringAnyDictDiff(a1: food1Dict, a2: food3.rawValue))
    }

    func test18_1_PostFoodDataItem() {
        let expectation = self.expectation(description: "post of user carb data completed")
        let tpKit = getTpKitSingleton()
        // first, ensure we are logged in, and then ...
        NSLog("\(#function): next calling ensureLogin...")
        ensureDataset() {
            dataset, session in
            XCTAssert(tpKit.isLoggedIn())
            
            let foodSample = self.createFoodItem()
            XCTAssertNotNil(foodSample, "\(#function) failed to create food sample!")
            
            tpKit.putData(samples: [foodSample!], into: dataset) {
                result  in
                expectation.fulfill()
                switch result {
                case .failure:
                    NSLog("\(#function) failed user data upload!")
                    XCTFail()
                case .success:
                    NSLog("\(#function) upload succeeded!")
                }
            }
        }
        // Wait 20.0 seconds until expectation has been fulfilled (sometimes staging takes almost 10 seconds). If not, fail.
        waitForExpectations(timeout: 20.0, handler: nil)
    }

    func test18_1_RoundTripFoodDataItem() {
        let expectation = self.expectation(description: "post/get of user carb data completed")
        let tpKit = getTpKitSingleton()
        // first, ensure we are logged in, and then ...
        NSLog("\(#function): next calling ensureLogin...")
        ensureDataset() {
            dataset, session in
            XCTAssert(tpKit.isLoggedIn())
            
            let foodSample = self.createFoodItem()
            XCTAssertNotNil(foodSample, "\(#function) failed to create food sample!")
            
            tpKit.putData(samples: [foodSample!], into: dataset) {
                result  in
                switch result {
                case .failure:
                    NSLog("\(#function) failed user data upload!")
                    XCTFail()
                case .success:
                    NSLog("\(#function) upload succeeded!")
                    let end = Date()
                    let start = end.addingTimeInterval(-60) // check samples in last minute...
                    tpKit.getData(for: session.user, startDate: start, endDate: end, objectTypes: "food") {
                        result in
                        expectation.fulfill()
                        switch result {
                        case .failure:
                            NSLog("\(#function) failed user data food fetch!")
                            XCTFail()
                        case .success(let userDataArray):
                            NSLog("\(#function) fetched \(userDataArray.count) items!")
                            let referenceFoodDict = foodSample!.rawValue
                            var foundSameItem = false
                            for item in userDataArray {
                                if let fetchedFood = item as? TPDataFood {
                                    var fetchedFoodRawValue = fetchedFood.rawValue
                                    fetchedFoodRawValue["id"] = nil
                                    if self.stringAnyDictDiff(a1: referenceFoodDict, a2: fetchedFoodRawValue) {
                                        foundSameItem = true
                                        break
                                    }
                                }
                            }
                            XCTAssertTrue(foundSameItem, "Same food item not found!")
                        }
                    }
                }
            }
        }
        // Wait 20.0 seconds until expectation has been fulfilled (sometimes staging takes almost 10 seconds). If not, fail.
        waitForExpectations(timeout: 20.0, handler: nil)
    }

}
