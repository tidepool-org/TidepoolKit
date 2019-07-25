//
//  DNSSrvRecordFetcher.swift
//  TidepoolKitUI
//
//  Created by Lennart Goedhart on 4/10/19.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import Foundation
import dnssd

class DNSSrvRecordFetcher {
    
    func doDNSSrvRecordLookup(completion: @escaping ([String]) -> (Void)) -> Bool {
        guard !dnsLookupInProgress else {
            NSLog("Ignoring call, DNS lookup is already in progress!")
            return false
        }
        dnsLookupInProgress = true
        var tidepoolHosts: [String] = []
        
        // do the lookup on a background thread...
        DispatchQueue.global(qos: .background).async {
            self.lookup("environments-srv.tidepool.org", completionHandler: {
                srvRecord, error in
                if error != nil {
                    LogError("DNS lookup error: \(error!)")
                }
                if let srvRecord = srvRecord {
                    tidepoolHosts.append(srvRecord.host)
                }
            }, timeoutInSeconds: 2)
            
            // send result back on main thread
            DispatchQueue.main.async {
                self.dnsLookupInProgress = false
                completion(tidepoolHosts)
            }
        }
        return true
    }
    private var dnsLookupInProgress = false
    
    typealias SRVLookupHandler = (SRVRecord?, String?) -> Void

    struct SRVRecord {
        let priority: UInt16
        let weight: UInt16
        let port: UInt16
        var host: String
        init(data: Data) {
            self.priority   = UInt16(bigEndian: data[0...2].withUnsafeBytes { $0.load(as: UInt16.self) })
            self.weight     = UInt16(bigEndian: data[2...4].withUnsafeBytes { $0.load(as: UInt16.self) })
            self.port       = UInt16(bigEndian: data[4...6].withUnsafeBytes { $0.load(as: UInt16.self) })
            
            // host is a byte array of format [size][ascii bytes][size][ascii bytes]...[null]
            // the size defines how many bytes ahead to read. The bytes represent each "chunk"
            // of the hostname. For example, "dev.tidepool.org", would be an array that looks like this (in hex):
            // 03 64 65 76 08 74 69 64 65 70 6F 6F 6C 03 6F 72 67 00
            self.host = String(data: data.subdata(in: 6..<data.endIndex), encoding: String.Encoding.ascii) ?? ""
            // Process the raw host data into a host string by replacing the "size" bytes and the null terminator with an ascii period,
            // then stripping the first and last period
            var pos = 0
            while( pos < Int(data.endIndex) - 6) {
                let index = self.host.index(self.host.startIndex, offsetBy: pos)
                let numChars = Int(self.host[index].asciiValue!)
                self.host.replaceSubrange(index...index, with: ".")
                pos+=(numChars+1)
            }
            self.host = String(self.host.dropFirst())
            self.host = String(self.host.dropLast())
        }
    }
    
