//
//  ImagesModel.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/27/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import ObjectMapper

struct ImageInfo: Mappable {
    var filePath: String?
    var height: Int?
    var width: Int?
    var aspectRatio: Double?
    var voteAverage: Double?
    var voteCount: Int?
    
    init?(_ map: Map) {
    }
    
    mutating func mapping(map: Map) {
        filePath<-map["file_path"]
        width<-map["width"]
        height<-map["height"]
        aspectRatio<-map["aspect_ratio"]
        voteAverage<-map["vote_average"]
        voteCount<-map["vote_count"]
    }
}

func == (lhs: ImageInfo, rhs: ImageInfo) -> Bool{
    return lhs.filePath == rhs.filePath
}

struct ImageInfoList: Mappable {
    var id: Int?
    var backdrops: [ImageInfo]?
    var posters: [ImageInfo]?
    
    init?(_ map: Map) {
    }
    
    mutating func mapping(map: Map) {
        id<-map["id"]
        backdrops<-map["backdrops"]
        posters<-map["posters"]
    }
}