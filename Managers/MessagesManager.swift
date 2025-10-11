//
//  MessagesManager.swift
//  pushback
//
//  Created by lynn on 2025/5/26.
//
import Foundation
import GRDB

class MessagesManager: ObservableObject{
    static let shared =  MessagesManager()
    
    private let DB: DatabaseManager = DatabaseManager.shared
    private var observationCancellable: AnyDatabaseCancellable?
    
    @Published var unreadCount: Int = 0
    @Published var allCount: Int = 9999999
    @Published var updateSign:Int = 0
    @Published var groupMessages: [Message] = []
    @Published var showGroupLoading:Bool = false
    
    private init() { startObservingUnreadCount() }
    
    deinit{ observationCancellable?.cancel() }
    
    private var updateLoading:Bool = false
    
    private func startObservingUnreadCount() {
        let observation = ValueObservation.tracking { db -> (Int,Int) in
            let unRead = try Message.filter(Message.Columns.read == false).fetchCount(db)
            let count = try Message.fetchCount(db)
            return (unRead,count)
        }
        
        observationCancellable = observation.start(
            in: DB.dbQueue,
            scheduling: .async(onQueue: .global()),
            onError: { error in
                NLog.error("Failed to observe unread count:", error)
            },
            onChange: { [weak self] newUnreadCount in
                NLog.log("🧲: 监听 Message: \(newUnreadCount)")
                guard let self else{ return }
                DispatchQueue.main.async {
                    self.showGroupLoading = true
                    self.updateSign += 1
                    self.unreadCount = newUnreadCount.0
                    self.allCount = newUnreadCount.1
                }
                Task.detached(priority: .userInitiated) {
                    await self.updateGroup()
                    await MainActor.run {
                        self.showGroupLoading = false
                    }
                }
            }
        )
    }
    
    func updateGroup() async {
        guard !updateLoading else{ return }
        await MainActor.run {
            self.updateLoading = true
        }
        let results = await self.queryGroup()
        let count   = self.count()
        let unCount = self.unreadCount()
        await MainActor.run { [weak self] in
            self?.groupMessages = results
            self?.updateSign += 1
            self?.allCount = count
            self?.unreadCount = unCount
            self?.updateLoading = false
        }
    }
}

extension MessagesManager{
    static func examples() ->[Message]{
        [
            Message(id: UUID().uuidString, group: "Markdown", createDate: .now,
                    title: String(localized: "示例"),
                    body: "# Pushback \n## Pushback \n### Pushback", level: 1, ttl: 1, read: false),
            
            Message(id: UUID().uuidString, group: String(localized: "示例"), createDate: .now + 10,
                    title: String(localized: "使用方法"),
                    body: String(localized:  """
                        * 左上角功能菜单，使用示例，分组
                        * 右上角按时间删除消息
                        * 单击图片/双击消息全屏查看
                        * 全屏查看，翻译，总结，朗读
                        * 左滑删除，右滑复制和智能解答。
                        """),
                    level: 1, ttl: 1, read: false),
            
            Message(id: UUID().uuidString, group: "App", createDate: .now ,
                    title: String(localized: "点击跳转app"),
                    body: String(localized:  "url属性可以打开URLScheme, 点击通知消息自动跳转，前台收到消息自动跳转"),
                    url: "weixin://", level: 1, ttl: 1, read: false)
        ]
    }
    
    func all() async throws -> [Message] {
        try await self.DB.dbQueue.read({ db in
            try Message.order(Message.Columns.createDate.desc).fetchAll(db)
        })
    }
    
    func updateRead() async -> Int? {
       return try? await DB.dbQueue.write { db in
            // 批量更新 read 字段为 true
            try Message
                .filter(Message.Columns.read == false)
                .updateAll(db, [Message.Columns.read.set(to: true)])
        }
    }
    
    func unreadCount(group: String? = nil) -> Int {
        do{
            return try DB.dbQueue.read { db in
                var request = Message.filter(Message.Columns.read == false)
                
                if let group = group {
                    request = request.filter(Message.Columns.group == group)
                }
                
                return try request.fetchCount(db)
            }
        }catch{
            NLog.error("查询失败")
            return 0
        }
        
    }
    
