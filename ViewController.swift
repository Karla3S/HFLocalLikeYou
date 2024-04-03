
//Extensions
import UIKit
import MapboxMaps
import CoreLocation
import MapboxCoreMaps
import Foundation
import MapKit

class ViewController: UIViewController {
   
//Variables
    var mapView: MapView!
    let locationProvider = AppleLocationProvider()
    var slideUpMenuView: UIView! // Slide-up menu view
    var allowedLocations: [CLLocationCoordinate2D] = []
    let MAX_DISTANCE_THRESHOLD: CLLocationDistance = 50 // Adjust as needed

    var tappedCoordinate: CLLocationCoordinate2D?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        mapView = MapView(frame: view.bounds)
// Set the Mapbox style URI
        mapView.mapboxMap.styleURI = StyleURI(rawValue: "mapbox://styles/locallikeyou/clo61gomh003y01r70gk2784w")
        
// Override the default location provider with the custom one.
        mapView.location.override(provider: locationProvider)
        locationProvider.delegate = self
        
// Set up location options
        let puckConfiguration = Puck2DConfiguration()
        mapView.location.options.puckType = .puck2D(puckConfiguration) // Use the default puck
        
// Enable heading (bearing) display explicitly
        let configuration = Puck2DConfiguration.makeDefault(showBearing: true)
        mapView.location.options.puckType = .puck2D(configuration)
        
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        view.addSubview(mapView)
        
        
// Set up slide-up menu view
        slideUpMenuView = UIView(frame: CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: 300))
        slideUpMenuView.backgroundColor = UIColor.white
        view.addSubview(slideUpMenuView)
        
// Add exit button to the slide-up menu view
        let exitButton = UIButton(type: .system)
        exitButton.setTitle("X", for: .normal)
        exitButton.frame = CGRect(x: slideUpMenuView.frame.width - 40, y: 20, width: 30, height: 30) // Adjust position and size as needed
        exitButton.addTarget(self, action: #selector(exitButtonTapped), for: .touchUpInside)
        slideUpMenuView.addSubview(exitButton)
        
        
// Add tap gesture recognizer to the map view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        mapView.addGestureRecognizer(tapGesture)
        
        
        // Load JSON data and extract allowed locations
        if let locations = loadJSONData() {
            allowedLocations = locations.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
            print("Allowed locations: \(allowedLocations)")
        } else {
            print("Failed to load JSON data")
        }
    }
    
// Function to load JSON data from file
       func loadJSONData() -> [LocationData]? {
           if let path = Bundle.main.path(forResource: "data", ofType: "json") {
               do {
                   let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                   let decoder = JSONDecoder()
                   let locations = try decoder.decode([LocationData].self, from: data)
                   return locations
               } catch {
                   print("Error decoding JSON: \(error)")
               }
           }
           return nil
       }
//Handle Tap Menu
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            let tapPoint = gesture.location(in: mapView)
            let tapCoordinate = mapView.mapboxMap.coordinate(for: tapPoint)
            print("Tapped at: \(tapCoordinate.latitude), \(tapCoordinate.longitude)")

            // Check if the tapped coordinates are within the allowed range
            if isCoordinateAllowed(tapCoordinate) {
                showSlideUpMenu()
                tappedCoordinate = tapCoordinate // Store the tapped coordinate
            } else {
                print("Tapping at this location is not allowed.")
            }
        }
    }

// Function to check if the tapped coordinates are within the allowed range
    func isCoordinateAllowed(_ coordinate: CLLocationCoordinate2D) -> Bool {
        for allowedCoordinate in allowedLocations {
            // Print the coordinates being compared
            print("Allowed Coordinate: \(allowedCoordinate.latitude), \(allowedCoordinate.longitude)")
            print("Tapped Coordinate: \(coordinate.latitude), \(coordinate.longitude)")

            // Calculate distance between the tapped coordinate and the allowed coordinate
            let distance = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                .distance(from: CLLocation(latitude: allowedCoordinate.latitude, longitude: allowedCoordinate.longitude))

            // Print the distance
            print("Distance: \(distance)")

            // Check if the distance is within the threshold
            if distance <= MAX_DISTANCE_THRESHOLD {
                print("Tapping is allowed at this location.")
                return true
            }
        }

        // If the loop completes without returning true, tapping is not allowed
        print("Tapping is not allowed at this location.")
        return false
    }

