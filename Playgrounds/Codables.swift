import UIKit

func jsonToObject<T: Decodable>(_ data: Data) -> T? {
    let decoder = JSONDecoder()
    do {
        return try decoder.decode(T.self, from: data)
    } catch {
        return nil
    }
}

func objectToJson<T: Encodable>(_ object: T) -> Data? {
    let encoder = JSONEncoder()
    do {
        return try encoder.encode(object)
    } catch {
        return nil
    }
}

enum DeduplicatorType {
    case dataset_delete_origin
    case device_deactivate_hash
    case device_truncate_dataset
    case none
}

struct DeduplicatorSpec: Equatable, Encodable {
    
    var type: DeduplicatorType = .dataset_delete_origin
    var name: String {
        get {
            return DeduplicatorSpec.enumToStrDict[type]!
        }
    }
    
    init(_ type: DeduplicatorType? = nil) {
        self.type = type ?? .dataset_delete_origin
    }
    
    init?(_ str: String) {
        if let type = DeduplicatorSpec.strToEnumDict[str] {
            self.type = type
        } else if let type = DeduplicatorSpec.altStrToEnumDict[str] {
            self.type = type
        } else {
            return nil
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case name
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
    }
    
    static let strToEnumDict: [String: DeduplicatorType] = [
        "org.tidepool.deduplicator.dataset.delete.origin": .dataset_delete_origin,
        "org.tidepool.deduplicator.device.deactivate.hash": .device_deactivate_hash,
        "org.tidepool.deduplicator.device.truncate.dataset": .device_truncate_dataset,
        "org.tidepool.deduplicator.none": .none,
    ]
    
    static let enumToStrDict: [DeduplicatorType: String] = [
        .dataset_delete_origin : "org.tidepool.deduplicator.dataset.delete.origin",
        .device_deactivate_hash : "org.tidepool.deduplicator.device.deactivate.hash",
        .device_truncate_dataset: "org.tidepool.deduplicator.device.truncate.dataset",
        .none: "org.tidepool.deduplicator.none"
    ]
    
    static let altStrToEnumDict: [String: DeduplicatorType] = [
        "org.tidepool.continuous.origin": .dataset_delete_origin,
        "org.tidepool.hash-deactivate-old": .device_deactivate_hash,
        "org.tidepool.truncate": .device_truncate_dataset,
        "org.tidepool.continuous": .none,
    ]
}

//extension DeduplicatorSpec: Encodable {
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(name, forKey: .name)
//    }
//}

func validateDedupStr(_ str: String) -> DeduplicatorSpec? {
    if let dedup = DeduplicatorSpec(str) {
        print(dedup.name)
        return dedup
    } else {
        print("Not a valid deduplicator!")
        return nil
    }
}

let spec1 = validateDedupStr("org.tidepool.deduplicator.device.deactivate.hash")
let spec2 = validateDedupStr("org.tidepool.hash-deactivate-old")
print("spec1==spec2: \(spec1==spec2)")
validateDedupStr("org.tidepool.anyoldstr")
let spec3 = DeduplicatorSpec()
print("spec1==spec3: \(spec1==spec3)")
print(DeduplicatorSpec("org.tidepool.hash-deactivate-old")?.name ?? "error!")
print("")

let encodeSpec1 = objectToJson(spec1)

func printDataAsStr(_ data: Data?) {
    guard let data = data else {
        print("nil")
        return
    }
    if let dataStr = String(data: data, encoding: .ascii) {
        print("data as ascii: \(dataStr)")
    } else {
        print("Not ascii!")
    }
}

printDataAsStr(encodeSpec1)
print("")


