/*
 * Copyright (c) 2019, Tidepool Project
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the associated License, which is identical to the BSD 2-Clause
 * License as published by the Open Source Initiative at opensource.org.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the License for more details.
 *
 * You should have received a copy of the License along with this program; if
 * not, you can obtain one from Tidepool Project at tidepool.org.
 */

import XCTest
@testable import TidepoolKit

class TPKitTests10UserData: TPKitTestsBase {

    func test11GetDataset() {
        let expectation = self.expectation(description: "Dataset fetch/create successful")
        let tpKit = getTpKitSingleton()
        NSLog("\(#function): starting with logout...")
        // next, log in, and then try configuring upload id: this will fetch a current id, or create one if a current id does not exist. Note: there is no way to force delete of an upload id, so a new account would be needed to test the create!
        NSLog("\(#function): next calling ensureLogin...")
        ensureLogin() {
            session in
            // first test with default dataset...
            tpKit.getDataset(user: session.user) {
                result in
                if case .failure(let error) = result {
                     XCTFail("failed to get dataset, error: \(error)")
                }
                
                // second, test with test dataset...
                let testDataSet = TPDataset(client: TPDatasetClient(name: "org.tidepool.tidepoolkittest", version: "1.0.0"), deduplicator: TPDeduplicator(type: .dataset_delete_origin))
                tpKit.getDataset(dataSet:testDataSet, user: session.user) {
                    result in
                    if case .failure(let error) = result {
                        XCTFail("failed to get dataset, error: \(error)")
                    }
                    expectation.fulfill()
                }
            }
        }
        // Wait 20.0 seconds until expectation has been fulfilled (sometimes staging takes almost 10 seconds). If not, fail.
        waitForExpectations(timeout: 20.0, handler: nil)
    }

    let kOneWeekTimeInterval: TimeInterval = 60*60*24*7
    func test12GetUserData() {
        let expectation = self.expectation(description: "Fetch of user data successful")
        let tpKit = getTpKitSingleton()
        // first, ensure we are logged in, and then ...
        NSLog("\(#function): next calling ensureLogin...")
        ensureLogin() {
            session in
            XCTAssert(tpKit.isLoggedIn())
            let end = Date()
            let start = end.addingTimeInterval(-self.kOneWeekTimeInterval)
            tpKit.getUserData(session.user, startDate: start, endDate: end) {
                result in
                expectation.fulfill()
                switch result {
                case .failure:
                    NSLog("\(#function) failed user data fetch!")
                    XCTFail()
                case .success(let userDataArray):
                    NSLog("\(#function) fetched \(userDataArray.count) items!")
                }
            }
        }
        // Wait 20.0 seconds until expectation has been fulfilled (sometimes staging takes almost 10 seconds). If not, fail.
        waitForExpectations(timeout: 20.0, handler: nil)
    }

    func test13_1_DeleteUserData() {
        let expectation = self.expectation(description: "Delete of user data successful")
        let tpKit = getTpKitSingleton()
        // first, ensure we are logged in, and then ...
        NSLog("\(#function): next calling ensureLogin...")
        ensureDataset() {
            dataset, session in
            XCTAssert(tpKit.isLoggedIn())
            let end = Date()
            let start = end.addingTimeInterval(-self.kOneWeekTimeInterval)
            tpKit.getUserData(session.user, startDate: start, endDate: end) {
                result in
                switch result {
                case .failure:
                    NSLog("\(#function) failed user data fetch!")
                    XCTFail()
                case .success(let userDataArray):
                    let itemCount = userDataArray.count
                    NSLog("\(#function) fetched \(itemCount) items!")
                    guard itemCount > 0 else {
                        NSLog("\(#function) no data to delete, pass test!")
                        expectation.fulfill()
                        return
                    }
                    // convert existing TPDeviceData items into TPDeleteItems
                    var deleteItems: [TPDeleteItem] = []
                    for item in userDataArray {
                        if let deleteItem = TPDeleteItem(item) {
                            deleteItems.append(deleteItem)
                        }
                    }
                    // and delete...
                    tpKit.deleteUserData(dataset, samples: deleteItems) {
                        result in
                        expectation.fulfill()
                        switch result {
                        case .failure:
                            NSLog("\(#function) failed delete user data!")
                            XCTFail()
                        case .success:
                            NSLog("\(#function) delete succeeded!")
                        }
                    }
                }
            }
        }
        // Wait 20.0 seconds until expectation has been fulfilled (sometimes staging takes almost 10 seconds). If not, fail.
        waitForExpectations(timeout: 20.0, handler: nil)
    }

