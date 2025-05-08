import CoreLocation

struct AreaCodeLookup {
    // Static method for looking up city by area code
    static func city(for areaCode: String) -> (city: String, state: String)? {
        // Look up area code in the location database
        let lookup = LocationLookup.shared
        if let (cityName, _) = lookup.city(for: areaCode) {
            return (city: cityName, state: "")
        }
        
        // Fallback for known area codes (hardcoded for now)
        switch areaCode {
        case "602":
            return (city: "Phoenix", state: "Arizona")
        case "480":
            return (city: "Tempe", state: "Arizona")
        case "212":
            return (city: "Manhattan", state: "New York")
        case "415":
            return (city: "San Francisco", state: "California")
        default:
            return nil
        }
    }
}
