//
//  TaskDetailVO.swift
//  TransmissionClient-Swift
//
//  Created by SUN on 15/11/28.
//  Copyright © 2015年 SUN. All rights reserved.
//

import Foundation
import SwiftyJSON

class TaskDetailVO : NSObject {
    
    var id:Int  //任务ID
    
    var name:String //名称
    
    var _state:Int

    var state:String {
        get {
            switch _state {
            case 0 : return "暂停"
            case 4 : return "下载"
            case 6 : return "做种中"
            default : return "其他"
            }
        }
    }
    
    var size:Int
    
    var downloadSpeed:Int = 0
    
    var error:String?
    
    var _activityDate : Int?
    var activityDate : NSDate {
        get {
            if let date = _activityDate {
                return NSDate(timeIntervalSince1970: Double(date))
            }else{
                return NSDate(timeIntervalSince1970: 0)
            }
        }
    }
    
    var comment:String?
    
    var corruptEver:Int = 0
    
    var creator:String
    
    var _dateCreated:Int?
    var dateCreated : NSDate {
        get {
            if let date = _dateCreated {
                return NSDate(timeIntervalSince1970: Double(date))
            }else{
                return NSDate(timeIntervalSince1970: 0)
            }
        }
    }
    
    var desiredAvailable:Int = 0
    
    var updatedEver:Int = 0
    var downloadedEver:Int = 0
    
    var downloadDir:String = "/"
    
    var hashString:String?
    
    var haveUnchecked:Int = 0
    
    var haveValid:Int = 0
    
    var isPrivate:Bool = false
    
    var pieceCount:Int = 0
    
    var pieceSize:Int = 0
    
    var _startDate:Int?
    var startDate: NSDate {
        get {
            if let date = _startDate {
                return NSDate(timeIntervalSince1970: Double(date))
            }else{
                return NSDate(timeIntervalSince1970: 0)
            }
        }
    }
    
    var peers:[PeerVO]?
    
    var trackerStats:[TrackerStatVO]?
    
    var files:[FileVO]?
    
    init(json:JSON,size:Int,state:Int,error:String?) {
        
        let torrent = json["arguments"]["torrents"][0]
        
        self.id = torrent["id"].intValue
        self.name = torrent["name"].stringValue
        self.size = size
        self._state = state
        self.creator = torrent["creator"].stringValue
        self.error = error
        self.downloadSpeed = torrent["rateDownload"].intValue
        _activityDate = torrent["activityDate"].intValue
        comment = torrent["comment"].stringValue
        corruptEver = torrent["corruptEver"].intValue
        
        updatedEver = torrent["uploadedEver"].intValue
        downloadDir = torrent["downloadDir"].stringValue
        _dateCreated = torrent["dateCreated"].intValue
        desiredAvailable = torrent["desiredAvailable"].intValue
        downloadedEver = torrent["downloadedEver"].intValue
        hashString = torrent["hashString"].stringValue
        haveUnchecked = torrent["haveUnchecked"].intValue
        haveValid = torrent["haveValid"].intValue
        isPrivate = torrent["isPrivate"].boolValue
        pieceCount = torrent["pieceCount"].intValue
        pieceSize = torrent["pieceSize"].intValue
        _startDate = torrent["startDate"].intValue
        
        peers = PeerVO.generatePeerVOs(torrent)
        trackerStats = TrackerStatVO.generateTrackerVOs(torrent)
        files = FileVO.generateFileVOs(torrent)
    }
}

class PeerVO : NSObject{
    var address:String
    var clientIsChoked:Bool = false
    var clientIsInterested:Bool = false
    var clientName:String
    var flagStr:String?
    var isDownloadingFrom:Bool = false
    var isEncrypted:Bool = true
    var isIncoming:Bool = true
    var isUTP:Bool = false
    var isUploadingTo:Bool = false
    var peerIsChoked:Bool = false
    var peerIsInterested:Bool = false
    var port:Int
    var progress:Float = 0
    var rateToClient:Int = 0
    var rateToPeer:Int = 0
    
