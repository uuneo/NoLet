    //
    //  DataSettingView.swift
    //  pushme
    //
    //  Created by lynn on 2025/9/22.
    //

import SwiftUI
import Defaults
import UniformTypeIdentifiers

extension UTType{
    static let sqlite = UTType(filenameExtension: "sqlite")!
}

struct DataSettingView: View {
    @EnvironmentObject private var manager:AppManager
    @StateObject private var messageManager = MessagesManager.shared

    @Default(.messageExpiration) var messageExpiration
    @Default(.imageSaveDays) var imageSaveDays

    @State private var messages:[Message] = []
    @State private var allCount:Int = 0

    @State private var showImport:Bool = false
    @State private var showexport:Bool = false


    @State private var showexportLoading:Bool = false
    @State private var showDriveCheckLoading:Bool = false

    @State private var showDeleteAlert:Bool = false
    @State private var resetAppShow:Bool = false
    @State private var restartAppShow:Bool = false

    @State private var totalSize:UInt64 = 0
    @State private var cacheSize:UInt64 = 0

    @State private var cancelTask: Task<Void, Never>?

    @State private var configPath:URL? = nil
    @State private var selectAction: MessageAction? = nil
    @State private var addLoading:Bool = false
    var body: some View {
        List{
#if DEBUG
                Section{
                    
                    Button{
                        self.addLoading = true
                        Task.detached(priority: .high){
                            _ =  await MessagesManager.createStressTest()
                            await MainActor.run{
                                self.addLoading = false
                            }
                        }
                    }label:{
                        HStack{
                            
                            Spacer()
                            Label {
                                Text(verbatim: addLoading ? "Adding..." : "Add 50,000 Test Message")
                            } icon: {
                                Image(systemName: "plus.message.fill")
                            }
                            Spacer()
                        }
                        .padding(.vertical, 10)
                    }
                    .button26(BorderedProminentButtonStyle())
                    .disabled(addLoading)
                    
                }header:{
                    Text(verbatim: "")
                }

#endif
            
            Section {
                


                Menu{
                    if messageManager.allCount > 0{
                        Section{
                            Button{
                                guard !showexportLoading else { return }
                                self.showexportLoading = true
                                cancelTask = Task.detached(priority: .background) {
                                    do{
                                        let results = try await messageManager.all()

                                        DispatchQueue.main.async {
                                            self.messages = results
                                            self.showexportLoading = false
                                            self.showexport = true
                                        }
                                    }catch{
                                        NLog.error(error.localizedDescription)
                                        DispatchQueue.main.async{
                                            self.showexportLoading = false
                                        }
                                    }
                                }
                            }label: {
                                Label("消息列表", systemImage: "list.bullet.clipboard")
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(.tint, Color.primary)

                            }
                        }
                    }

                    
                    if let configPath{
                        Section{
                            ShareLink( item: configPath) {
                                Label("配置文件", systemImage: "doc.badge.gearshape")
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(.tint, Color.primary)

                            }

                        }
                    }

                    if let database = BaseConfig.databasePath{
                        Section{
                            ShareLink( item: database) {
                                Label("数据库文件", systemImage: "internaldrive")
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(.tint, Color.primary)
                            }
                        }
                    }

                }label: {
                    HStack{
                        Label("导出", systemImage: "square.and.arrow.up")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.tint, Color.primary)
                            .symbolEffect(.wiggle, delay: 3)
                            .if(showexportLoading) {
                                Label("正在处理数据", systemImage: "slowmo")
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(.tint, Color.primary)
                                    .symbolEffect(.rotate)
                            }

                        Spacer()
                        Text(String(format: String(localized: "%d条消息"), messageManager.allCount) )
                            .foregroundStyle(Color.green)
                    }
                }

                .fileExporter(isPresented: $showexport, document: TextFileMessage(content: messages), contentType: .trnExportType, defaultFilename: "pushback_\(Date().formatString(format:"yyyy_MM_dd_HH_mm"))") { result in
                    switch result {
                    case .success(let success):
                        NLog.log(success)
                    case .failure(let failure):
                        NLog.error(failure)
                    }
                    self.showexport = false
                }
                .onAppear{
                    self.configPath = AppManager.createDatabaseFileTem()
                    self.calculateSize()
                }
                .onDisappear{
                    cancelTask?.cancel()
                    self.messages = []
                    self.showexport = false
                    if let file = self.configPath{
                        try? FileManager.default.removeItem(at: file)
                    }
                }
                



                Button{
                    self.showImport.toggle()
                }label: {
                    HStack{
                        Label( "导入", systemImage: "arrow.down.circle")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.tint, Color.primary)
                            .symbolEffect(.wiggle, delay: 6)
                        Spacer()
                    }
                }
                .fileImporter(
                    isPresented: $showImport,
                    allowedContentTypes: [ .trnExportType, .sqlite, .propertyList ],
                    allowsMultipleSelection: false,
                    onCompletion: { result in
                        
                    switch result {
                    case .success(let files):
                        let msg = importMessage(files)
                        Toast.shared.present(title: msg, symbol: .info)
                    case .failure(let err):
                        Toast.shared.present(title: err.localizedDescription, symbol: .error)
                    }
                })
            } header: {
                Text( "导出消息列表")
                    .textCase(.none)
            } footer:{
                Text("只能导入.exv结尾的JSON数据")
            }


