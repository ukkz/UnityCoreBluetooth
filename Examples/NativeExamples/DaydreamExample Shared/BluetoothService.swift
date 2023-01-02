//
//  BluetoothService.swift
//  NativeExamples
//
//  Created by fuziki on 2021/07/04.
//

import CoreBluetooth
import UnityCoreBluetooth

class BluetoothService {
    static let shared = BluetoothService()

    private var characteristic: UnsafePointer<CBCharacteristic>?
    public var onUpdateValue: ((String) -> Void)?

    init() {
        ucb_manager_shared_register_onUpdateState { (state: UnsafePointer<CChar>?) in
            let state = String(cString: state!)
            print("update state: \(state)")
            if state != "poweredOn" { return }
            ucb_manager_shared_startScan()
        }
        ucb_manager_shared_register_onDiscoverPeripheral { (peripheral: UnsafePointer<CBPeripheral>) in
            let name = ucb_peripheral_getName(peripheral).flatMap { String(cString: $0) }!
            print("discovered peripheral: \(name)")
            if (name != "Daydream controller") && (name != "M5StickC") { return }
            ucb_manager_shared_stopScan()
            ucb_manager_shared_connectWithPeripheral(peripheral)
        }
        ucb_manager_shared_register_onConnectPeripheral { (peripheral: UnsafePointer<CBPeripheral>) in
            print("connected peripheral: \(peripheral)")
            ucb_peripheral_discoverServicesWithPeripheral(peripheral)
        }
        ucb_manager_shared_register_onDiscoverService { (service: UnsafePointer<CBService>) in
            let uuid = ucb_service_getUuid(service).flatMap { String(cString: $0) }!
            print("discovered peripheral: \(uuid)")
            if uuid != "FE55" { return }
            ucb_service_discoverCharacteristic(service)
        }
        ucb_manager_shared_register_onDiscoverCharacteristic { (characteristic: UnsafePointer<CBCharacteristic>) in
            let uuid = ucb_characteristic_getUuid(characteristic).flatMap { String(cString: $0) }!
            let usage = ucb_characteristic_getProperties(characteristic).flatMap { String(cString: $0) }!
            print("discovered characteristic: \(uuid), usage: \(usage)")
            if !usage.contains("notify") { return }
            BluetoothService.shared.characteristic = characteristic
            ucb_characteristic_setNotify(characteristic, true)
        }
        ucb_manager_shared_register_onUpdateValue { (_: UnsafePointer<CBCharacteristic>, ptr: UnsafePointer<UInt8>, l: CLong) in
            var res = ""
            for i in 0..<l {
                res += String(ptr.advanced(by: i).pointee, radix: 16)
            }
            BluetoothService.shared.onUpdateValue?(res)
            print("update value: \(res)")
        }
    }

    deinit {
        ucb_manager_shared_instantiate()
    }

    public func start() {
        ucb_manager_shared_instantiate()
    }

    public func write(data: Data) {
        data.withUnsafeBytes { (unsafeBytes: UnsafeRawBufferPointer) in
            let bytes: UnsafePointer<UInt8> = unsafeBytes.bindMemory(to: UInt8.self).baseAddress!
            let len = unsafeBytes.count
            ucb_characteristic_write(characteristic!, bytes, len)
        }
    }
}