    func count(group: String? = nil) -> Int {
        do{
            return try DB.dbQueue.read { db in
                if let group = group{
                    return  try Message.filter(Message.Columns.group == group).fetchCount(db)
                }else {
                    return  try Message.fetchCount(db)
                }
                
            }
        }catch{
            NLog.error(error.localizedDescription)
            return 0
        }
    }
    
    func add(_ message: Message) async  {
        do {
            try await DB.dbQueue.write { db in
                try message.insert(db, onConflict: .replace)
            }
        } catch {
            NLog.error("Add or update message failed:", error)
        }
    }
    
    func query(id: String) -> Message? {
        do {
            return try  DB.dbQueue.read { db in
                try Message.fetchOne(db, key: id)
            }
        } catch {
            NLog.error("Failed to query message by id:", error)
            return nil
        }
    }
    
    func query(id: String) async -> Message? {
        do {
            return try await  DB.dbQueue.read { db in
                try Message.fetchOne(db, key: id)
            }
        } catch {
            NLog.error("Failed to query message by id:", error)
            return nil
        }
    }
    
    func searchRequest(search: String,group: String? = nil, date: Date? = nil) -> QueryInterfaceRequest<Message>{
        // 1. 分词，去掉空字符串
        let keywords = search
            .split(separator: " ")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        var request = Message.order(Message.Columns.createDate.desc)
        
        // 2. 多关键词叠加 AND 条件
        for keyword in keywords {
            let escaped = keyword
                .replacingOccurrences(of: "%", with: "\\%")
                .replacingOccurrences(of: "_", with: "\\_")
            
            let pattern = "%\(escaped)%"
            
            // 每个关键词作用在所有字段：用 OR
            let perKeywordFilter =
            Message.Columns.title.like(pattern)
            || Message.Columns.subtitle.like(pattern)
            || Message.Columns.body.like(pattern)
            || Message.Columns.group.like(pattern)
            || Message.Columns.url.like(pattern)
            
            // 每个关键词之间用 AND 累加
            request = request.filter(perKeywordFilter)
        }
        
        // 3. 附加其他过滤条件
        if let group = group {
            request = request.filter(Message.Columns.group == group)
        }
        
        if let date = date {
            request = request.filter(Message.Columns.createDate < date)
        }
        
        return request
    }
    
    func query(search: String,
               group: String? = nil,
               limit lim: Int = 50,
               _ date: Date? = nil) async -> ([Message], Int) {
        let start = CFAbsoluteTimeGetCurrent()
        
        let request = searchRequest(search: search, group: group, date: date)

        
        do {
            async let datas = DB.dbQueue.read { db in
                return try request.limit(lim).fetchAll(db)
            }
            
            async let counts = DB.dbQueue.read { db in
                return  try request.fetchCount(db)
            }
            
            let (results, total) = try await (datas, counts)
            
            let diff = CFAbsoluteTimeGetCurrent() - start
            NLog.log("⏱️ \(search)-用时: \(diff)s")
            return (results, total)
        } catch {
            NLog.error("Query error: \(error)")
            return ([], 0)
        }
    }
    
    
    func queryGroup() async -> [Message]{
        do {
            return try await DB.dbQueue.read { db in
                try self.fetchGroupedMessages(from: db)
            }
        } catch {
            NLog.error("Failed to query messages:", error)
            return []
        }
    }
    
    func queryGroup() -> [Message] {
        do {
            return try DB.dbQueue.read { db in
                try self.fetchGroupedMessages(from: db)
            }
        } catch {
            NLog.error("Failed to query messages:", error)
            return []
        }
    }
    
    
    private func fetchGroupedMessages(from db: Database) throws -> [Message] {
        
        let rows = try Row.fetchAll(db, sql: """
            SELECT m.*, unread.count AS unreadCount
            FROM (
                SELECT *
                FROM (
                    SELECT *,
                           ROW_NUMBER() OVER (PARTITION BY "group" ORDER BY createdate DESC, id DESC) AS rn
                    FROM message
                )
                WHERE rn = 1
            ) AS m
            LEFT JOIN (
                SELECT "group", COUNT(*) AS count
                FROM message
                WHERE read = 0
                GROUP BY "group"
            ) AS unread
            ON m."group" = unread."group"
            ORDER BY unread.count DESC NULLS LAST, m.createdate DESC
        """)
        
        return try rows.map { try Message(row: $0) }
    }
    
