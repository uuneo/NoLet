//
// PttAudioManager.swift
//  pushme
//
//  Created by lynn on 2025/8/21.
//

import AVKit
import Defaults
import Opus


class PttAudioManager{
    
    static let shared = PttAudioManager()
    
    // MARK: - 播放器
    private let playerEngine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private let EQ = AVAudioUnitEQ(numberOfBands: 2)
    private var mixer: AVAudioMixerNode = AVAudioMixerNode()
    private let format = AVAudioFormat(standardFormatWithSampleRate: 48000, channels: 1)!
    
    
    // MARK: - 录音
    private let recordEngine = AVAudioEngine()
    private var oggWriter = OggOpusWriter()
    private var dataItem = DataItem()
    private var audioBuffer = Data()
    
    
   
    
    // MARK: - other
    private var callback:((Double, Double) -> Void)? = nil
    private var sessionInterrupted:((InterruptedType) -> Void)? = nil
    private var soundID: SystemSoundID = 0
    private var hasMicrophonePermission: Bool = false
    private init(){
        if !hasMicrophonePermission{
            self.requestMicrophonePermission()
        }
        // Band 1: 提升人声清晰度（2kHz）
        let band1 = EQ.bands[0]
        band1.filterType = .parametric
        band1.frequency = 2000
        band1.bandwidth = 1.5
        band1.gain = 10.0
        band1.bypass = false
        
        // Band 2: - 减少低频杂音（低切）
        let band2 = EQ.bands[1]
        band2.filterType = .highPass
        band2.frequency = 100
        band2.bandwidth = 0.5
        band2.bypass = false
        EQ.globalGain = Float(Defaults[.pttVoiceVolume] * 15)
        
        playerEngine.attach(playerNode)
        playerEngine.attach(EQ)
        playerEngine.connect(playerNode, to:  self.EQ, format: format)
        playerEngine.connect( self.EQ, to:  playerEngine.mainMixerNode, format: format)
        self.playerEngine.prepare()

        // 注册通知
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption(_:)),
            name: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance()
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
    func setInterrupted(callback: @escaping (InterruptedType)-> Void){
        self.sessionInterrupted = callback
    }
    
    
    func setCallback(callback: @escaping ( Double, Double) -> Void){
        self.callback = callback
    }
    
    // MARK: - player
    
    func play(filePath: URL) async throws {
        
        if !playerEngine.isRunning{
            try playerEngine.start()
        }
        
        let audioFile = try AVAudioFile(forReading: filePath)
        
        let asset = AVURLAsset(url: filePath)
        let duration = try? await asset.load(.duration)
        
        playerNode.removeTap(onBus: 0)
        playerNode.installTap(onBus: 0, bufferSize: 4096, format: nil) { buffer, when in
            
            var currentTime: Double {
                if let nodeTime = self.playerNode.lastRenderTime,
                   let playerTime = self.playerNode.playerTime(forNodeTime: nodeTime) {
                    let seconds = Double(playerTime.sampleTime) / playerTime.sampleRate
                    return seconds
                }
                return 0
            }
            
            
            let duration = CMTimeGetSeconds(duration ?? .zero)
            
            self.callback?(currentTime + duration * 0.05, duration)
        }
        
        playerNode.play()
        
        _ = await playerNode.scheduleFile(audioFile, at: nil, completionCallbackType: .dataPlayedBack)
        
        debugPrint("播放成功")
    }
    
    
    func stop() {
        self.playerNode.removeTap(onBus: 0)
        self.playerNode.stop()
    }
    
    
    func setVolume(_ value: Float){
        self.EQ.globalGain =  value
    }
    
    // MARK: - 录音
    func record() throws{
        
        let input = recordEngine.inputNode
        let format = input.inputFormat(forBus: 0)
        
        self.oggWriter = OggOpusWriter()
        self.dataItem = DataItem()
        self.oggWriter.inputSampleRate = Int32(format.sampleRate)
        self.oggWriter.begin(with: self.dataItem)
        
        input.removeTap(onBus: 0)
        guard format.sampleRate > 0 else { return }
        input.installTap(onBus: 0, bufferSize:  1024, format: format) { buffer, when in
            
            
            let elapsedTime = self.oggWriter.encodedDuration()
            
            if elapsedTime > 60{ return }
            
            self.processAndDisposeAudioBuffer(buffer)
            
            let mic = self.calculateLevelPercentage( from: buffer)
            self.callback?(mic, elapsedTime)
        }
        
        
        try recordEngine.start()
        print("🎤 开始录音（AGC 已启用）")
        
    }
    
