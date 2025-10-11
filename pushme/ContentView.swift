//
//  ContentView.swift
//  pushback
//
//  Created by lynn on 2025/4/3.
//

import SwiftUI
import GRDB
import UniformTypeIdentifiers
import WidgetKit
import Defaults


struct ContentView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    @Default(.showGroup) private var showGroup
    @StateObject private var manager = AppManager.shared
    @StateObject private var messageManager = MessagesManager.shared
    
    @Default(.firstStart) private var firstStart
    @Default(.badgeMode) private var badgeMode
    
    @State private var HomeViewMode:NavigationSplitViewVisibility = .detailOnly

    @Namespace private var selectMessageSpace

    var body: some View {
        
        ZStack{
            if .ISPAD{
                IpadHomeView()
            }else{
                IphoneHomeView()
            }
            
            if firstStart {
                firstStartLauchFirstStartView()
            }
        }
        .environmentObject(manager)
        .overlay{
            if manager.isLoading && manager.inAssistant{
                ColoredBorder()
            }
        }
        .if( !Defaults[.firstStart] ){ view in
            Group{
                if #available(iOS 17.0, *) {
                    view.subscriptionStatusTask(for: "21582431") {
                            if let result = $0.value {
                                let premiumUser = result.filter({ $0.state == .subscribed })
                                NLog.log("User Subscribed = \(!premiumUser.isEmpty)")
                                manager.PremiumUser = !premiumUser.isEmpty
                            }
                        }
                } else {
                    // Fallback on earlier versions
                    view
                }
            }
            
        }
        .sheet(isPresented: manager.sheetShow){ ContentSheetViewPage() }
        .fullScreenCover(isPresented: manager.fullShow){ ContentFullViewPage() }

    }
    
    @ViewBuilder
    func IphoneHomeView()-> some View{

        Group{
            if #available(iOS 26.0, *){
                TabView(selection: Binding(get: { manager.page }, set: { updateTab(with: $0) })) {

                    Tab(value: .message) {
                        NavigationStack(path: $manager.mrouter){
                            // MARK: 信息页面
                            MessagePage()
                                .router(manager)
                        }
                    } label: {
                        Label( "消息", systemImage: "ellipsis.message")
                            .symbolRenderingMode(.palette)
                            .customForegroundStyle(.green, .primary)
                    }
                    .badge(messageManager.unreadCount)



                    Tab(value: .setting) {
                        NavigationStack(path: $manager.srouter){
                            // MARK: 设置页面
                            SettingsPage()
                                .router(manager)
                        }
                    } label: {
                        Label( "设置", systemImage: "gear.badge.questionmark")
                            .symbolRenderingMode(.palette)
                            .customForegroundStyle(.green, .primary)
                    }


                    Tab(value: .search, role: .search) {
                        NavigationStack(path: $manager.sorouter){
                            // MARK: 设置页面
                            SearchMessageView()
                                .router(manager)
                        }
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .symbolRenderingMode(.palette)
                            .customForegroundStyle(.green, .primary)
                    }

                }.tabBarMinimizeBehavior(.onScrollDown)
            }else{
                TabView(selection: Binding(get: { manager.page }, set: { updateTab(with: $0) })) {

                    NavigationStack(path: $manager.mrouter){
                        // MARK: 信息页面
                        MessagePage()
                            .router(manager)

                    }
                    .tabItem {
                        Label( "消息", systemImage: "ellipsis.message")
                            .symbolRenderingMode(.palette)
                            .customForegroundStyle(.green, .primary)

                    }
                    .badge(messageManager.unreadCount)
                    .tag(TabPage.message)



                    NavigationStack(path: $manager.srouter){
                        // MARK: 设置页面
                        SettingsPage()
                            .router(manager)
                    }
                    .tabItem {
                        Label( "设置", systemImage: "gear.badge.questionmark")
                            .symbolRenderingMode(.palette)
                            .customForegroundStyle(.green, .primary)
                    }
                    .tag(TabPage.setting)


                }
            }
        }
    }

    func updateTab(with newTab: TabPage){
        Haptic.impact()
        AudioManager.tips(.tabSelection)
        manager.page = newTab
    }

    @ViewBuilder
    func IpadHomeView() -> some View{
        
        NavigationSplitView(columnVisibility: $HomeViewMode) {
            SettingsPage()
                .environmentObject(manager)
        } detail: {
            
            NavigationStack(path: $manager.prouter){
                MessagePage()
                    .router(manager)
            }
        }
    }
    
    @ViewBuilder
    func firstStartLauchFirstStartView()-> some View{
        PermissionsStartView(){
            withAnimation { self.firstStart.toggle() }
            
            Task.detached(priority: .userInitiated) {
                for item in MessagesManager.examples(){
                    await MessagesManager.shared.add(item)
                }
            }
            
            if Defaults[.cryptoConfigs].count == 0{
                Defaults[.cryptoConfigs] = [CryptoModelConfig.creteNewModel()]
            }
            
        }
        .background26(.ultraThinMaterial, radius: 5)
    }
    
    @ViewBuilder
    func ContentFullViewPage() -> some View{
        Group{
            switch manager.fullPage {
            case .customKey:
                ChangeKeyView()
            case .scan:
                ScanView{ code in
                    if AppManager.shared.HandlerOpenUrl(url: code) == nil{
                        manager.fullPage = .none
                    }
                }
            case .web(let url):
                SFSafariView(url: url).ignoresSafeArea()

            default:
                EmptyView().onAppear{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                        manager.fullPage = .none
                    }
                }
            }
        }
        .environmentObject(manager)
        
    }
    
    @ViewBuilder
    func ContentSheetViewPage() -> some View {
        Group{
            switch manager.sheetPage {
            case .appIcon:
                NavigationStack{
                    AppIconView()
                }.presentationDetents([.height(300)])
            case .cloudIcon:
                CloudIcon() .presentationDetents([.medium, .large])
            case .paywall:
                if #available(iOS 18.0, *) { PayWallHighView() }else{
                    EmptyView()
                        .onAppear{
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                manager.sheetPage = .none
                            }
                        }
                }
            case .quickResponseCode(let text, let title, let preview):
                QuickResponseCodeview(text:text, title: title, preview:preview)
                    .presentationDetents([.medium])
            case .scan:
                
                ScanView{ code in
                    if let data = AppManager.shared.HandlerOpenUrl(url: code),data.hasHttp(){
                        let success = await manager.appendServer(server: PushServerModel(url: code))
                        if success{
                            manager.sheetPage = .none
                            manager.fullPage = .none
                            manager.page = .setting
                            manager.router = [.server]
                        }else{
                            Toast.error(title: "添加失败")
                        }
                    }else{
                        manager.sheetPage = .none
                    }
                    
                }
            case .crypto(let item):
                ChangeCryptoConfigView(item: item)
                   
            default:
                EmptyView().onAppear{ manager.sheetPage = .none }
            }
        }
        .environmentObject(manager)
        .customPresentationCornerRadius(30)
    }
    
}

