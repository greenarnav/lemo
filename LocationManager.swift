import Foundation
import CoreLocation
import SwiftUI

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()

    @Published var userLocation: CLLocation?
    @Published var equatableLocation: EquatableCoordinate?
    @Published var cityName: String = ""
    @Published var stateName: String = ""
    @Published var areaCode: String = ""
    @Published var isLocationFetched: Bool = false
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 100 // Update when user moves 100 meters
    }
    
    func requestLocationPermission() {
        manager.requestWhenInUseAuthorization()
    }
    
    func startLocationUpdates() {
        manager.startUpdatingLocation()
    }
    
    func stopLocationUpdates() {
        manager.stopUpdatingLocation()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        if manager.authorizationStatus == .authorizedWhenInUse ||
           manager.authorizationStatus == .authorizedAlways {
            startLocationUpdates()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        // Filter out poor accuracy readings
        if location.horizontalAccuracy < 100 {
            DispatchQueue.main.async {
                self.userLocation = location
                let coord = location.coordinate
                self.equatableLocation = EquatableCoordinate(coordinate: coord)
                self.isLocationFetched = true
                
                // Reverse geocode to get city and state
                self.fetchCityAndState(for: coord)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location update failed: \(error.localizedDescription)")
    }

    func fetchCityAndState(for coordinate: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                return
            }
            
            if let placemark = placemarks?.first {
                DispatchQueue.main.async {
                    self.cityName = placemark.locality ?? "Unknown"
                    self.stateName = placemark.administrativeArea ?? ""
                    
                    // Try to get area code from postal code
                    if let postalCode = placemark.postalCode, postalCode.count >= 3 {
                        // For US postal codes, try to extract area code equivalent
                        self.areaCode = String(postalCode.prefix(3))
                    }
                }
            }
        }
    }
    
    // Find the most relevant area code for the current location
    func getRelevantAreaCode() -> String {
        // Default to "602" for Phoenix/Tempe if we don't have a more specific one
        return areaCode.isEmpty ? "602" : areaCode
    }
}

// MARK: - Equatable Coordinate Wrapper
struct EquatableCoordinate: Equatable {
    let coordinate: CLLocationCoordinate2D

    static func == (lhs: EquatableCoordinate, rhs: EquatableCoordinate) -> Bool {
        return lhs.coordinate.latitude == rhs.coordinate.latitude &&
               lhs.coordinate.longitude == rhs.coordinate.longitude
    }
}
