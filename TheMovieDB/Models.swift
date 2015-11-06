//
//  Models.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/2/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import Foundation
import ObjectMapper

//_____________________Pagintation protocol______________________
protocol PaginationLoading {
    var hasMorePages: Bool { get }
    var nextPage: Int? { get }
}

//__________________Authorization request token__________________
class Token: NSObject, NSCoding, Mappable {
    var requestToken: String?
    var expireAt: String?
    var success: Bool?
    
    init?(token: String, expire: String?){
        requestToken = token
        expireAt = expire
        
        super.init()
        
        if token.isEmpty {
            return nil
        }
    }
    
    //MARK: Mappable protocol
    required init?(_ map: Map) {
    }

    func mapping(map: Map) {
        requestToken<-map["request_token"]
        expireAt<-map["expires_at"]
        success<-map["success"]
    }

    //MARK: NSCoding protocol
    required convenience init?(coder aDecoder: NSCoder) {
        let token = aDecoder.decodeObjectForKey("token") as? String
        let expire = aDecoder.decodeObjectForKey("expire") as? String
        
        self.init(token: token ?? "", expire: expire)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(requestToken, forKey: "token")
        aCoder.encodeObject(expireAt, forKey: "expire")
    }
}

//__________________Sesssion identificator__________________
class Session: NSObject, NSCoding, Mappable {
    var sessionToken: String?
    var success: Bool?
    
    init?(session: String) {
        sessionToken = session
        
        super.init()
        
        if session.isEmpty {
            return nil
        }
    }
    
    //MARK: Mappable protocol
    required init?(_ map: Map) {
    }
    
    func mapping(map: Map) {
        sessionToken<-map["session_id"]
        success<-map["success"]
    }
    
    //MARK: NSCoding protocol
    required convenience init?(coder aDecoder: NSCoder) {
        let session = aDecoder.decodeObjectForKey("session_id") as? String
        
        self.init(session: session ?? "")
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(sessionToken, forKey: "session_id")
    }
}

//__________________User account info__________________
struct Account: Mappable {
    var userId: Int?
    var username: String?
    var fullName: String?
    var langCode: String?
    var countryCode: String?
    var includeAdult: Bool?
    var gravatarHash: String?
    var gravatar: String {
        return "http://www.gravatar.com/avatar/\(gravatarHash!)?s=150"
    }
    
    //MARK: Mappable protocol
    init?(_ map: Map) {
    }
    
    mutating func mapping(map: Map) {
        userId<-map["id"]
        username<-map["username"]
        fullName<-map["name"]
        gravatarHash<-map["avatar.gravatar.hash"]
        langCode<-map["iso_639_1"]
        countryCode<-map["iso_3166_1"]
        includeAdult<-map["include_adult"]
    }
}

//__________________User's lists single item__________________
struct ListInfo: Mappable {
    var listId: String?
    var listName: String?
    var poster: String?
    var listDesc: String?
    var itemsInList: Int?
    var favoriteCount: Int?
    var listType: String?
    var langCode: String?
    var itemsCount: String {
        let count = itemsInList ?? 0
        return "\(count > 0 ? String(count) : "no") item\(count != 1 ? "s" : "")"
    }
    
    //MARK: Mappable protocol
    init?(_ map: Map) {
    }
    
    mutating func mapping(map: Map) {
        listId<-map["id"]
        listName<-map["name"]
        poster<-map["poster_path"]
        listDesc<-map["description"]
        itemsInList<-map["item_count"]
        favoriteCount<-map["favorite_count"]
        listType<-map["list_type"]
        langCode<-map["iso_639_1"]
    }
}

//__________________User's lists__________________
struct ListInfoPages: Mappable {
    var page: Int?
    var pagesTotal: Int?
    var resultsTotal: Int?
    var results: [ListInfo]?
    
    //MARK: Mappable protocol
    init?(_ map: Map) {
    }
    
    mutating func mapping(map: Map) {
        page<-map["page"]
        pagesTotal<-map["total_pages"]
        resultsTotal<-map["total_results"]
        results<-map["results"]
    }
}

//__________________User's list movie item__________________
struct ListItem: Mappable {
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
    
    //MARK: Mappable protocol
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

//__________________User's list info__________________
struct ListDetails: Mappable {
    var listId: String?
    var name: String?
    var createdBy: String?
    var description: String?
    var posterPath: String?
    var favoriteCount: Int?
    var itemsCount: Int?
    var langCode: String?
    var items: [ListItem]?
    
    //MARK: Mappable protocol
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
}

//__________________Search movies results item__________________
struct SearchMovieItem: Mappable, SearchViewRepresentation {
    var movieId: Int?
    var title: String?
    var titleOriginal: String?
    var overview: String?
    var genres: [Int]?
    var backdropPath: String?
    var posterPath: String?
    var releaseDate: String?
    var popularity: Double?
    var voteAverage: Double?
    var voteCount: Int?
    var originalLanguage: String?
    var video: Bool?
    var adult: Bool?
    
    //MARK: Mappable protocol
    init?(_ map: Map) {
    }
    
