//
//  AboutNoLetView.swift
//  pushme
//
//  Created by AI Assistant 2024/05/29.
//

import SwiftUI
import Defaults
import StoreKit



struct AboutNoLetView: View {
    @EnvironmentObject private var manager: AppManager
    @Default(.appIcon) var setting_active_app_icon
    
    @State private var buildDetail: Bool = false
    
    var buildVersion: String {
        // 版本号
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        // build号
        var buildNumber: String {
            if let version = Bundle.main.infoDictionary?["CFBundleVersion"] as? String,
               let versionNumber = Int(version) {
                return String(versionNumber, radix: 16).uppercased()
            }
            return ""
        }

        return buildDetail ? "\(appVersion)(\(buildNumber))" : appVersion
    }



    var body: some View {
        List {
            // Logo 部分
            Section {
                HStack {
                    Spacer()
                    VStack(spacing: 16) {
                        Button{
                            manager.sheetPage = .appIcon
                            Haptic.impact()
                        }label:{
                            Image(setting_active_app_icon.logo)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                        }

                        
                        Text(BaseConfig.AppName)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("版本 \(buildVersion)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .onTapGesture {
                                buildDetail.toggle()
                                Haptic.impact()
                            }
                    }
                    Spacer()
                }
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())
            
            // 应用信息部分
            Section {
                // 去评分
                ListButton {
                    Label {
                        Text("去评分")
                            .foregroundStyle(.textBlack)
                    } icon: {
                        Image(systemName: "star.fill")
                            .symbolRenderingMode(.palette)
                            .customForegroundStyle(.yellow, Color.primary)
                    }
                } action: {
                    requestReview()
                    return true
                }

                ListButton {
                    Label {
                        Text( "使用帮助")
                            .foregroundStyle(.textBlack)
                    } icon: {
                        Image(systemName: "person.fill.questionmark")

                            .symbolRenderingMode(.palette)
                            .customForegroundStyle(.accent, Color.primary)
                    }
                } action: {
                    manager.fullPage = .web(BaseConfig.docHelp)
                    return true
                }

                // App开源地址
                ListButton {
                    Label {
                        Text("App开源地址")
                            .foregroundStyle(.textBlack)
                    } icon: {
                        Image(systemName: "curlybraces")
                            .symbolRenderingMode(.palette)
                            .customForegroundStyle(.blue, Color.primary)
                    }
                } action: {

                    manager.fullPage = .web(BaseConfig.GITHUBAPP)
                    return true
                }
                
                // 服务器开源地址
                ListButton {
                    Label {
                        Text("服务器开源地址")
                            .foregroundStyle(.textBlack)
                    } icon: {
                        Image(systemName: "server.rack")
                            .symbolRenderingMode(.palette)
                            .customForegroundStyle(.green, Color.primary)
                    }
                } action: {
                    manager.fullPage = .web(BaseConfig.GITHUBSERVER)
                    return true
                }

                // 版本更新
                ListButton {
                    Label {
                        Text("版本更新")
                            .foregroundStyle(.textBlack)
                    } icon: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .symbolRenderingMode(.palette)
                            .customForegroundStyle(.accent, Color.primary)
                            .symbolEffect(.bounce)
                    }
                } action: {
                    if let url = URL(string: BaseConfig.APPSTORE){
                        AppManager.openUrl(url: url)
                    }

                    return true
                }



            } header: {
                Text("应用信息")
                    .textCase(.none)
            }
        }
        .overlay(alignment: .bottom) {
            VStack{
                HStack(spacing: 7){
                    Spacer(minLength: 10)

                    Button{
                        manager.fullPage = .web(BaseConfig.privacyURL)
                        Haptic.impact()
                    }label: {
                        Text("隐私政策")


                    }
                    Circle()
                        .frame(width: 3,height: 3)
                    Button{
                        manager.fullPage = .web(BaseConfig.userAgreement)
                        Haptic.impact()
                    }label: {
                        Text("用户协议")

                    }

                    Spacer(minLength: 10)
                }
                .font(.caption)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .padding(.bottom)
                HStack{
                    Spacer()
                    Text(verbatim: "© 2024 uuneo. All rights reserved.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 8)
                    Spacer()
                }
            }

        }

    }

    func requestReview() {
        if let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}

#Preview {
    NavigationStack {
        AboutNoLetView()
            .environmentObject(AppManager.shared)
    }
}