    func query(group: String? = nil, limit lim: Int = 100, _ date: Date? = nil) async -> [Message] {
        do {
            return try await  DB.dbQueue.read { db in
                var request = Message.order(Message.Columns.createDate.desc)
                
                if let group = group {
                    request = request.filter(Message.Columns.group == group)
                }
                
                if let date = date {
                    request = request.filter(Message.Columns.createDate < date)
                }
                
                return try request.limit(lim).fetchAll(db)
            }
        } catch {
            NLog.error("Query failed:", error)
            return []
        }
    }
    
    func markAllRead(group: String? = nil) async {
        do{
            try await self.DB.dbQueue.write { db in
                var request = Message.filter(Message.Columns.read == false)
                if let group = group {
                    request = request.filter(Message.Columns.group == group)
                }
                try request.updateAll(db, [Message.Columns.read.set(to: true)])
            }
        }catch{
            NLog.error("markAllRead error")
        }
    }
    
    func delete(allRead: Bool = false, date: Date? = nil) async {
        do {
            try await self.DB.dbQueue.write { db in
                var request = Message.all()
                
                // 构建查询条件
                if allRead, let date = date {
                    request = request
                        .filter(Message.Columns.read == true)
                        .filter(Message.Columns.createDate < date)
                } else if allRead {
                    request = request.filter(Message.Columns.read == true)
                } else if let date = date {
                    request = request.filter( Message.Columns.createDate < date)
                } else {
                    return // 没有任何条件，不执行删除
                }
                
                try request.deleteAll(db)
            }
            
            try await self.DB.dbQueue.vacuum()
            
        } catch {
            NLog.error("删除消息失败: \(error)")
        }
    }
    
    func delete(_ message: Message, in group: Bool = false) async -> Int {
        do {
            if group{
                return try await DB.dbQueue.write { db in
                    try Message
                        .filter(Message.Columns.group == message.group)
                        .deleteAll(db)
                    
                    return try Message.filter(Message.Columns.group == message.group).fetchCount(db)
                }
            }
            return try await DB.dbQueue.write { db in
                try message.delete(db)
                return try Message.filter(Message.Columns.group == message.group).fetchCount(db)
            }
        } catch {
            NLog.error("删除消息失败：\(error)")
        }
        return -1
    }
    
    func delete(_ messageId: String) -> String?{
        do{
            return  try DB.dbQueue.write { db in
                if  let message = try Message.filter(Message.Columns.id == messageId).fetchOne(db){
                    try message.delete(db)
                    return message.group
                }
                return nil
            }
        }catch{
            NLog.error("删除消息失败：\(error)")
            return nil
        }
        
    }
    
    func deleteExpired() async {
        
        do{
            try await DB.dbQueue.write { db in
                let now = Date()
                let cutoffDateExpr = now.addingTimeInterval(-1) // 当前时间
                
                // 删除逻辑：
                // ttl != forever（-1） 并且 createDate + ttl天 < now
                try db.execute(sql: """
                        DELETE FROM message
                        WHERE ttl != ?
                          AND datetime(createdate, '+' || ttl || ' days') < ?
                    """, arguments: [ExpirationTime.forever.rawValue, cutoffDateExpr])
            }
        }catch{
            NLog.error("删除失败")
        }
        
        
    }
    
    static func ensureMarkdownLineBreaks(_ text: String) -> String {
        // 将文本按行分割
        let lines = text.components(separatedBy: .newlines)
        
        // 处理每一行：检查结尾是否已经有两个空格
        let processedLines = lines.map { line in
            if line.hasSuffix("  ") || line.isEmpty {
                return line
            } else {
                return line + "  "  // 添加两个空格
            }
        }
        
        // 使用 \n 连接回去
        return processedLines.joined(separator: "\n")
    }
    
    static func createStressTest(
        max number: Int = 50_000,
        len textLength: Int = 500
    ) async -> Bool {
        
        do {

            try await Self.shared.DB.dbQueue.write { db in
                let body = Domap.generateRandomString(textLength)
                try autoreleasepool {
                    for k in 0..<number {
                        
                        let message = Message(
                            id: UUID().uuidString, group: "\(k % 10)",
                            createDate: .now, title: "\(k) Test",
                            body: "Text Data \(body)", level: 1, ttl: 1, read: true
                        )
                        try message.insert(db)
                    }
                }
            }
            return true
        } catch {
            NLog.error("创建失败")
            return false
        }
    }
}
