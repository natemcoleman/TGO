//
//  Polyline.swift
//  UserRoute
//
//  Created by Brooklyn Daines on 9/18/25.
//


import CoreLocation

public struct Polyline {

    public static func encode(coordinates: [CLLocationCoordinate2D]) -> String {
        var prevLat: Int32 = 0
        var prevLng: Int32 = 0
        var result = ""

        for coordinate in coordinates {
            let lat = Int32(round(coordinate.latitude * 1e5))
            let lng = Int32(round(coordinate.longitude * 1e5))

            let dLat = lat - prevLat
            let dLng = lng - prevLng

            result += encode(value: dLat)
            result += encode(value: dLng)

            prevLat = lat
            prevLng = lng
        }
        return result
    }

    private static func encode(value: Int32) -> String {
        var mutableValue = value
        if mutableValue < 0 {
            mutableValue = ~(mutableValue << 1)
        } else {
            mutableValue = mutableValue << 1
        }
        
        var result = ""
        while mutableValue >= 0x20 {
            let chunk = (mutableValue & 0x1f) | 0x20
            result += String(UnicodeScalar(UInt8(chunk + 63)))
            mutableValue >>= 5
        }
        result += String(UnicodeScalar(UInt8(mutableValue + 63)))
        return result
    }
    
    public static func decode(polyline: String) -> [CLLocationCoordinate2D] {
        var coordinates: [CLLocationCoordinate2D] = []
        var index = polyline.startIndex
        var lat: Int32 = 0
        var lng: Int32 = 0

        while index < polyline.endIndex {
            var b: Int32 = 0
            var shift: Int32 = 0
            var result: Int32 = 0
            
            repeat {
                let char = polyline[index]
                let ascii = Int32(char.asciiValue!) - 63
                b = ascii
                result |= (b & 0x1f) << shift
                shift += 5
                index = polyline.index(after: index)
            } while (b >= 0x20)
            
            let dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1))
            lat += dlat
            
            shift = 0
            result = 0
            
            repeat {
                let char = polyline[index]
                let ascii = Int32(char.asciiValue!) - 63
                b = ascii
                result |= (b & 0x1f) << shift
                shift += 5
                index = polyline.index(after: index)
            } while (b >= 0x20)
            
            let dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1))
            lng += dlng
            
            let coordinate = CLLocationCoordinate2D(latitude: Double(lat) / 1e5, longitude: Double(lng) / 1e5)
            coordinates.append(coordinate)
        }
        
        return coordinates
    }
}