    init(clientName:String,address:String,port:Int){
        self.clientName = clientName
        self.address = address
        self.port = port
    }
    
    static func generatePeerVOs(json:JSON) -> [PeerVO]? {
        
        let _peers=json["peers"].array
        
        guard let peers = _peers else {
            return nil
        }
        
        var peerVOs:[PeerVO] = []
        
        for peer in peers {
            let clientName = peer["clientName"].stringValue
            let address = peer["address"].stringValue
            let port = peer["port"].intValue
            
            let peerVO = PeerVO(clientName: clientName, address: address, port: port)
            peerVOs.append(peerVO)
            
            peerVO.flagStr = peer["flagStr"].stringValue
            peerVO.progress = peer["progress"].floatValue
            peerVO.rateToClient = peer["rateToClient"].intValue
            peerVO.rateToPeer = peer["rateToPeer"].intValue
            
        }
        
        return peerVOs
    }
}

class TrackerStatVO : NSObject{
    var announce:String
    var announceState:Int = 0
    var hasAnnounced:Bool = true
    var hasScraped:Bool = false
    var host:String
    var id:Int
    var lastAnnouncePeerCount:Int = 0
    var lastAnnounceResult:String?
    var _lastAnnounceStartTime:Int?
    var lastAnnounceStartTime:NSDate{
        if let date = _lastAnnounceStartTime {
            return NSDate(timeIntervalSince1970: Double(date))
        }else{
            return NSDate(timeIntervalSince1970: 0)
        }
    }
    
    var lastAnnounceSucceeded:Bool = false
    
    var _lastAnnounceTime:Int?
    var lastAnnounceTime:NSDate {
        if let date = _lastAnnounceTime {
            return NSDate(timeIntervalSince1970: Double(date))
        }else{
            return NSDate(timeIntervalSince1970: 0)
        }
    }
    
    var lastAnnounceTimedOut:Bool = false
    
    var downloadCount:Int = 0
    var leecherCount:Int = 0
    var seederCount:Int = 0
    
    var _nextAnnounceTime:Int?
    var nextAnnounceTime:NSDate {
        if let date = _nextAnnounceTime {
            return NSDate(timeIntervalSince1970: Double(date))
        }else{
            return NSDate(timeIntervalSince1970: 0)
        }
    }
    
    var _lastScrapeStartTime:Int?
    var lastScrapeStartTime:NSDate {
        if let date = _lastScrapeStartTime {
            return NSDate(timeIntervalSince1970: Double(date))
        }else{
            return NSDate(timeIntervalSince1970: 0)
        }
    }
    
    var tier:Int = 0
    
    init(id:Int,host:String,announce:String){
        self.id = id
        self.host = host
        self.announce = announce
    }
    
    static func generateTrackerVOs(json:JSON) -> [TrackerStatVO]? {
        
        let _trackerStats=json["trackerStats"].array
        
        guard let trackerStats = _trackerStats else {
            return nil
        }
        
        var trackerStatVOs:[TrackerStatVO] = []
        
        for trackerStat in trackerStats {
            let id = trackerStat["id"].intValue
            let host = trackerStat["host"].stringValue
            let announce = trackerStat["announce"].stringValue
            
            let trackerStatVO = TrackerStatVO(id: id, host: host, announce: announce)
            trackerStatVOs.append(trackerStatVO)
            
            trackerStatVO._lastAnnounceTime = trackerStat["lastAnnounceTime"].intValue
            trackerStatVO.lastAnnounceSucceeded = trackerStat["lastAnnounceSucceeded"].boolValue
            trackerStatVO.lastAnnouncePeerCount = trackerStat["lastAnnouncePeerCount"].intValue
            
            trackerStatVO._nextAnnounceTime = trackerStat["nextAnnounceTime"].intValue
            trackerStatVO._lastScrapeStartTime = trackerStat["lastScrapeStartTime"].intValue
            
            trackerStatVO.seederCount = trackerStat["seederCount"].intValue
            trackerStatVO.leecherCount = trackerStat["leecherCount"].intValue
            trackerStatVO.downloadCount = trackerStat["downloadCount"].intValue
        }
        
        return trackerStatVOs
        
    }
    
}