    /// Test passing a bunch of origin ids, where data doesn't exist...
    func test13_2_DeleteUserData() {
        let expectation = self.expectation(description: "Delete of user data successful")
        let tpKit = getTpKitSingleton()
        // first, ensure we are logged in, and then ...
        NSLog("\(#function): next calling ensureLogin...")
        ensureDataset() {
            dataset, session in
            XCTAssert(tpKit.isLoggedIn())
            var deleteItemArray: [TPDeleteItem] = []
            for _ in 1...5 {
                let id = UUID().uuidString
                if let deleteItem = TPDeleteItem(originId: id) {
                    deleteItemArray.append(deleteItem)
                }
            }
            XCTAssert(deleteItemArray.count == 5)
            for _ in 1...5 {
                let id = UUID().uuidString
                let origin = TPDataOrigin(id: id)
                if let deleteItem = TPDeleteItem(origin: origin) {
                    deleteItemArray.append(deleteItem)
                }
            }
            XCTAssert(deleteItemArray.count == 10)
            tpKit.deleteUserData(dataset, samples: deleteItemArray) {
                result in
                expectation.fulfill()
                switch result {
                case .failure:
                    NSLog("\(#function) failed delete user data!")
                    XCTFail()
                case .success:
                    NSLog("\(#function) delete succeeded!")
                }
            }
        }
        // Wait 20.0 seconds until expectation has been fulfilled. If not, fail.
        waitForExpectations(timeout: 20.0, handler: nil)
    }

    let TestCbgOriginPayload1 = TPDataPayload([
        "sourceRevision": [
            "source": [
                "name": "JoJo Loop",
                "bundleIdentifier": "com.8Q7535T65L.loopkit.Loop"
            ],
            "productType": "iPhone10,1",
            "operatingSystemVersion": "12.3.0",
            "version": "55"
        ],
        "device": [
            "udiDeviceIdentifier": "00386270000385",
            "name": "CGMBLEKit",
            "softwareVersion": "20.0",
            "model": "G6",
            "manufacturer": "Dexcom"
        ]
    ])

    let TestCbgPayload1 = TPDataPayload([
        "HKMetadataKeySyncIdentifier" : "80XBG2972576",
        "HKMetadataKeySyncVersion" : 1,
        "com.loudnate.GlucoseKit.HKMetadataKey.GlucoseIsDisplayOnly" : 0
    ])

    let TestCbgOriginPayload2 = TPDataPayload([
        "sourceRevision" : [
            "operatingSystemVersion" : "12.2.0",
            "source" : [
                "bundleIdentifier" : "com.dexcom.G6",
                "name" : "Dexcom G6"
            ],
            "productType" : "iPhone10,6",
            "version" : "15631"
        ]
    ])

    let TestCbgPayload2 = TPDataPayload([
        "Trend Arrow" : "Flat",
        "Transmitter Time" : "2019-04-06T23:55:06.000Z",
        "HKDeviceName" : "10386270000221",
        "Trend Rate" : -0.10000000000000001,
        "HKTimeZone" : "America/Los_Angeles",
        "Status" : "IN_RANGE"
    ])

    func test14PostCbgDataItem() {
        let expectation = self.expectation(description: "Post of user cbg data successful")
        let tpKit = getTpKitSingleton()
        // first, ensure we are logged in, and then ...
        NSLog("\(#function): next calling ensureLogin...")
        ensureDataset() {
            dataset, session in
            XCTAssert(tpKit.isLoggedIn())
            let newId = UUID.init().uuidString
            let origin = TPDataOrigin(id: newId, name: "org.tidepool.tidepoolKitTest", type: .service, payload: self.TestCbgOriginPayload2)!
            let payload = self.TestCbgPayload2
            guard let cbgSample = TPDataCbg(time: Date(), value: 90, units: .milligramsPerDeciliter) else {
                NSLog("\(#function) failed to create cbg sample!")
                XCTFail()
                return
            }
            cbgSample.origin = origin
            cbgSample.payload = payload
            NSLog("created TPDataCbg: \(cbgSample)")
            tpKit.putUserData(dataset, samples: [cbgSample]) {
                result  in
                switch result {
                case .failure:
                    NSLog("\(#function) failed user data upload!")
                    XCTFail()
                case .success:
                    NSLog("\(#function) upload succeeded!")
                    expectation.fulfill()
                }
            }
        }
        // Wait 20.0 seconds until expectation has been fulfilled (sometimes staging takes almost 10 seconds). If not, fail.
        waitForExpectations(timeout: 20.0, handler: nil)
    }

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
        let expectation = self.expectation(description: "Post of user carb data successful")
        let tpKit = getTpKitSingleton()
        // first, ensure we are logged in, and then ...
        NSLog("\(#function): next calling ensureLogin...")
        ensureDataset() {
            dataset, session in
            XCTAssert(tpKit.isLoggedIn())

            let foodSample = self.createCarbItem(30)
            XCTAssertNotNil(foodSample, "\(#function) failed to create food sample!")

            tpKit.putUserData(dataset, samples: [foodSample!]) {
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
        foodSample?.origin = origin
        NSLog("created TPDataFood: \(foodSample!)")
        return foodSample
    }

    func test17CreateFoodDataItem() {
        let foodSample = createFoodItem()
        XCTAssertNotNil(foodSample, "\(#function) failed to create food sample!")
        let asDict = foodSample!.rawValue
        NSLog("serialized as dictionary: \(asDict)")
    }

    func test18PostFoodDataItem() {
        let expectation = self.expectation(description: "Post of user carb data successful")
        let tpKit = getTpKitSingleton()
        // first, ensure we are logged in, and then ...
        NSLog("\(#function): next calling ensureLogin...")
        ensureDataset() {
            dataset, session in
            XCTAssert(tpKit.isLoggedIn())
            
            let foodSample = self.createFoodItem()
            XCTAssertNotNil(foodSample, "\(#function) failed to create food sample!")
            
            tpKit.putUserData(dataset, samples: [foodSample!]) {
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


}