//Function to show slide up menu
//    func showSlideUpMenu() {
//        print("Showing slide-up menu")
//        UIView.animate(withDuration: 0.3) {
//            // Update frame size and position
//            let menuHeight: CGFloat = 550 // Adjust height as needed
//            let cornerRadius: CGFloat = 15 // Adjust corner radius as needed
//
//            self.slideUpMenuView.frame = CGRect(x: 0, y: self.view.frame.height - menuHeight, width: self.view.frame.width, height: menuHeight)
//            self.slideUpMenuView.backgroundColor = UIColor.white // Add a background color for visibility
//
//            // Update corner radius
//            self.slideUpMenuView.layer.cornerRadius = cornerRadius
//
//            // Apply shadow for better appearance
//            self.slideUpMenuView.layer.shadowColor = UIColor.black.cgColor
//            self.slideUpMenuView.layer.shadowOpacity = 0.5
//            self.slideUpMenuView.layer.shadowOffset = CGSize(width: 0, height: -3)
//            self.slideUpMenuView.layer.shadowRadius = 3
//
//            // Add rounded corners to the top corners only
//            self.slideUpMenuView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
//            
//            // Add text labels
//            let titleLabel = UILabel(frame: CGRect(x: 20, y: 20, width: self.slideUpMenuView.frame.width - 40, height: 30))
//            titleLabel.text = "Slide-Up Menu Title"
//            titleLabel.textAlignment = .center
//            titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
//            titleLabel.textColor = UIColor.black
//            titleLabel.backgroundColor = UIColor.white // Add a background color for visibility
//            self.slideUpMenuView.addSubview(titleLabel)
//            
//            let descriptionLabel = UILabel(frame: CGRect(x: 20, y: titleLabel.frame.maxY + 10, width: self.slideUpMenuView.frame.width - 40, height: 100))
//            descriptionLabel.text = "This is a description for the slide-up menu."
//            descriptionLabel.textAlignment = .justified
//            descriptionLabel.numberOfLines = 0 // Allow multiple lines
//            descriptionLabel.textColor = UIColor.black
//            descriptionLabel.backgroundColor = UIColor.white // Add a background color for visibility
//            self.slideUpMenuView.addSubview(descriptionLabel)
//            
//            // Ensure that the text labels are brought to the front
//            self.slideUpMenuView.bringSubviewToFront(titleLabel)
//            self.slideUpMenuView.bringSubviewToFront(descriptionLabel)
//
//            
//            // Add navigation button to the slide-up menu view
//            let navigationButton = UIButton(type: .system)
//            navigationButton.setTitle("Navigate", for: .normal)
//            navigationButton.frame = CGRect(x: 20, y: descriptionLabel.frame.maxY + 20, width: self.slideUpMenuView.frame.width - 40, height: 40)
//            navigationButton.backgroundColor = UIColor.blue // Set the background color to blue
//            navigationButton.setTitleColor(UIColor.white, for: .normal) // Set text color to white
//            navigationButton.layer.cornerRadius = 10 // Set corner radius for rounded corners
//            navigationButton.addTarget(self, action: #selector(self.navigationButtonTapped), for: .touchUpInside)
//            self.slideUpMenuView.addSubview(navigationButton)
//            
//            // Add exit button and ensure it's brought to the front
//             let exitButton = UIButton(type: .system)
//             exitButton.setTitle("X", for: .normal)
//             exitButton.frame = CGRect(x: self.slideUpMenuView.frame.width - 40, y: 20, width: 30, height: 30) // Adjust position and size as needed
//             exitButton.addTarget(self, action: #selector(self.exitButtonTapped), for: .touchUpInside)
//             self.slideUpMenuView.addSubview(exitButton)
//             self.slideUpMenuView.bringSubviewToFront(exitButton) // Ensure exit button is brought to the front
//            
//        }
//    }


    func showSlideUpMenu() {
        print("Showing slide-up menu")
        UIView.animate(withDuration: 0.6) {
            // Update frame size and position
            let menuHeight: CGFloat = 550 // Adjust height as needed
            let cornerRadius: CGFloat = 15 // Adjust corner radius as needed

            self.slideUpMenuView.frame = CGRect(x: 0, y: self.view.frame.height - menuHeight, width: self.view.frame.width, height: menuHeight)
            self.slideUpMenuView.backgroundColor = UIColor.white // Add a background color for visibility

            // Update corner radius
            self.slideUpMenuView.layer.cornerRadius = cornerRadius

            // Apply shadow for better appearance
            self.slideUpMenuView.layer.shadowColor = UIColor.black.cgColor
            self.slideUpMenuView.layer.shadowOpacity = 0.5
            self.slideUpMenuView.layer.shadowOffset = CGSize(width: 0, height: -3)
            self.slideUpMenuView.layer.shadowRadius = 3

            // Add rounded corners to the top corners only
            self.slideUpMenuView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            
            // Load data from JSON file
            if let url = Bundle.main.url(forResource: "data", withExtension: "json") {
                do {
                    let data = try Data(contentsOf: url)
                    let decoder = JSONDecoder()
                    let jsonData = try decoder.decode([LocationData].self, from: data) // Use LocationData array

                    if let firstItem = jsonData.first {
                        // Business name label
                        let businessNameLabel = UILabel(frame: CGRect(x: 20, y: 20, width: self.slideUpMenuView.frame.width - 40, height: 30))
                        businessNameLabel.text = " \(firstItem.businessName)"
                        businessNameLabel.textAlignment = .center
                        businessNameLabel.font = UIFont.boldSystemFont(ofSize: 20)
                        businessNameLabel.textColor = UIColor.black
                        businessNameLabel.backgroundColor = UIColor.white // Add a background color for visibility
                        self.slideUpMenuView.addSubview(businessNameLabel)
                        
                        // Customer type label
                        let customerTypeLabel = UILabel(frame: CGRect(x: 20, y: 70, width: self.slideUpMenuView.frame.width - 40, height: 30))
                        customerTypeLabel.text = " \(firstItem.customerType)"
                        customerTypeLabel.textAlignment = .left
                        customerTypeLabel.font = UIFont.systemFont(ofSize: 16)
                        customerTypeLabel.textColor = UIColor.black
                        customerTypeLabel.backgroundColor = UIColor.white // Add a background color for visibility
                        self.slideUpMenuView.addSubview(customerTypeLabel)
                        
                        // Address label
                        let addressLabel = UILabel(frame: CGRect(x: 20, y: 120, width: self.slideUpMenuView.frame.width - 40, height: 100))
                        addressLabel.text = "\(firstItem.address)"
                        addressLabel.textAlignment = .left
                        addressLabel.numberOfLines = 0 // Allow multiple lines
                        addressLabel.font = UIFont.systemFont(ofSize: 16)
                        addressLabel.textColor = UIColor.black
                        addressLabel.backgroundColor = UIColor.white // Add a background color for visibility
                        self.slideUpMenuView.addSubview(addressLabel)
                    }
                } catch {
                    print("Error loading JSON data: \(error)")
                }
            }
            
            // Add navigation button to the slide-up menu view
            let navigationButton = UIButton(type: .system)
            navigationButton.setTitle("Navigate", for: .normal)
            navigationButton.frame = CGRect(x: 20, y: 250, width: self.slideUpMenuView.frame.width - 40, height: 40)
            navigationButton.backgroundColor = UIColor.blue // Set the background color to blue
            navigationButton.setTitleColor(UIColor.white, for: .normal) // Set text color to white
            navigationButton.layer.cornerRadius = 10 // Set corner radius for rounded corners
            navigationButton.addTarget(self, action: #selector(self.navigationButtonTapped), for: .touchUpInside)
            self.slideUpMenuView.addSubview(navigationButton)
            
            // Add exit button and ensure it's brought to the front
            let exitButton = UIButton(type: .system)
            exitButton.setTitle("X", for: .normal)
            exitButton.frame = CGRect(x: self.slideUpMenuView.frame.width - 40, y: 20, width: 30, height: 30) // Adjust position and size as needed
            exitButton.addTarget(self, action: #selector(self.exitButtonTapped), for: .touchUpInside)
            self.slideUpMenuView.addSubview(exitButton)
            self.slideUpMenuView.bringSubviewToFront(exitButton) // Ensure exit button is brought to the front
        }
    }


   //Naviavgtion Button Tapped
    @objc func navigationButtonTapped() {
        // Open Apple Maps with navigation to the tapped location
        if let tappedCoordinate = tappedCoordinate {
            let destination = MKMapItem(placemark: MKPlacemark(coordinate: tappedCoordinate))
            destination.name = "Destination"
            let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
            MKMapItem.openMaps(with: [destination], launchOptions: options)
        }
    }
    
    
//Exit button handle
    @objc func exitButtonTapped() {
        hideSlideUpMenu()
    }
    
    func hideSlideUpMenu() {
        UIView.animate(withDuration: 0.3) {
            self.slideUpMenuView.frame.origin.y = self.view.frame.height
        }
    }
    
// Method that will be called as a result of the delegate below
    func requestPermissionsButtonTapped() {
        locationProvider.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "CustomKey")
    }
}

