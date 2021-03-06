//
//  NTPClient.swift
//  CorrectedTime
//
//  Created by 倪僑德 on 2021/1/26.
//

import Foundation

protocol NTPSocketClientSpec {

    init(host: String)
    
    var isConnected: Bool { get }
    
    func start(then handler: ((_ success: Bool) -> Void)?)
    func listen(then handler: @escaping (_ data: Data) -> Void)
    func close()
    func send(packet: @escaping () -> Data)
}

extension NWSocketClient : NTPSocketClientSpec {}
extension CSocketClient : NTPSocketClientSpec {}

final class NTPClient {
    
    private let socketClient: NTPSocketClientSpec
    private var hasUnsendPacket: Bool = false
    
    private var correctedTime: CorrectedTime?
    private var lastBootTime: TimeInterval?
    
    private let operationQueue: DispatchQueue = .init(
        label: "time.beanfun.com.NTPTimeSync",
        qos: .utility
    )
    private var retryCount: Int = 0
    
    init() {
        if #available(iOS 12, *) {
            socketClient = NWSocketClient(host: "time.asia.apple.com")
        } else {
            socketClient = CSocketClient(host: "time.asia.apple.com")
        }
    }
    
    func start() {
        operationQueue.async { [weak self] in
            self?.socketClient.start {connectSuccess in
                if connectSuccess {
                    guard self?.hasUnsendPacket == true else { return }
                    self?.send()
                } else {
                    self?.socketClient.close()
                    let retryCount = self?.retryCount ?? 0
                    let deadline: DispatchTime = .now() + .seconds(retryCount * 2 + 1)
                    DispatchQueue
                        .global()
                        .asyncAfter(deadline: deadline) {
                            self?.start()
                        }
                }
            }
        }
    }
    
    func close() {
        operationQueue.async { [weak self] in
            self?.socketClient.close()
        }
    }
    
    func getTime() -> Date? {
        guard let correctedTime = correctedTime else { return nil }
        return correctedTime.currentTime
    }
    
    func listenNewCorrectedTime(then handler: @escaping (_ result: Result<CorrectedTime, Error>) -> Void) {
        socketClient.listen { [weak self] data in
            self?.operationQueue.async {
                guard let self = self else { return }
                guard let packet = try? NTPPacket(
                        data: data,
                        destinationTime: CorrectedTime.currentTime()
                ) else {
                    return handler(.failure(NTPError(code: 500, message: "packet decode fail")))
                }
                
                // [ ( T2- T1 ) + ( T3 – T4 ) ] / 2
                let offset = ((packet.receiveTime - packet.originTime)
                                + (packet.transmitTime - packet.destinationTime)) / 2
                
                let newCorrectedTime: CorrectedTime = .init(
                    offset: offset,
                    originBoottime: self.lastBootTime ?? CorrectedTime.getCurrentBoottime()
                )
                
                DispatchQueue.main.async {
                    self.correctedTime = newCorrectedTime
                }
                handler(.success(newCorrectedTime))
            }
        }
    }
    
    func send() {
        operationQueue.async { [weak self] in
            guard self?.socketClient.isConnected == true else {
                self?.hasUnsendPacket = true
                return
            }
            self?.socketClient.send(packet: {
                var packet = NTPPacket()
                let data = packet.prepareToSend()
                self?.lastBootTime = CorrectedTime.getCurrentBoottime()
                return data
            })
        }
    }
}