    private func fdSet(_ fd: Int32?, set: inout fd_set) {
        
        if let fd = fd {
            
            let intOffset: Int32 = fd / 32
            let bitOffset: Int32 = fd % 32
            let mask: Int32 = 1 << bitOffset
            
            switch intOffset {
            case 0: set.fds_bits.0 = set.fds_bits.0 | mask
            case 1: set.fds_bits.1 = set.fds_bits.1 | mask
            case 2: set.fds_bits.2 = set.fds_bits.2 | mask
            case 3: set.fds_bits.3 = set.fds_bits.3 | mask
            case 4: set.fds_bits.4 = set.fds_bits.4 | mask
            case 5: set.fds_bits.5 = set.fds_bits.5 | mask
            case 6: set.fds_bits.6 = set.fds_bits.6 | mask
            case 7: set.fds_bits.7 = set.fds_bits.7 | mask
            case 8: set.fds_bits.8 = set.fds_bits.8 | mask
            case 9: set.fds_bits.9 = set.fds_bits.9 | mask
            case 10: set.fds_bits.10 = set.fds_bits.10 | mask
            case 11: set.fds_bits.11 = set.fds_bits.11 | mask
            case 12: set.fds_bits.12 = set.fds_bits.12 | mask
            case 13: set.fds_bits.13 = set.fds_bits.13 | mask
            case 14: set.fds_bits.14 = set.fds_bits.14 | mask
            case 15: set.fds_bits.15 = set.fds_bits.15 | mask
            case 16: set.fds_bits.16 = set.fds_bits.16 | mask
            case 17: set.fds_bits.17 = set.fds_bits.17 | mask
            case 18: set.fds_bits.18 = set.fds_bits.18 | mask
            case 19: set.fds_bits.19 = set.fds_bits.19 | mask
            case 20: set.fds_bits.20 = set.fds_bits.20 | mask
            case 21: set.fds_bits.21 = set.fds_bits.21 | mask
            case 22: set.fds_bits.22 = set.fds_bits.22 | mask
            case 23: set.fds_bits.23 = set.fds_bits.23 | mask
            case 24: set.fds_bits.24 = set.fds_bits.24 | mask
            case 25: set.fds_bits.25 = set.fds_bits.25 | mask
            case 26: set.fds_bits.26 = set.fds_bits.26 | mask
            case 27: set.fds_bits.27 = set.fds_bits.27 | mask
            case 28: set.fds_bits.28 = set.fds_bits.28 | mask
            case 29: set.fds_bits.29 = set.fds_bits.29 | mask
            case 30: set.fds_bits.30 = set.fds_bits.30 | mask
            case 31: set.fds_bits.31 = set.fds_bits.31 | mask
            default: break
            }
        }
    }
    
    private func lookup(_ domainName: String, completionHandler: @escaping SRVLookupHandler, timeoutInSeconds: Int = 10) {
        var mutableCompletionHandler = completionHandler // completionHandler needs to be mutable to be used as inout param
        let callback: DNSServiceQueryRecordReply = {
            (sdRef, flags, interfaceIndex, errorCode, fullname, rrtype, rrclass, rdlen, rdata, ttl, context) -> Void in
            // dereference completionHandler from pointer since we can't directly capture it in a C callback
            guard let completionHandlerPtr = context?.assumingMemoryBound(to: SRVLookupHandler.self) else { return }
            let completionHandler = completionHandlerPtr.pointee
            
            let data = Data(bytes: rdata!, count: Int(rdlen))
            let srvRecord = SRVRecord(data: data)
            
            completionHandler(srvRecord, nil)
        }
        
        var timeout:timeval = timeval(tv_sec: timeoutInSeconds, tv_usec: 0)
        // MemoryLayout<T>.size can give us the necessary size of the struct to allocate
        let serviceRef: UnsafeMutablePointer<DNSServiceRef?> = UnsafeMutablePointer.allocate(capacity:
            MemoryLayout<DNSServiceRef>.size)
        // pass completionHandler as context object to callback so that we have a way to pass the record result back to the caller
        DNSServiceQueryRecord(serviceRef, 0, 0, domainName, UInt16(kDNSServiceType_SRV), UInt16(kDNSServiceClass_IN), callback,
                              &mutableCompletionHandler)
        
        // This is necessary so we don't hang forever if there are no results
        let dnsSocketFd = DNSServiceRefSockFD(serviceRef.pointee)
        let numOfFd:Int32 = dnsSocketFd + 1
        var readSet:fd_set = fd_set(fds_bits: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
        
        fdSet(dnsSocketFd, set: &readSet)
        let status = select(numOfFd, &readSet, nil, nil, &timeout)
        
        // In case of a timeout, clean up
        if status == 0 {
            DNSServiceRefDeallocate(serviceRef.pointee)
            completionHandler(nil, "Timeout during select.")
            return
        }
        // In case of an error, clean up
        if status == -1 {
            
            let errString = String(utf8String: strerror(errno)) ?? "Unknown error code"
            let message = "Error during select, message = \(errno) (\(errString))"
            DNSServiceRefDeallocate(serviceRef.pointee)
            completionHandler(nil, message)
            return
        }
        
        DNSServiceProcessResult(serviceRef.pointee)
        DNSServiceRefDeallocate(serviceRef.pointee)
    }
}