extension ViewController: AppleLocationProviderDelegate {
    func appleLocationProvider(_ locationProvider: AppleLocationProvider, didFailWithError error: Error) {
        
        
    }
    
    func centerMapOnLocation(_ location: CLLocationCoordinate2D) {
        let cameraOptions = CameraOptions(center: location,
                                          zoom: 2, // Adjust the zoom level as needed
                                          bearing: 0,
                                          pitch: 0)
        mapView.mapboxMap.setCamera(to: cameraOptions)
    }
    
    func appleLocationProviderShouldDisplayHeadingCalibration(_ locationProvider: AppleLocationProvider) -> Bool {
        // Return true if you want to display the heading calibration interface, false otherwise
        return true
    }
    
    func appleLocationProvider(
        _ locationProvider: AppleLocationProvider,
        didChangeAccuracyAuthorization accuracyAuthorization: CLAccuracyAuthorization
    ) {
        if accuracyAuthorization == .reducedAccuracy {
            // Perform an action in response to the new change in accuracy
        }
    }
    
    
    // Function to fetch location data for a given coordinate
    func getLocationData(for coordinate: CLLocationCoordinate2D) -> LocationData? {
        return loadJSONData()?.first { location in
            return location.latitude == coordinate.latitude && location.longitude == coordinate.longitude
        }
    }
    
    
    func appleLocationProvider(_ locationProvider: AppleLocationProvider, didUpdateLocations locations: [CLLocation]) {
        if let userLocation = locations.last {
            let cameraOptions = CameraOptions(center: userLocation.coordinate,
                                              zoom: 4, // You might want to adjust the zoom level as needed
                                              bearing: 0,
                                              pitch: 0)
            mapView.mapboxMap.setCamera(to: cameraOptions)
        }
    }
}


