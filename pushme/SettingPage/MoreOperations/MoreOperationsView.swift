    //
    //  File name:     DataStorageView.swift
    //  Author:        Copyright (c) 2024 QingHe. All rights reserved.
    //  Blog  :        https://uuneo.com
    //  E-mail:        to@uuneo.com
    //  Description:
    //  History:
    //  Created by uuneo on 2024/12/11.

import SwiftUI
import Defaults
import UniformTypeIdentifiers
import Photos
struct MoreOperationsView: View {
    @EnvironmentObject private var manager:AppManager



    @Default(.autoSaveToAlbum) var autoSaveToAlbum

    @Default(.badgeMode) var badgeMode
    @Default(.showMessageAvatar) var showMessageAvatar
    @Default(.defaultBrowser) var defaultBrowser
    @Default(.muteSetting) var muteSetting




    var body: some View {
        List{

            Section {




                ListButton(leading: {
                    Label {
                        Text("删除静音分组")
                            .foregroundStyle(.textBlack)
                    } icon: {

                        Image(systemName: "\(muteSetting.count).circle")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.tint, Color.primary)

                    }
                }, trailing: {
                    Image(systemName: "trash")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.tint, Color.primary)
                }, showRight: true) {
                    Defaults[.muteSetting] = [:]
                    return true
                }

            }header:{
                Text("分组设置")
                    .textCase(.none)
            }

            Section{
                Picker(selection: $badgeMode) {
                    Text( "自动").tag(BadgeAutoMode.auto)
                    Text( "自定义").tag(BadgeAutoMode.custom)
                } label: {
                    Label {
                        Text( "角标模式")
                    } icon: {
                        Image(systemName: "app.badge")
                            .scaleEffect(0.9)
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.tint, Color.primary)
                            .symbolEffect(.pulse, delay: 3)
                    }
                }.onChange(of: badgeMode) { newValue in
                    if Defaults[.badgeMode] == .auto{
                        let unRead =  DatabaseManager.shared.unreadCount()
                        UNUserNotificationCenter.current().setBadgeCount( unRead )
                    }
                }
            }footer:{
                Text( "自动模式按照未读数，自定义按照推送badge参数")
                    .foregroundStyle(.gray)
            }

            Section{
                Toggle(isOn: $showMessageAvatar) {
                    Label("显示图标", systemImage: showMessageAvatar ? "camera.macro.circle" : "camera.macro.slash.circle")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle( .tint, Color.primary)
                        .symbolEffect(.replace)

                }
            }footer:{
                Text( "消息卡片未分组时是否显示logo")
                    .foregroundStyle(.gray)
            }


            Section{
                Toggle(isOn: $autoSaveToAlbum) {
                    Label("自动保存到相册", systemImage: "a.circle")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle( .tint, Color.primary)
                        .symbolEffect(.rotate, delay: 3)
                        .onChange(of: autoSaveToAlbum) { newValue in
                            if newValue{
                                PHPhotoLibrary.requestAuthorization{status in
                                    switch status {
                                    case .notDetermined:
                                        Toast.info(title:"用户尚未做出选择")

                                    case .restricted:
                                        Toast.info(title: "访问受限（可能是家长控制）")

                                    case .denied:
                                        Toast.info(title: "用户拒绝了访问权限")

                                    case .authorized:
                                        Toast.success(title: "用户已授权访问照片库")

                                    case .limited:
                                        Toast.info(title: "用户授予了有限的访问权限")

                                    @unknown default:
                                        break

                                    }
                                }
                            }
                        }

                }
            }footer:{
                Text( "是否收到消息自动保存图片")
                    .foregroundStyle(.gray)
            }




            Section{
                HStack{
                    Picker(selection: $defaultBrowser) {
                        ForEach(DefaultBrowserModel.allCases, id: \.self) { item in
                            Text(item.title)
                                .tag(item)
                        }
                    }label:{
                        Text("默认浏览器")
                    }.pickerStyle(SegmentedPickerStyle())

                }
            }footer:{
                Text( "链接默认打开方式")
                    .foregroundStyle(.gray)
            }

            Section{

                ListButton {
                    Label {
                        Text("小组件")
                            .foregroundStyle(.textBlack)
                    } icon: {
                        Image(systemName: "window.shade.closed")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.tint, Color.primary)

                    }
                } action:{
                    manager.router.append(.widget(title: nil, data: "app"))
                    return true
                }
            }footer:{
                Text( "详细配置查看文档")
                    .foregroundStyle(.gray)
            }




            Section{
                ListButton {
                    Label {
                        Text( "系统设置")
                            .foregroundStyle(.textBlack)
                    } icon: {
                        Image(systemName: "gear.circle")

                            .symbolRenderingMode(.palette)
                            .customForegroundStyle(.accent, Color.primary)
                            .symbolEffect(.rotate)
                    }
                } action:{
                    Task{@MainActor in
                        AppManager.openSetting()
                    }
                    return true
                }


            }



        }
        .navigationTitle("更多设置")
        .navigationBarTitleDisplayMode(.inline)

    }













}

#Preview {
    MoreOperationsView()
        .environmentObject(AppManager.shared)
}
