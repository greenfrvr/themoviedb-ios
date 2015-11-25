//
//  Models.swift
//  TheMovieDB
//
//  Created by Artsiom Grintsevich on 11/2/15.
//  Copyright © 2015 Artsiom Grintsevich. All rights reserved.
//

import ObjectMapper
import Locksmith

//_____________________Pagintation protocol______________________
protocol PaginationLoading {
    var hasMorePages: Bool { get }
    var nextPage: Int? { get }
}

//__________________Authorization request token__________________
class Token: Mappable {
    var requestToken: String?
    var expireAt: String?
    var success: Bool?
    
    init?(token: String, expire: String?){
        requestToken = token
        expireAt = expire
        
        if token.isEmpty {
            return nil
        }
    }
    
    required init?(_ map: Map) {
    }

    func mapping(map: Map) {
        requestToken<-map["request_token"]
        expireAt<-map["expires_at"]
        success<-map["success"]
    }
}

//__________________Sesssion identificator__________________
class Session: Mappable, CreateableSecureStorable, GenericPasswordSecureStorable  {
    var sessionToken: String?
    var success: Bool?
    
    init?(session: String) {
        sessionToken = session
        if session.isEmpty {
            return nil
        }
    }
    
    required init?(_ map: Map) {}
    
    func mapping(map: Map) {
        sessionToken<-map["session_id"]
        success<-map["success"]
    }
    