extension View{
    func router(_ manager:AppManager) -> some View{
        self
            .navigationDestination(for: RouterPage.self){ router in
                Group{
                    switch router {
                    case .example:
                        ExampleView()
                    case .messageDetail(let group):
                        MessageDetailPage(group: group)
                            .navigationTitle(group)
                        
                    case .sound:
                        SoundView()

                    case .assistant:
                        AssistantPageView()
                        
                    case .assistantSetting(let account):
                        AssistantSettingsView(account: account)
                        
                    case .crypto:
                        CryptoConfigListView()
                        
                    case .server:
                        ServersConfigView()
                        
                    case .more:
                        MoreOperationsView()
                        
                    case .widget(title: let title, data: let data):
                        WidgetChartView(data: data)
                            .navigationTitle(title ?? "小组件")
                    case .tts:
                        SpeakSettingsView()
                        
                    case .pushtalk:
                        PushToTalkView()
                        
                    case .about:
                        AboutNoLetView()

                    case .dataSetting:
                        DataSettingView()
                        
                    case .serverInfo(let server):
                        ServerMonitoringView(server: server)

                    case .files(let url):
                        NoletFileList(rootURL: url)
                           

                    }
                }
                .toolbar(.hidden, for: .tabBar)
                .navigationBarTitleDisplayMode(.large)
                .environmentObject(manager)
                
            }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppManager.shared)
}
