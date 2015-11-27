//
//  CompilationModel.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/27/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import ObjectMapper

struct CompilationInfo: Mappable, SegmentsRepresentation {
    var listId: String?
    var listName: String?
    var posterPath: String?
    var listDesc: String?
    var itemsInList: Int?
    var favoriteCount: Int?
    var listType: String?
    var langCode: String?
    
    init?(_ map: Map) {
    }
    
    mutating func mapping(map: Map) {
        listId<-map["id"]
        listName<-map["name"]
        posterPath<-map["poster_path"]
        listDesc<-map["description"]
        itemsInList<-map["item_count"]
        favoriteCount<-map["favorite_count"]
        listType<-map["list_type"]
        langCode<-map["iso_639_1"]
    }
    
    //MARK: SegementsRepresentation
    var id: String? {
        return listId
    }
    
    var representTitle: String? {
        return listName
    }
    
    var representDescription: String? {
        return listDesc
    }
    
    var representImage: String? {
        if let path = posterPath {
            return ImagesConfig.poster(2, path)
        }
        return nil
    }
    
    var representCounter: String? {
        let count = itemsInList ?? 0
        return "\(count > 0 ? String(count) : "no") item\(count != 1 ? "s" : "")"
    }
    
}

struct CompilationInfoPages: Mappable, PaginationLoading {
    var page: Int?
    var totalPages: Int?
    var totalResults: Int?
    var results: [CompilationInfo]?
    
    var resultsRepresentative: [SegmentsRepresentation]? {
        get {
            guard let res = results else { return nil }
            
            var array = [SegmentsRepresentation]()
            for info in res {
                array.append(info as SegmentsRepresentation)
            }
            return array
        }
    }
    
    init?(_ map: Map) {
    }
    
    mutating func mapping(map: Map) {
        page<-map["page"]
        totalPages<-map["total_pages"]
        totalResults<-map["total_results"]
        results<-map["results"]
    }
}

struct CompilationItem: Mappable {
    var itemId: Int?
    var title: String?
    var originalTitle: String?
    var popularity: Double?
    var voteAverage: Double?
    var voteCount: Int?
    var releaseDate: String?
    var backdropPath: String?
    var posterPath: String?
    var adult: Bool?
    
    init?(_ map: Map) {
    }
    
    mutating func mapping(map: Map) {
        itemId<-map["id"]
        title<-map["title"]
        originalTitle<-map["original_title"]
        popularity<-map["popularity"]
        voteAverage<-map["vote_average"]
        voteCount<-map["vote_count"]
        releaseDate<-map["release_date"]
        backdropPath<-map["backdrop_path"]
        posterPath<-map["poster_path"]
        adult<-map["adult"]
    }
}

struct CompilationDetails: Mappable {
    var listId: String?
    var name: String?
    var createdBy: String?
    var description: String?
    var posterPath: String?
    var favoriteCount: Int?
    var itemsCount: Int?
    var langCode: String?
    var items: [CompilationItem]?
    
    init?(_ map: Map) {
    }
    
    mutating func mapping(map: Map) {
        listId<-map["id"]
        name<-map["name"]
        createdBy<-map["created_by"]
        description<-map["description"]
        posterPath<-map["poster_path"]
        favoriteCount<-map["favorite_count"]
        itemsCount<-map["item_count"]
        langCode<-map["iso_639_1"]
        items<-map["items"]
        
    }
    
    struct UpdateBody: Mappable {
        var mediaId: Int?
        
        init(mediaId id: Int) {
            mediaId = id
        }
        
        init?(_ map: Map) {
        }
        
        mutating func mapping(map: Map) {
            mediaId<-map["media_id"]
        }
    }
}
struct SegmentListItem: Mappable, SegmentsRepresentation {
    var itemId: Int?
    var title: String?
    var titleOriginal: String?
    var releaseDate: String?
    var posterPath: String?
    var backdropPath: String?
    var voteAverage: Double?
    var voteCount: Int?
    var rating: Int?
    
    init?(_ map: Map) {
    }
    
    mutating func mapping(map: Map) {
        itemId<-map["id"]
        title<-map["title"]
        titleOriginal<-map["original_title"]
        releaseDate<-map["release_date"]
        posterPath<-map["poster_path"]
        backdropPath<-map["backdrop_path"]
        voteAverage<-map["vote_average"]
        voteCount<-map["vote_count"]
        rating<-map["rating"]
    }
    
    //MARK: SegementsRepresentation
    var id: String? {
        if let id = itemId {
            return String(id)
        } else {
            return ""
        }
    }
    
    var representTitle: String? {
        return title
    }
    
    var representDescription: String? {
        return releaseDate?.stringByReplacingOccurrencesOfString("-", withString: "/")
    }
    
    var representImage: String? {
        if let path = posterPath {
            return ImagesConfig.poster(2, path)
        }
        return nil
    }
    
    var representCounter: String? {
        return "\(voteAverage!) (\(voteCount!))"
    }
}

struct SegmentList: Mappable, PaginationLoading {
    var page: Int?
    var totalPages: Int?
    var totalResults: Int?
    var results: [SegmentListItem]?
    var resultsRepresentative: [SegmentsRepresentation]? {
        get {
            guard let res = results else { return nil }
            
            var array = [SegmentsRepresentation]()
            for info in res {
                array.append(info as SegmentsRepresentation)
            }
            return array
        }
    }
    
    init?(_ map: Map) {
    }
    
    mutating func mapping(map: Map) {
        page<-map["page"]
        totalPages<-map["total_pages"]
        totalResults<-map["total_results"]
        results<-map["results"]
    }
}