    //MARK: Locksmith
    let service = Cache.serviceName
    var account: String { return Cache.userAccount }
    var data: [String: AnyObject] {
        if let token = sessionToken {
            return ["sessionId": token]
        }
        return [:]
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
    
    init(){}
    
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
struct ListInfo: Mappable, SegmentsRepresentation {
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

//__________________User's lists__________________
struct ListInfoPages: Mappable, PaginationLoading {
    var page: Int?
    var totalPages: Int?
    var totalResults: Int?
    var results: [ListInfo]?
    var resultsRepresentative: [SegmentsRepresentation]? {
        get {
            var array: [SegmentsRepresentation]!
            if let res = results {
                array = [SegmentsRepresentation]()
                for info in res {
                    array.append(info as SegmentsRepresentation)
                }
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
    
    //MARK: Pagintation
    var hasMorePages: Bool {
        return page < totalPages
    }
    
    var nextPage: Int? {
        return hasMorePages ? page! + 1 : nil
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
    
    struct UpdateListBody: Mappable {
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
        if let path = posterPath {
            return ImagesConfig.poster(2, path)
        }
        return nil
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
        if let path = posterPath {
            return ImagesConfig.poster(2, path)
        }
        return nil
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
        if let path = profilePath {
            return ImagesConfig.profile(2, path)
        }
        return nil
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

//____________________Movie info___________________
struct MovieInfo: Mappable {
    var movieId: Int?
    var imdbId: String?
    var title: String?
    var tagline: String?
    var overview: String?
    var genres: [Genre]?
    var runtime: Int?
    var voteAverage: Double?
    var voteCount: Int?
    var releaseDate: String?
    var budget: Int?
    var revenue: Int?
    var posterPath: String?
    
    init?(_ map: Map) {
    }
    
    mutating func mapping(map: Map) {
        movieId<-map["id"]
        imdbId<-map["imdb_id"]
        title<-map["title"]
        tagline<-map["tagline"]
        overview<-map["overview"]
        genres<-map["genres"]
        runtime<-map["runtime"]
        voteAverage<-map["vote_average"]
        voteCount<-map["vote_count"]
        releaseDate<-map["release_date"]
        budget<-map["budget"]
        revenue<-map["revenue"]
        posterPath<-map["poster_path"]
    }
    
    struct Genre: Mappable {
        var id: String?
        var name: String?
        
        init?(_ map: Map) {
        }
        
        mutating func mapping(map: Map) {
            id<-map["id"]
            name<-map["name"]
        }
    }
}

struct Credits: Mappable {
    var id: Int?
    var casts: [Cast]?
    
    init?(_ map: Map) {
    }
    
    mutating func mapping(map: Map) {
        id<-map["id"]
        casts<-map["cast"]
    }
    
    struct Cast: Mappable {
        var id: Int?
        var castId: Int?
        var creditId: String?
        var name: String?
        var character: String?
        var profilePath: String?
        var order: Int?
        
        init?(_ map: Map) {
        }
        
        mutating func mapping(map: Map) {
            id<-map["id"]
            castId<-map["cast_id"]
            creditId<-map["credit_id"]
            name<-map["name"]
            character<-map["character"]
            profilePath<-map["profile_path"]
            order<-map["order"]
        }
    }
}

struct TvShowInfo: Mappable {
    var tvShowId: Int?
    var name: String?
    var homepage: String?
    var overview: String?
    var numberOfSeasons: Int?
    var numberOfEpisodes: Int?
    var lastAirDate: String?
    var posterPath: String?
    var voteAverage: Double?
    var voteCount: Int?
    var seasons: [Season]?
    var createdBy: [Creator]?
    
    init?(_ map: Map) {
    }
    
    mutating func mapping(map: Map) {
        tvShowId<-map["id"]
        name<-map["name"]
        homepage<-map["homepage"]
        overview<-map["overview"]
        numberOfSeasons<-map["number_of_seasons"]
        numberOfEpisodes<-map["number_of_episodes"]
        lastAirDate<-map["last_air_date"]
        posterPath<-map["poster_path"]
        voteAverage<-map["vote_average"]
        voteCount<-map["vote_count"]
        seasons<-map["seasons"]
        createdBy<-map["created_by"]
    }
    
    struct Season: Mappable {
        var id: Int?
        var seasonNumber: Int?
        var episodeCount: Int?
        var airDate: String?
        var posterPath: String?
        
        init?(_ map: Map) {
        }
        
        mutating func mapping(map: Map) {
            id<-map["id"]
            seasonNumber<-map["season_number"]
            episodeCount<-map["episode_count"]
            airDate<-map["air_date"]
            posterPath<-map["poster_path"]
        }
    }
    
    struct Creator: Mappable {
        var id: Int?
        var name: String?
        var profilePath: String?
        
        init?(_ map: Map) {
        }
        
        mutating func mapping(map: Map) {
            id<-map["id"]
            name<-map["name"]
            profilePath<-map["profile_path"]
        }
    }
}

struct PersonInfo: Mappable {
    var personId: Int?
    var name: String?
    var biography: String?
    var birthday: String?
    var deathday: String?
    var birthplace: String?
    var profilePath: String?
    var homepage: String?
    
    init?(_ map: Map) {
    }
    
    mutating func mapping(map: Map) {
        personId<-map["id"]
        name<-map["name"]
        biography<-map["biography"]
        birthday<-map["birthday"]
        deathday<-map["deathday"]
        birthplace<-map["place_of_birth"]
        profilePath<-map["profile_path"]
        homepage<-map["homepage"]
    }
}

/*
{
"adult": false,
"character": "Tristan Ludlow",
"credit_id": "52fe43c4c3a36847f806e20d",
"id": 4476,
"original_title": "Legends of the Fall",
"poster_path": "/uh0sJcx3SLtclJSuKAXl6Tt6AV0.jpg",
"release_date": "1994-12-16",
"title": "Legends of the Fall",
"media_type": "movie"
}
*/

struct PersonCredits: Mappable {
    var id: Int?
    var cast: [Cast]?
    
    init?(_ map: Map) {
    }
    
    mutating func mapping(map: Map) {
        id<-map["id"]
        cast<-map["cast"]
    }
    
    struct Cast: Mappable {
        var itemId: Int?
        var creditId: String?
        var type: String?
        var title: String?
        var titleOriginal: String?
        var character: String?
        var releaseDate: String?
        var posterPath: String?
        
        init?(_ map: Map) {
        }
        
        mutating func mapping(map: Map) {
            itemId<-map["id"]
            creditId<-map["credit_id"]
            type<-map["media_type"]
            title<-map["title"]
            titleOriginal<-map["original_title"]
            character<-map["character"]
            releaseDate<-map["release_date"]
            posterPath<-map["poster_path"]
        }
    }
}

//____________________Movie image info___________________
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

//____________________Movie images list (including both backdrops and posters)___________________
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

//____________________Movie status (rated, favorite, in watchlist, etc)___________________
struct AccountState: Mappable {
    var movieId: Int?
    var favorite: Bool?
    var watchlist: Bool?
    var ratedValue: Double?
    
    init?(_ map: Map) {
    }
    
    mutating func mapping(map: Map) {
        movieId<-map["id"]
        favorite<-map["favorite"]
        watchlist<-map["watchlist"]
        ratedValue<-map["rated.value"]
    }
}

//____________________Favorite state change request body___________________
struct FavoriteBody: Mappable {
    var mediaId: Int?
    var mediaType: String?
    var favorite: Bool?
    
    init(id: Int?, type: String?, favorite: Bool?){
        self.mediaId = id
        self.mediaType = type
        self.favorite = favorite
    }
    
    init(movieId id: Int?, isFavorite: Bool?) {
        self.init(id: id, type: "movie", favorite: isFavorite)
    }

    init(tvShowId id: Int?, isFavorite: Bool?) {
        self.init(id: id, type: "tv", favorite: isFavorite)
    }
    
    init?(_ map: Map) {
    }
    
    mutating func mapping(map: Map) {
        mediaId<-map["media_id"]
        mediaType<-map["media_type"]
        favorite<-map["favorite"]
    }
}

//____________________Watchlist state change request body___________________
struct WatchlistBody: Mappable {
    var mediaId: Int?
    var mediaType: String?
    var watchlist: Bool?
    
    init(id: Int?, type: String?, watchlist: Bool?){
        self.mediaId = id
        self.mediaType = type
        self.watchlist = watchlist
    }
    
    init(movieId id: Int?, isInWatchlist: Bool?) {
        self.init(id: id, type: "movie", watchlist: isInWatchlist)
    }
    
    init(tvShowId id: Int?, isInWatchlist: Bool?) {
        self.init(id: id, type: "tv", watchlist: isInWatchlist)
    }
    
    init?(_ map: Map) {
    }
    
    mutating func mapping(map: Map) {
        mediaId<-map["media_id"]
        mediaType<-map["media_type"]
        watchlist<-map["watchlist"]
    }
}

//____________________User defined segment list single item___________________
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
    var results: [SegmentListItem]?
    var totalPages: Int?
    var totalResults: Int?
    var resultsRepresentative: [SegmentsRepresentation]? {
        get {
            var array: [SegmentsRepresentation]!
            if let res = results {
                array = [SegmentsRepresentation]()
                for info in res {
                    array.append(info as SegmentsRepresentation)
                }
            }
            return array
        }
    }
    
    init?(_ map: Map) {
    }
    
    mutating func mapping(map: Map) {
        page<-map["page"]
        results<-map["results"]
        totalPages<-map["total_pages"]
        totalResults<-map["total_results"]
    }
    
    //MARK: Pagintation
    var hasMorePages: Bool {
        return page < totalPages
    }
    
    var nextPage: Int? {
        return hasMorePages ? page! + 1 : nil
    }
}

struct MovieTrendsItem: Mappable, TrendsRepresentation {
    var itemId: Int?
    var movieTitle: String?
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
        movieTitle<-map["title"]
        titleOriginal<-map["original_title"]
        releaseDate<-map["release_date"]
        posterPath<-map["poster_path"]
        backdropPath<-map["backdrop_path"]
        voteAverage<-map["vote_average"]
        voteCount<-map["vote_count"]
        rating<-map["rating"]
    }
    
    var id: Int? { return itemId }
    var title: String? { return movieTitle }
    var poster: String? { return posterPath }
    var backdrop: String? { return backdropPath }
    var desc: String? { return releaseDate?.stringByReplacingOccurrencesOfString("-", withString: "/") }
    var rate: String? { return "\(voteAverage!) (\(voteCount!))" }
}

struct TvTrendsItem: Mappable, TrendsRepresentation {
    var itemId: Int?
    var name: String?
    var nameOriginal: String?
    var overview: String?
    var firstAirDate: String?
    var posterPath: String?
    var backdropPath: String?
    var voteAverage: Double?
    var voteCount: Int?
    var rating: Int?
    
    init?(_ map: Map) {
    }
    
    mutating func mapping(map: Map) {
        itemId<-map["id"]
        name<-map["name"]
        nameOriginal<-map["original_name"]
        overview<-map["overview"]
        firstAirDate<-map["first_air_date"]
        posterPath<-map["poster_path"]
        backdropPath<-map["backdrop_path"]
        voteAverage<-map["vote_average"]
        voteCount<-map["vote_count"]
        rating<-map["rating"]
    }
    
    var id: Int? { return itemId }
    var title: String? { return name }
    var poster: String? { return posterPath }
    var backdrop: String? { return backdropPath }
    var desc: String? { return overview }
    var rate: String? { return "\(voteAverage!) (\(voteCount!))" }
}

struct MovieTrendsList: Mappable {
    var page: Int?
    var results: [MovieTrendsItem]?
    var totalPages: Int?
    var totalResults: Int?
    
    init?(_ map: Map) {
    }
    
    mutating func mapping(map: Map) {
        page<-map["page"]
        results<-map["results"]
        totalPages<-map["total_pages"]
        totalResults<-map["total_results"]
    }
}

struct TvTrendsList: Mappable {
    var page: Int?
    var results: [TvTrendsItem]?
    var totalPages: Int?
    var totalResults: Int?
    
    init?(_ map: Map) {
    }
    
    mutating func mapping(map: Map) {
        page<-map["page"]
        results<-map["results"]
        totalPages<-map["total_pages"]
        totalResults<-map["total_results"]
    }
}

struct TrendsList: PaginationLoading {
    var page: Int?
    var results = [TrendsRepresentation]()
    var totalPages: Int?
    var totalResults: Int?
    
    init?(fromMovieList list: MovieTrendsList) {
        self.page = list.page
        self.totalPages = list.totalPages
        self.totalResults = list.totalResults
        if let data = list.results {
            for item in data {
                self.results.append(item)
            }
        } else {
            return nil
        }
    }
    
    init?(fromTvList list: TvTrendsList) {
        self.page = list.page
        self.totalPages = list.totalPages
        self.totalResults = list.totalResults
        if let data = list.results {
            for item in data {
                self.results.append(item)
            }
        } else {
            return nil
        }
    }
    
    var hasMorePages: Bool {
        return page < totalPages
    }
    
    var nextPage: Int? {
        return hasMorePages ? page! + 1 : nil
    }
}