// Define a struct to represent your JSON data
struct LocationData: Codable {
    let id: Int
    let businessName: String
    let customerType: String
    let address: String
    let latitude: Double
    let longitude: Double

    private enum CodingKeys: String, CodingKey {
        case id = "Id"
        case businessName = "BusinessName"
        case customerType = "CustomerType"
        case address = "Address"
        case latitude = "Latitude"
        case longitude = "Longitude"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        // Attempt to decode businessName as String, but handle both String and Number values
        if let businessNameString = try? container.decode(String.self, forKey: .businessName) {
            businessName = businessNameString
        } else if let businessNameNumber = try? container.decode(Int.self, forKey: .businessName) {
            businessName = String(businessNameNumber)
        } else {
            throw DecodingError.typeMismatch(String.self, DecodingError.Context(codingPath: [CodingKeys.businessName], debugDescription: "Expected String or Number value for businessName"))
        }
        customerType = try container.decode(String.self, forKey: .customerType)
        address = try container.decode(String.self, forKey: .address)
        latitude = try container.decode(Double.self, forKey: .latitude)
        longitude = try container.decode(Double.self, forKey: .longitude)
    }
}

// Add an extension to CLLocation to calculate distance between two coordinates
extension CLLocation {
    convenience init(coordinate: CLLocationCoordinate2D) {
        self.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}






