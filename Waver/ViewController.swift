//
//  ViewController.swift
//  Waver
//
//  Created by 方林威 on 2019/12/25.
//  Copyright © 2019 方林威. All rights reserved.
//

import UIKit
import AVKit

class ViewController: UIViewController {
    
    private lazy var recorder: AVAudioRecorder? = {
        let url = URL(fileURLWithPath: "/dev/null")
        // 录音参数设置
        let config: [String: Any] = [
                   // 编码格式 kAudioFormatLinearPCM
                   // kAudioFormatMPEG4AAC压缩格式能在显著减小文件的同时，保证音频的质量
                   AVFormatIDKey: NSNumber(value: Int32(kAudioFormatMPEG4AAC)),
                   // 采样率越高，文件越大，质量越好，反之，文件小，质量相对差一些，但是低于普通的音频，
                   // 人耳并不能明显的分辨出好坏。最终选取哪一种采样率，由我们的耳朵来判断。
                   // 建议使用标准的采样率，8000、16000、22050、44100
                   AVSampleRateKey: NSNumber(value: 16000),
                   // 线性采样位数  8、16、24、32
                   AVLinearPCMBitDepthKey : NSNumber(value: 16),
                   // 通道数
                   AVNumberOfChannelsKey: NSNumber(value: 2),
                   // 录音质量 AVAudioQuality.min.rawValue
                   AVEncoderAudioQualityKey: NSNumber(value: AVAudioQuality.max.rawValue)
               ]
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord)
            return try AVAudioRecorder(url: url, settings: config)
        } catch {
            return nil
        }
    } ()

    private lazy var waver = WaverView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRecorder()
        setup()
    }


    private func setup() {
        view.addSubview(waver)
        
        waver.set { [weak self]() -> Float in
            guard let self = self, let recorder = self.recorder else { return 0 }
            recorder.updateMeters()
            return pow(10, recorder.averagePower(forChannel: 0) / 40)
        }
        
        waver.start()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        waver.frame = CGRect(x: 0, y: view.bounds.midY, width: view.bounds.width, height: 100)
    }
    
    private func setupRecorder() {
        recorder?.prepareToRecord()
        recorder?.isMeteringEnabled = true
        recorder?.record()
    }
}

