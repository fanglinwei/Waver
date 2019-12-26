//
//  WaverView.swift
//  Waver
//
//  Created by 方林威 on 2019/12/25.
//  Copyright © 2019 方林威. All rights reserved.
//

import UIKit

class WaverView: UIView {
    typealias Callback = () -> Float
    
    // 波纹条数
    @IBInspectable var numberOfWaves: Int = 5
    
    // 波纹颜色
    @IBInspectable var waveColor: UIColor = #colorLiteral(red: 0.5098039216, green: 0.5568627451, blue: 1, alpha: 1)
    /// 主波纹 宽度
    @IBInspectable var mainWaveWidth: CGFloat = 2.0
    /// 辅助波纹 宽度
    @IBInspectable var decorativeWavesWidth: CGFloat = 1.0
    
    private(set) var waves: [CAShapeLayer] = []
    
    private var idleAmplitude: CGFloat = 0.01
    
    private var frequency: CGFloat = 1.2
    
    private var amplitude: CGFloat = 1.0
    
    private var density: CGFloat = 1.0
    
    private var phaseShift: CGFloat = -0.25
    
    private var phase: CGFloat = 0
    
    private lazy var displayLink = CADisplayLink(target: self, selector: #selector(displayLinkAction))
    
    private var callback: Callback?
    
    private var _numberOfWaves: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        reloadWaves()
    }
    
    deinit {
        displayLink.invalidate()
    }
}



extension WaverView {
    
    @objc
    private func displayLinkAction() {
        guard let level = callback?() else { return }
        
        phase += phaseShift
        amplitude = fmax(CGFloat(level), idleAmplitude)
        updateMeters()
    }
}
extension WaverView {
    
    func start() {
        displayLink.add(to: .current, forMode: .common)
    }
    
    func stop() {
        displayLink.invalidate()
    }
    
    func set(waverLevel callback:  @escaping Callback) {
        self.callback = callback
    }
    
    func reloadWaves() {
        if numberOfWaves != _numberOfWaves {
            waves = (0 ..< numberOfWaves).map { _ in
                CAShapeLayer.line()
            }
            
            layer.sublayers?.forEach { $0.removeFromSuperlayer() }
            waves.forEach { layer.addSublayer( $0 ) }
            _numberOfWaves = numberOfWaves
        }
        
        // 刷样式
        waves.enumerated().forEach {
            $1.lineWidth = $0 == 0 ? mainWaveWidth : decorativeWavesWidth
            let progress = 1.0 - CGFloat($0) / CGFloat(numberOfWaves)
            let multiplier = min(1.0, (progress / 3.0 * 2.0) + (1.0 / 3.0))
            $1.strokeColor = (waveColor.withAlphaComponent($0 == 0 ? 1.0 : 1.0 * multiplier * 0.4)).cgColor
        }
    }
}

extension WaverView {
    
    private func updateMeters() {
        UIGraphicsBeginImageContext(bounds.size)
        
        (0 ..< numberOfWaves).forEach {
            
            let path = UIBezierPath()
            // Progress is a value between 1.0 and -0.5, determined by the current wave idx, which is used to alter the wave's amplitude.
            let progress = 1.0 - CGFloat($0) / CGFloat(numberOfWaves)
            let normedAmplitude = (CGFloat(1.5) * progress - CGFloat(0.5)) * amplitude
            
            var x: CGFloat = 0
            while (x < waveWidth + density) {
                //Thanks to https://github.com/kevinzhow/Waver
                // We use a parable to scale the sinus wave, that has its peak in the middle of the view.
                let scaling: CGFloat = -pow(x / waveMid  - 1, 2) + 1
                let y = scaling * maxAmplitude * normedAmplitude * CGFloat(sinf(Float(2 * CGFloat.pi * (x / waveWidth) * frequency + phase))) + (waveHeight * 0.5)
                if (x==0) {
                    path.move(to: CGPoint(x: x, y: y))
                }
                else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
                
                x += density
            }
            
            waves[$0].path = path.cgPath
        }
        UIGraphicsEndImageContext()
    }
}

extension WaverView {
    
    private var waveHeight: CGFloat { bounds.height }
    
    private var waveWidth: CGFloat { bounds.width }
    
    private var waveMid: CGFloat { bounds.width * 0.5 }
    
    private var maxAmplitude: CGFloat { bounds.height - 4.0 }
}

extension CAShapeLayer {
    
    static func line() -> CAShapeLayer {
        let line = CAShapeLayer()
        line.lineCap = .butt
        line.lineJoin = .round
        line.fillColor = UIColor.clear.cgColor
        return line
    }
}
