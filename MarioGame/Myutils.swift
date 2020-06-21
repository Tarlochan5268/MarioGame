//
//  MyUtils.swift
//  IOSZombieGame
//
//  Created by Das Tarlochan Preet Singh on 2020-06-10.
//  Copyright © 2020 Tarlochan5268. All rights reserved.
//
import Foundation
import CoreGraphics


#if !(arch(x86_64) || arch(arm64))
func atan2(y: CGFloat, x: CGFloat) -> CGFloat {
 return CGFloat(atan2f(Float(y), Float(x)))
}
func sqrt(a: CGFloat) -> CGFloat {
 return CGFloat(sqrtf(Float(a)))
}
#endif


import AVFoundation
var backgroundMusicPlayer: AVAudioPlayer!
func playBackgroundMusic(filename: String) {
 let resourceUrl = Bundle.main.url(forResource:
 filename, withExtension: nil)
 guard let url = resourceUrl else {
 print("Could not find file: \(filename)")
 return
 }
 do {
 try backgroundMusicPlayer =
 AVAudioPlayer(contentsOf: url)
 backgroundMusicPlayer.numberOfLoops = -1
 backgroundMusicPlayer.prepareToPlay()
 backgroundMusicPlayer.play()
 } catch {
 print("Could not create audio player!")
 return
 }
}