            Section{
                Picker(selection: $messageExpiration) {
                    ForEach(ExpirationTime.allCases, id: \.self){ item in
                        Text(item.title)
                            .tag(item)
                    }
                } label: {
                    Label {
                        Text( "消息存档")
                    } icon: {
                        Image(systemName: "externaldrive.badge.timemachine")
                            .scaleEffect(0.9)
                            .symbolRenderingMode(.palette)
                            .foregroundStyle((messageExpiration == .no ? .red : (messageExpiration == .forever  ? .green : .yellow)), Color.primary)
                            .symbolEffect(.pulse, delay: 1)
                    }
                }


                Picker(selection: $imageSaveDays) {
                    ForEach(ExpirationTime.allCases, id: \.self){ item in
                        Text(item.title)
                            .tag(item)
                    }
                } label: {
                    Label {
                        Text( "图片存档")
                    } icon: {
                        Image(systemName: "externaldrive.badge.timemachine")
                            .scaleEffect(0.9)
                            .symbolRenderingMode(.palette)
                            .symbolEffect(.pulse, delay: 1)
                            .foregroundStyle((imageSaveDays == .no ? .red : (imageSaveDays == .forever  ? .green : .yellow)), Color.primary)
                    }
                }
            }footer:{
                Text( "当推送请求URL没有指定 isArchive 参数时，将按照此设置来决定是否保存通知消息")
                    .foregroundStyle(.gray)
            }

            Section(header: Text(verbatim: "")){
                HStack{
                    Label {
                        Text("存储使用")
                    } icon: {
                        Image(systemName: "externaldrive.badge.person.crop")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.green, Color.primary)
                            .symbolEffect(.pulse, delay: 3)
                            
                    }

                    Spacer()

                    Text(totalSize.fileSize())
                        .onAppear{
                            calculateSize()
                        }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if let container = CONTAINER{
                        manager.router = [.dataSetting, .files(url: container)]
                    }
                    
                }
                
                HStack{
                    Label {
                        Text("临时文件")
                    } icon: {
                        Image(systemName: "questionmark.folder")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.green, Color.primary)
                            .symbolEffect(.pulse, delay: 3)
                    }

                    Spacer()

