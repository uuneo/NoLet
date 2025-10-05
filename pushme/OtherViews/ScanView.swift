//
//  ScanView.swift
//  Meow
//
//  Created by uuneo 2024/8/10.
//


import SwiftUI
import AVFoundation
import QRScanner
import UIKit



struct ScanView: View {
	@Environment(\.dismiss) var dismiss
    @State private var isScanning = true
    @State private var isTorchOn = false
    @State private var shouldRescan = false
	@State private var showActive = false
    @State private var code:String? = nil
    @EnvironmentObject private var manager:AppManager
    
    var response: (String)async-> Bool

    
	var body: some View {
		ZStack{
            QRScannerSwiftUIView(
                isScanning: $isScanning,
                torchActive: $isTorchOn,
                shouldRescan: $shouldRescan,
                onSuccess: { code in
                    AudioManager.tips(.qrcode)
                    Task{@MainActor in
                        try await Task.sleep(for: .seconds(0.5))
                        self.code = code
                        self.showActive = await response(code)
                    }
                },
                onFailure: { error in
                    AudioServicesPlaySystemSound(1053)
                    switch error{
                    case .unauthorized(let status):
                        if status != .authorized{
                            Toast.info(title:  "没有相机权限")
                        }
                    default:
                        Toast.error(title: "扫码失败")
                    }
                    self.code = nil
                    self.showActive = true
                },
                onTorchActiveChange: { isOn in
                    isTorchOn = isOn
                }
            )
            .actionSheet(isPresented: $showActive) {
                if let code = code {
                    ActionSheet(title: Text( "扫码提示!"),buttons: [
                        .default(Text( "重新扫码"), action: {
                            self.showActive = false
                            self.shouldRescan.toggle()
                        }),
                        .default(Text( "展示二维码"), action: {
                            self.dismiss()
                            AppManager.shared.sheetPage = .quickResponseCode(text: code, title: String("二维码"), preview: String("二维码"))
                        }),
                        .cancel({
                            self.dismiss()
                        })
                    ])
                }else{
                    ActionSheet(title: Text( "扫码失败!"),buttons: [
                        .default(Text( "重新扫码"), action: {
                            self.showActive = false
                            self.shouldRescan.toggle()
                        }),
                        .cancel({
                            self.dismiss()
                        })
                    ])
                }
                
            }


            VStack{
                HStack{
                    
                    Spacer()
                    Button{
                        self.dismiss()
                        Haptic.impact()
                    }label: {
                        Image(systemName: "xmark")
                            .font(.title3.bold())
                            .foregroundColor(.secondary)
                            .padding()
                            .background26(.ultraThinMaterial, radius: 10)
                            .clipShape(Circle())
                    }
				}
				.padding()
				.padding(.top,50)
				Spacer()
                
                VStack{
                    Image(systemName: isTorchOn ? "flashlight.on.fill" : "flashlight.off.fill")
                        .font(.system(size: 50))
                        .symbolRenderingMode(.palette)
                        .symbolEffect(.replace)
                        .padding()
                        .contentShape(Rectangle())
                        .VButton(onRelease: { _ in
                            self.isTorchOn.toggle()
                            return true
                        })
                    
                }
                .padding(.bottom, 80)
				


			}

		}
        .ignoresSafeArea()
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 30, coordinateSpace: .global)
                .onChanged({ active in
                    Haptic.selection()
                })
                .onEnded({ action in
                   
                    if  action.translation.height > 100{
                        manager.fullPage = .none
                        Haptic.impact()
                    }
                })
        )
	}

    func showMenu(){
        self.showActive = true
    }

}




#Preview {
    ScanView(){_ in true}
}




