//
//  Coordinator.swift
//  PictureWalk
//
//  Created by Derek Blair on 2017-07-01.
//  Copyright © 2017 Derek Blair. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftLocation


/// The coordinator implements the application business logic and ties 
/// together the presentation layer with the photo service.
final class Coordinator: Then {

    // MARK: Nested Types

    struct Constants {
        static let pictureDistanceInterval: CLLocationDistance = 100
    }

    // MARK: Initialization

    init(photoService: PhotoService, picturesDidChange: @escaping ([URL]) -> ()) {
        self.photoService = photoService
        self.picturesDidChange = picturesDidChange
    }

    // MARK: Flow

    func start() {
        request = Location.getLocation(withAccuracy: .house, frequency: .continuous, onSuccess: {[weak self] location in
            self?.process(location:location)
        }) { (_, error) in
            print("\(error)")
        }
    }

    func stop() {
        request?.cancel()
        request = nil
    }

    func toggle() {
        if request == nil {
            start()
        } else {
            stop()
        }
    }

    // MARK: Private

    private func process(location: CLLocation) {
        guard let lastLocation = lastPictureLocation else {
            lastPictureLocation = location
            return
        }
        let distance = location.distance(from: lastLocation)
        if distance > Constants.pictureDistanceInterval {
            lastPictureLocation = location
        }
    }

    private func takePhoto(at location:CLLocation) {
        photoService.pictureURL(at: location.coordinate) {
            $0.map { self.pictures.append($0) }
        }
    }

    private var lastPictureLocation: CLLocation? {
        didSet {
            lastPictureLocation.map { self.takePhoto(at: $0) }
        }
    }

    private var pictures: [URL] = [] {
        didSet {
            DispatchQueue.main.async {
                self.picturesDidChange(self.pictures)
            }
        }
    }

    private let picturesDidChange: ([URL]) -> ()
    private let photoService: PhotoService
    private var request: SwiftLocation.Request?
}




