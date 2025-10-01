//
//  SingleMessagesView.swift
//  pushback
//
//  Created by uuneo on 2025/2/13.
//

import SwiftUI
import GRDB
import Defaults



struct SingleMessagesView: View {


    @Default(.showMessageAvatar) var showMessageAvatar
    
    @State private var isLoading: Bool = false
    
 
    @State private var showAllTTL:Bool = false
    
    @EnvironmentObject private var manager:AppManager
    @EnvironmentObject private var messageManager: MessagesManager
   

    @State private var showLoading:Bool = false
    @State private var scrollItem:String = ""

    @State private var selectMessage: Message? = nil
    @State private var messages:[Message] = []

    var body: some View {
        
        ScrollViewReader { proxy in
            List{
               
                    ForEach(messages, id: \.id) { message in

                        MessageCard(message: message, searchText: "",showAllTTL: showAllTTL,showAvatar:showMessageAvatar){
                            withAnimation(.easeInOut) {
                                manager.selectMessage = message
                            }
                        }delete:{
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){
                                withAnimation(.default){
                                    messages.removeAll(where: {$0.id == message.id})
                                }
                            }

                            Task.detached(priority: .background){
                                _ = await DatabaseManager.shared.delete(message)
                            }
                            Toast.success(title: "删除成功")
                        }
                        .id(message.id)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .listSectionSeparator(.hidden)
                        .onAppear{
                            if messages.count < messageManager.allCount &&
                                messages.last == message{
                                self.loadData(proxy: proxy, item: message)
                            }
                        }


                    }
                
                
            }
            .listStyle(.grouped)
            .animation(.easeInOut, value: messages)
            .refreshable {
                self.loadData(proxy: proxy , limit: min(messages.count, 150))
            }
            .onChange(of: messageManager.updateSign) {  newValue in
                loadData(proxy: proxy, limit: max(messages.count, 30))
            }
        }
        .diff{ view in
            Group{
                if #available(iOS 26.0, *){
                    view
                        .toolbar {
                            if !(messages.count == 0 || messages.count == messageManager.allCount){
                                ToolbarItem(placement: .subtitle) {
                                    allMessageCount
                                }
                            }
                        }
                }else{
                    view
                        .safeAreaInset(edge: .bottom){
                            HStack{
                                Spacer()
                                allMessageCount
                                    .padding(.horizontal, 10)
                                    .background26(.ultraThinMaterial, radius: 5)
                            }.opacity((messages.count == 0 || messages.count == messageManager.allCount) ? 0 : 1)
                        }
                }
            }
        }
        .task {

            self.loadData()
            Task.detached(priority: .background) {
                
                try? await DatabaseManager.shared.dbQueue.write { db in
                    // 批量更新 read 字段为 true
                    try Message
                        .filter(Message.Columns.read == false)
                        .updateAll(db, [Message.Columns.read.set(to: true)])
                    
                    // 清除徽章
                    if Defaults[.badgeMode] == .auto {
                        UNUserNotificationCenter.current().setBadgeCount(0)
                    }
                }

            }
            
        }


    }

    private var allMessageCount: some View{
        Text(verbatim: "\(messages.count) / \(max(messageManager.allCount, messages.count))")
            .font(.caption)
            .foregroundStyle(.gray)
    }

    private func proxyTo(proxy: ScrollViewProxy, selectId:String?){
        if let selectId = selectId{
            withAnimation {
                proxy.scrollTo(selectId, anchor: .center)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                manager.selectId = nil
                manager.selectGroup = nil
            }
        }
    }
    
    private func loadData(proxy:ScrollViewProxy? = nil, limit:Int =  30, item:Message? = nil){
        guard !self.showLoading else { return }
        self.showLoading = true

       Task.detached(priority: .userInitiated) {

           let results = await DatabaseManager.shared.query( limit: limit, item?.createDate)
            
             DispatchQueue.main.async {
 
                if item == nil {
                    
                    self.messages = results
                }else{
                    self.messages += results
                }
                if let selectId = manager.selectId{
                    proxy?.scrollTo(selectId, anchor: .center)
                    manager.selectId = nil
                    manager.selectGroup = nil
                }
                self.showLoading = false
            }
        }
    }
    
}

#Preview {
    SingleMessagesView()
}


struct BottomScrollDetector: View {
    let onBottomReached: () -> Void
    
    var body: some View {
        GeometryReader { geo in
            Color.clear
                .preference(key: ScrollOffsetKey.self, value: geo.frame(in: .global).maxY)
        }
        .frame(height: 0) // 不占空间
    }
}

struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}