    mutating func mapping(map: Map) {
        movieId<-map["id"]
        title<-map["title"]
        titleOriginal<-map["original_title"]
        overview<-map["overview"]
        genres<-map["genre_ids"]
        backdropPath<-map["backdrop_path"]
        posterPath<-map["poster_path"]
        releaseDate<-map["release_date"]
        popularity<-map["popularity"]
        voteAverage<-map["vote_average"]
        voteCount<-map["vote_count"]
        originalLanguage<-map["original_language"]
        video<-map["video"]
        adult<-map["adult"]
    }
    
    //MARK: SearchViewRepresentation
    var representImage: String? {
        return ApiEndpoints.poster(3, posterPath ?? "")
    }
    var representTitle: String? {
        return title
    }
    var representDate: String? {
        return releaseDate
    }
    var representDescription: String? {
        return overview
    }
}

//__________________Search movies results__________________
struct SearchMovieResults: Mappable, PaginationLoading {
    var page: Int?
    var results: [SearchMovieItem]?
    var totalPages: Int?
    var totalItems: Int?
    
    //MARK: Mappable protocol
    init?(_ map: Map) {
    }
    
    mutating func mapping(map: Map) {
        page<-map["page"]
        results<-map["results"]
        totalPages<-map["total_pages"]
        totalItems<-map["total_results"]
    }
    
    //MARK: Pagintation
    var hasMorePages: Bool {
        return page < totalPages
    }
    
    var nextPage: Int? {
        return hasMorePages ? page! + 1 : nil
    }
}

//_____________________Search TV results item_____________________
struct SearchTVItem: Mappable, SearchViewRepresentation {
    var showId: Int?
    var name: String?
    var nameOriginal: String?
    var overview: String?
    var genres: [Int]?
    var backdropPath: String?
    var posterPath: String?
    var firstAirDate: String?
    var popularity: Double?
    var voteAverage: Double?
    var voteCount: Int?
    var originalLanguage: String?
    var originCountry: [String]?
    
    //MARK: Mappable protocol
    init?(_ map: Map) {
    }
    
    mutating func mapping(map: Map) {
        showId<-map["id"]
        name<-map["name"]
        nameOriginal<-map["original_name"]
        overview<-map["overview"]
        genres<-map["genre_ids"]
        backdropPath<-map["backdrop_path"]
        posterPath<-map["poster_path"]
        firstAirDate<-map["first_air_date"]
        popularity<-map["popularity"]
        voteAverage<-map["vote_average"]
        voteCount<-map["vote_count"]
        originalLanguage<-map["original_language"]
        originCountry<-map["origin_country"]
    }
    
    //MARK: SearchViewRepresentation
    var representImage: String? {
        return ApiEndpoints.poster(3, posterPath ?? "")
    }
    var representTitle: String? {
        return name
    }
    var representDate: String? {
        return firstAirDate
    }
    var representDescription: String? {
        return overview
    }
}
//__________________Search TV results__________________
struct SearchTVResults: Mappable, PaginationLoading {
    var page: Int?
    var results: [SearchTVItem]?
    var totalPages: Int?
    var totalItems: Int?
    
    //MARK: Mappable protocol
    init?(_ map: Map) {
    }
    
    mutating func mapping(map: Map) {
        page<-map["page"]
        results<-map["results"]
        totalPages<-map["total_pages"]
        totalItems<-map["total_results"]
    }
    
    //MARK: Pagintation
    var hasMorePages: Bool {
        return page < totalPages
    }
    
    var nextPage: Int? {
        return hasMorePages ? page! + 1 : nil
    }
}

//_____________________Search Person results item_____________________
struct SearchPersonItem: Mappable, SearchViewRepresentation {
    var personId: Int?
    var name: String?
    var profilePath: String?
    var popularity: Double?
    var adult: Bool?
    
    //MARK: Mappable protocol
    init?(_ map: Map) {
    }
    
    mutating func mapping(map: Map) {
        personId<-map["id"]
        name<-map["name"]
        popularity<-map["popularity"]
        profilePath<-map["profile_path"]
        adult<-map["adult"]
    }
    
    //MARK: SearchViewRepresentation
    var representImage: String? {
        return ApiEndpoints.poster(3, profilePath ?? "")
    }
    var representTitle: String? {
        return name
    }
    var representDate: String? { return "" }
    var representDescription: String? { return "" }
}
//__________________Search Person results__________________
struct SearchPersonResults: Mappable, PaginationLoading {
    var page: Int?
    var results: [SearchPersonItem]?
    var totalPages: Int?
    var totalItems: Int?
    
    //MARK: Mappable protocol
    init?(_ map: Map) {
    }
    
    mutating func mapping(map: Map) {
        page<-map["page"]
        results<-map["results"]
        totalPages<-map["total_pages"]
        totalItems<-map["total_results"]
    }
    
    //MARK: Pagintation
    var hasMorePages: Bool {
        return page < totalPages
    }
    
    var nextPage: Int? {
        return hasMorePages ? page! + 1 : nil
    }
}












