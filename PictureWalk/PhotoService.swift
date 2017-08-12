//
//  PhotoService.swift
//  PictureWalk
//
//  Created by Derek Blair on 2017-07-03.
//  Copyright © 2017 Derek Blair. All rights reserved.
//

import Foundation
import CoreLocation


// MARK: PhotoService

protocol PhotoService {
    func pictureURL(at location: CLLocationCoordinate2D, finished:@escaping (URL?) -> ())
}

// MARK: Implementations

struct FlickrService: PhotoService {

    struct Config {
        typealias Km = Double
        typealias Seconds = Double
        var pictureRadius: Km = 5
        var pictureRequestTimeout: Seconds = 10.0
        var apiKey = "eb159d8d58a1817495ba016a3eacf781"
        var urlKey = "url_m"
    }

    init(config: Config = Config()) {
        self.config = config
    }

    let config: Config

    func pictureURL(at location: CLLocationCoordinate2D, finished:@escaping (URL?) -> ()) {

        let lat = location.latitude
        let long = location.longitude
        let urlString = [
            "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(config.apiKey)",
            "&lat=\(lat)",
            "&long=\(long)",
            "&media=photos",
            "&min_taken_date=1278162327",
            "&radius=\(config.pictureRadius)&format=json&has_geo=1&geo_context=2",
            "&nojsoncallback=1&per_page=1&extras=\(config.urlKey),geo"].joined()

        guard let url = URL(string:urlString) else {
            finished(nil)
            return
        }

        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: config.pictureRequestTimeout)
        let task = URLSession.shared.dataTask(with: request) {(data,response,error) in
            guard let data = data, error == nil else { finished(nil); return }
            if  let json = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [String:Any],
                let photo = (json["photos"] as? [String:Any])?["photo"],
                let info = (photo as? Array<[String:Any]>)?.first,
                let imgURL = info[self.config.urlKey] as? String {
                finished(URL(string: imgURL))
            } else {
                finished(nil)
            }
            
        }
        task.resume()
    }
}