                    Text(cacheSize.fileSize())
                        .onAppear{
                            calculateSize()
                        }
                }.contentShape(Rectangle())
                    .onTapGesture {
                        if let tem = BaseConfig.getDir(.tem){
                            manager.router = [.dataSetting, .files(url: tem)]
                        }
                        
                    }

                HStack{
                    Button{
                        guard !showDeleteAlert else { return }
                        self.showDeleteAlert.toggle()
                    }label: {
                        HStack{
                            Spacer()
                            Label("清空缓存数据", systemImage: "trash.circle")
                                .foregroundStyle(.white, Color.primary)
                                .fontWeight(.bold)
                                .padding(.vertical, 5)
                                .if(showDriveCheckLoading) {
                                    Label("正在处理数据", systemImage: "slowmo")
                                        .symbolRenderingMode(.palette)
                                        .foregroundStyle(.white, Color.primary)
                                        .symbolEffect(.rotate)
                                }

                            Spacer()
                        }

                    }
                    .diff{view in
                        Group{
                            if #available(iOS 26.0, *) {
                                view
                                    .buttonStyle(.glassProminent)
                            }else{
                                view
                                    .buttonStyle(BorderedProminentButtonStyle())
                            }
                        }

                    }

                }

                HStack{
                    Button{
                        self.resetAppShow.toggle()
                    }label: {
                        HStack{
                            Spacer()
                            Label("初始化App", systemImage: "arrow.3.trianglepath")
                                .foregroundStyle(.white, Color.primary)
                                .padding(.vertical, 5)
                                .fontWeight(.bold)

                            Spacer()
                        }

                    }
                    .tint(.red)
                    .button26(BorderedProminentButtonStyle())
                }
            }


        }
        .navigationTitle("数据管理")
        .navigationBarTitleDisplayMode(.inline)
        .if(selectAction != nil ){ view in
            view.alert("确认删除", isPresented: Binding(get: { selectAction != nil }, set: { _ in selectAction = nil })) {
                Button("取消", role: .cancel) {
                    self.selectAction = nil
                }
                Button("删除", role: .destructive) {
                    if let mode = selectAction {
                        Task.detached(priority: .userInitiated) {
                            await messageManager.delete(date: mode.date)
                            await MainActor.run{
                                self.selectAction = nil
                                self.calculateSize()
                            }
                        }
                    }
                }
            } message: {
                if let selectAction {
                    Text("此操作将删除 \(selectAction.title) 数据，且无法恢复。确定要继续吗？")
                }
            }
        }
        .if(restartAppShow){ view in
            view
                .alert(isPresented: $restartAppShow) {

                    Alert(title: Text("导入成功"),
                          message:  Text("重启才能生效,即将退出程序！"),
                          dismissButton:
                            .destructive(Text("确定"), action: { exit(0) })
                    )}
        }
        .if(resetAppShow){ view in
            view
                .alert(isPresented: $resetAppShow) {
                    Alert(title: Text("危险操作!!! 恢复初始化."),
                          message:  Text("将丢失所有数据"),
                          primaryButton: .destructive(Text("确定"), action: { resetApp() }),
                          secondaryButton: .cancel()
                    )}
        }
        .if(showDeleteAlert){ view in
            view
                .alert(isPresented: $showDeleteAlert) {
                    Alert(title: Text("是否确定清空?"),  message: Text("删除后不能还原!!!"),
                          primaryButton: .destructive(Text("清空"),
                                                      action: {
                        self.showDriveCheckLoading = true
                        if let cache = ImageManager.defaultCache(),
                           let fileUrl = BaseConfig.getDir(.sounds),
                           let voiceUrl = BaseConfig.getDir(.voice),
                           let cacheUrl = BaseConfig.getDir(.tem) {
                            cache.clearDiskCache()
                            manager.clearContentsOfDirectory(at: fileUrl)
                            manager.clearContentsOfDirectory(at: voiceUrl)
                            manager.clearContentsOfDirectory(at: cacheUrl)
                            Defaults[.imageSaves] = []
                        }
    
                        try? DatabaseManager.shared.dbQueue.vacuum()

                        Toast.success(title: "清理成功")

                        DispatchQueue.main.async{
                            self.showDriveCheckLoading = false
                            calculateSize()
                        }


                    }),
                          secondaryButton: .cancel())

                }

        }
        .toolbar {
            
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    ForEach(MessageAction.allCases, id: \.self) { item in
                        if item == .cancel {
                            Section {
                                Button(role: .destructive) {} label: {
                                    Label(item.title, systemImage: "xmark.seal")
                                        .symbolRenderingMode(.palette)
                                        .customForegroundStyle(.accent, .primary)
                                }
                            }
                        } else {
                            Section{
                                Button {
                                    self.selectAction = item
                                } label: {
                                    Label(item.title, systemImage: "trash")
                                        .symbolRenderingMode(.palette)
                                        .customForegroundStyle(.accent, .primary)
                                }
                            }
                        }
                    }
                } label: {
                    Label("按条件删除消息", systemImage: "trash")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.green, Color.primary)
                }
            }
        }
        .onChange(of: messageManager.allCount) { _ in
            self.calculateSize()
        }
    }

    


    fileprivate func resetApp(){
        if let group = CONTAINER{
            manager.clearContentsOfDirectory(at: group)
            exit(0)
        }

    }
    


    func calculateSize(){
        if let group = CONTAINER,
           let soundsUrl = BaseConfig.getDir(.sounds),
           let imageUrl = BaseConfig.getDir(.image),
           let voiceUrl = BaseConfig.getDir(.voice),
           let cacheFileUrl = BaseConfig.getDir(.tem)
        {
            self.totalSize = manager.calculateDirectorySize(at: group)

            self.cacheSize =  manager.calculateDirectorySize(at: soundsUrl) +  manager.calculateDirectorySize(at: imageUrl) +
            manager.calculateDirectorySize(at: voiceUrl) +
            manager.calculateDirectorySize(at: cacheFileUrl)

        }
    }



    fileprivate func importMessage(_ fileUrls: [URL]) -> String {
        guard let url = fileUrls.first else { return ""}

        do{

            if url.startAccessingSecurityScopedResource(){

                switch url.pathExtension{
                case "plist":
                    let raw = try Data(contentsOf: url)
                    if let data = CryptoManager(.data).decrypt(inputData: raw),  let path = BaseConfig.configPath{
                        try data.write(to: path)
                    }else{
                        throw NoletError.basic("解密失败")
                    }
                    self.restartAppShow.toggle()
                case "sqlite":
                    let raw = try Data(contentsOf: url)
                    if let path = BaseConfig.databasePath{
                        try raw.write(to: path)
                    }else{
                        throw NoletError.basic("导入失败")
                    }

                    self.restartAppShow.toggle()

                default:
                    let raw = try Data(contentsOf: url)
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .secondsSince1970
                    let messages = try decoder.decode([Message].self, from: raw)
                    try DatabaseManager.shared.dbQueue.write { db in
                        try messages.forEach({ try $0.insert(db)})
                    }
                }

            }

            return String(localized: "导入成功")

        }catch{
            NLog.log(error)
            return error.localizedDescription
        }
    }
}

extension UInt64{
    func fileSize()->String{
        if self >= 1_073_741_824 { // 1GB
            return String(format: "%.2fGB", Double(self) / 1_073_741_824)
        } else if self >= 1_048_576 { // 1MB
            return String(format: "%.2fMB", Double(self) / 1_048_576)
        } else if self >= 1_024 { // 1KB
            return String(format: "%dKB", self / 1_024)
        } else {
            return "\(self)B" // 小于 1KB 直接显示字节
        }
    }
}


#Preview {
    DataSettingView()
        .environmentObject(AppManager.shared)
}