class FileVO : NSObject{
    var id:String = ""
    var pid:String?
    var layer:Int = 0       //层次
    var expand:Bool = false  //是否展开
    var isLeaf:Bool = true      //是否是叶子节点
    var bytesCompleted:Int = 0
    var length:Int
    var name:String
    var priority:Int = 0
    var wanted:Bool = true
    
    init(layer:Int = 0,name:String,length:Int){
        self.layer = layer
        self.name = name
        self.length = length
    }
    
    static func generateFileVOs(json:JSON) -> [FileVO]? {
        
        let _files=json["files"].array
        
        let _fileStats=json["fileStats"].array
        
        guard let files = _files,fileStats = _fileStats else {
            return nil
        }

        var fileVOs:[FileVO] = []
        
        for (index,file) in files.enumerate() {
            let name = file["name"].stringValue
            let length = file["length"].intValue
            let splits = name.componentsSeparatedByString("/")
            
            var pid:String?
            if  splits.count > 1 {
                var tmpFile:FileVO? = nil
                for i in 0 ..< (splits.count-1 < 0 ? 0 : splits.count-1) {
                    let sp = splits[i]
                    var find = false
                    for tmp in fileVOs {
                        if  tmp.name == sp {
                            //表示有这个了
                            find = true
                            pid = tmp.id
                            tmpFile = tmp
                            break
                        }
                    }
                    if !find {
                        //如果没有找到,那么就要新增这个节点
                        tmpFile = createFileNode(sp, parentNode: tmpFile)
                        fileVOs.append(tmpFile!)
                        pid = tmpFile!.id
                    }
                }
            }
            
            let fileVO = FileVO(name: splits.last!, length: length)
            fileVOs.append(fileVO)
            
            fileVO.id = NSUUID().UUIDString
            fileVO.pid = pid
            fileVO.layer = splits.count
            fileVO.isLeaf = true
            fileVO.bytesCompleted = file["bytesCompleted"].intValue
            fileVO.priority = fileStats[index]["priority"].intValue
            fileVO.wanted = fileStats[index]["wanted"].boolValue
        }
        
        //这里还要递归的修正父节点的大小和状态
        if fileVOs.count > 0 {
            calcuateFileSize(fileVOs[0], files: fileVOs)
        }
        
        return fileVOs
    }
    
    /**
     递归计算文件夹的大小
     
     - parameter file:
     - parameter files:
     
     - returns: 元组, 第一个是TotalLength,第二个是已下载大小
     */
    private static func calcuateFileSize(file:FileVO,files:[FileVO]) -> (Int,Int,Bool) {
        
        if  file.isLeaf {
            return (file.length,file.bytesCompleted,file.wanted)
        }
        
        var (length,bytesCompleted,wanted):(Int,Int,Bool) = (0,0,true)
        
        for f in files {
            if f.pid == file.id {
                //找到子
                let (a,b,c) = calcuateFileSize(f, files: files)
                length = length + a
                bytesCompleted = bytesCompleted + b
                wanted = wanted || c
            }
        }
        
        file.length = length
        file.bytesCompleted = bytesCompleted
        file.wanted = wanted
        
        return (length,bytesCompleted,wanted)
    }
    
    private static func createFileNode(name:String,parentNode:FileVO?) ->FileVO{
        
        let fileVO = FileVO(name: name, length: -1)
        fileVO.id = NSUUID().UUIDString
        fileVO.pid = parentNode?.id
        fileVO.isLeaf = false
        fileVO.layer = parentNode==nil ? 1 : (parentNode!.layer + 1)
        fileVO.expand = parentNode==nil ? true : false
        
        return fileVO
    }
}