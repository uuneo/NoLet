//
//  PushParams.swift
//  pushback
//
//  Created by lynn on 2025/3/31.
//

import UserNotifications

enum Params: String, CaseIterable{
    case  id, title, subtitle, body, from, host, group, url, category, level, ttl,
          currentindex, totalcount,
          sound, volume, badge, call,
          callback, autocopy, copy, widget,
          icon, image, savealbum,
          ciphertext, ciphernumber, iv,
          aps, alert, caf
    
    var name:String{ self.rawValue }
}


extension [AnyHashable : Any]{
    
    func raw<T:Any>(_ params: Params)-> T?{
        return raw(params) as? T
    }
    
    func raw(_ params: Params)-> Any? {
        switch params {
        case .title,.subtitle, .body:
            let alert = (self[Params.aps.name] as? [String: Any])?[Params.alert.name] as? [String: Any]
            return alert?[params.name]
        case .sound:
            return (self[Params.aps.name] as? [AnyHashable: Any])?[Params.sound.name]
        default:
            if let data = self[params.name] as? String, let intValue = Int(data) {
                return intValue
            } else if let intValue = self[params.name] as? Int {
                return intValue
            }
            
            return self[params.name]
        }
    }
    
    func voiceText() -> String{
        var text:[String] = []
        
        if let title:String = self.raw(Params.title){
            text.append(title)
        }
        
        if let subtitle:String = self.raw(Params.subtitle){
            text.append(subtitle)
        }
        
        if let body:String = self.raw(Params.body){
            text.append(PBMarkdown.plain(body))
        }
        
        return text.joined(separator: ",")
    }
}