    func end() -> Data?{
        guard recordEngine.isRunning else { return nil}
        self.recordEngine.inputNode.removeTap(onBus: 0)
        self.recordEngine.stop()
        
        if self.oggWriter.writeFrame(nil, frameByteCount: 0),
           self.oggWriter.encodedDuration() > 0.2{
            return self.dataItem.data()
        }
        
        return nil
        
    }
    
    private func processAndDisposeAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        
        guard let bufferData = self.conversionFloat32ToInt16Buffer(buffer) else { return }
        let buffer = bufferData.audioBufferList.pointee.mBuffers
        
        let sampleRate = 16000
        let frameDurationMs = 60
        let bytesPerSample = 2
        let encoderPacketSizeInBytes = sampleRate * frameDurationMs / 1000 * bytesPerSample
        
        
        let currentEncoderPacket = malloc(encoderPacketSizeInBytes)!
        defer { free(currentEncoderPacket) }
        
        var bufferOffset = 0
        
        while true {
            var currentEncoderPacketSize = 0
            
            while currentEncoderPacketSize < encoderPacketSizeInBytes {
                if self.audioBuffer.count != 0 {
                    let takenBytes = min(self.audioBuffer.count, encoderPacketSizeInBytes - currentEncoderPacketSize)
                    if takenBytes != 0 {
                        self.audioBuffer.withUnsafeBytes { rawBytes -> Void in
                            let bytes = rawBytes.baseAddress!.assumingMemoryBound(to: Int8.self)
                            
                            memcpy(currentEncoderPacket.advanced(by: currentEncoderPacketSize), bytes, takenBytes)
                        }
                        self.audioBuffer.replaceSubrange(0 ..< takenBytes, with: Data())
                        currentEncoderPacketSize += takenBytes
                    }
                } else if bufferOffset < Int(buffer.mDataByteSize) {
                    let takenBytes = min(Int(buffer.mDataByteSize) - bufferOffset, encoderPacketSizeInBytes - currentEncoderPacketSize)
                    if takenBytes != 0 {
                        memcpy(currentEncoderPacket.advanced(by: currentEncoderPacketSize), buffer.mData?.advanced(by: bufferOffset), takenBytes)
                        
                        bufferOffset += takenBytes
                        currentEncoderPacketSize += takenBytes
                    }
                } else {
                    break
                }
            }
            
            if currentEncoderPacketSize < encoderPacketSizeInBytes {
                self.audioBuffer.append(currentEncoderPacket.assumingMemoryBound(to: UInt8.self), count: currentEncoderPacketSize)
                break
            } else {
                
                self.oggWriter.writeFrame(currentEncoderPacket.assumingMemoryBound(to: UInt8.self), frameByteCount: UInt(currentEncoderPacketSize))
            }
        }
        
    }
    
    
    func conversionFloat32ToInt16Buffer(_ buffer: AVAudioPCMBuffer) -> AVAudioPCMBuffer? {
        guard let format = AVAudioFormat(commonFormat: .pcmFormatInt16,
                                         sampleRate: buffer.format.sampleRate,
                                         channels: buffer.format.channelCount,
                                         interleaved: true) else {
            return nil
        }
        
        let frameLength = buffer.frameLength
        guard let convertedBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameLength) else {
            return nil
        }
        convertedBuffer.frameLength = frameLength
        
        // 获取输入 float32 样本指针
        guard let sourcePointer = buffer.floatChannelData?[0] else {
            return nil
        }
        
        // 获取目标 int16 样本指针
        guard let destinationPointer = convertedBuffer.int16ChannelData?[0] else {
            return nil
        }
        
        for index in 0..<Int(frameLength) {
            let floatSample = min(max(sourcePointer[index], -1.0), 1.0)
            destinationPointer[index] = Int16(clamping: Int(floatSample * 32767.0))
        }
        
        return convertedBuffer
    }
    
    // MARK: - OTHER
    
    func playTips(_ fileName: TipsSound, fileExtension:String = "aac", complete:(()->Void)? = nil) {
        self.setCategory(true, .playAndRecord, mode: .default)
        guard let url = Bundle.main.url(forResource: fileName.rawValue, withExtension: fileExtension) else { return }
        // 先释放之前的 SystemSoundID（如果有），避免内存泄漏或重复播放
        AudioServicesDisposeSystemSoundID(self.soundID)
        
        AudioServicesCreateSystemSoundID(url as CFURL, &self.soundID)
        // 播放音频，播放完成后执行回调
        AudioServicesPlaySystemSoundWithCompletion(self.soundID) {
            // 释放资源
            AudioServicesDisposeSystemSoundID(self.soundID)
            // 重置播放状态
            self.soundID = 0
            complete?()
        }
        
    }
    
    // MARK: - OTHER
    
    func calculateLevelPercentage(from buffer: AVAudioPCMBuffer) -> Double {
        guard let channelData = buffer.floatChannelData else {
            return 0.0
        }
        
        let channelDataValue = channelData.pointee
        // 4
        let channelDataValueArray = stride(
            from: 0,
            to: Int(buffer.frameLength),
            by: buffer.stride)
            .map { channelDataValue[$0] }
        
        // 5
        let rms = sqrt(channelDataValueArray.map {
            return $0 * $0
        }
            .reduce(0, +) / Float(buffer.frameLength))
        
        // 6
        let avgPower = 20 * log10(rms)
        // 7
        let meterLevel = self.scaledPower(power: avgPower)
        
        return Double(meterLevel)
        
    }
    
    func scaledPower(power: Float) -> Float {
        // 1. 避免 NaN 或 Inf
        guard power.isFinite else {
            return 0.0
        }
        
        // 参考的最小分贝值（静音阈值）
        let minDb: Float = -80.0
        
        // 2. 小于阈值直接当作静音
        if power < minDb {
            return 0.0
        }
        
        // 3. 如果超过 1.0（非常大声），直接归一化到 1.0
        if power >= 1.0 {
            return 1.0
        }
        
        // 4. 按比例线性映射到 0~1
        return (abs(minDb) - abs(power)) / abs(minDb)
    }
    
    func setCategory(_ active: Bool = true,
                     _ category: AVAudioSession.Category = .playback,
                     mode: AVAudioSession.Mode = .default){
        
        let session = AVAudioSession.sharedInstance()
        
        do{
            if active{
                if category == .playAndRecord{
                    try session.setCategory(category,
                                            mode: mode,
                                            options: [
                                                .defaultToSpeaker,
                                                .allowBluetooth,
                                                .allowBluetoothA2DP
                                            ])
                }else{
                    try session.setCategory(category,
                                            mode: mode,
                                            options: [ .allowBluetooth, .allowBluetoothA2DP ] )
                }
                
            }
            
            
            
            try session.setActive(active, options: .notifyOthersOnDeactivation)
            try session.overrideOutputAudioPort(.speaker)
            
            if let inputs = AVAudioSession.sharedInstance().availableInputs {
                if let bluetooth = inputs.first(where: { $0.portType == .bluetoothHFP }) {
                    try AVAudioSession.sharedInstance().setPreferredInput(bluetooth)
                }
            }
        }catch{
            Log.error("设置setActive失败：",error.localizedDescription)
        }
    }
    
    func requestMicrophonePermission() {
        
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            self.hasMicrophonePermission = granted
        }
    }
    
    @objc private func handleInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        
        switch type {
        case .began:
            // 中断开始，比如电话进来 -> 暂停播放
            print("🔴 音频被打断（开始）")
            sessionInterrupted?(.begin)
            // 在这里暂停播放器
            return
            
        case .ended:
            // 中断结束，可以恢复播放
            print("🟢 音频打断结束")
            // 系统会告诉你是否可以恢复
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    // 恢复播放
                    print("✅ 可以恢复播放")
                    sessionInterrupted?(.resume)
                    return
                }
            }
            sessionInterrupted?(.end)
            return
        @unknown default:
            sessionInterrupted?(.other)
           
            return
        }
    }
    
}


enum TipsSound: String{
    case pttconnect
    case pttnotifyend
    case cbegin
    case bottle
    case qrcode
}

enum InterruptedType{
    case begin
    case end
    case resume
    case other
}
