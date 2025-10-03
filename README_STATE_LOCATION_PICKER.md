# State-Restricted Location Picker

This feature restricts users to only pick locations within their current state as defined in their user profile.

## Overview

The `MapPickerScreen` has been enhanced to:
- Automatically detect the user's current state from their profile
- Restrict map movement and location picking to within that state's boundaries
- Provide visual feedback showing the state boundaries
- Validate that selected locations are within the user's state

## How It Works

### 1. State Detection
- The system reads the user's `currentState` from their profile
- If no state is available, it shows an error message and falls back to a default location

### 2. Boundary Restriction
- Uses predefined state boundaries stored in `StateBoundaries` class
- Restricts map camera movement to within state boundaries
- Shows a visual polygon overlay of the state boundary

### 3. Location Validation
- Only allows location selection within the user's state
- Automatically snaps back to state boundaries if user tries to pick outside
- Shows warning messages for out-of-bounds attempts

## Files Modified

### `lib/core/utils/state_boundaries.dart`
- New utility class defining approximate boundaries for all Nigerian states
- Methods for boundary validation, state center calculation, and camera positioning
- Support for state abbreviations and partial name matching

### `lib/features/booking/view/screen/map_picker_screen.dart`
- Enhanced with state boundary validation
- Visual state boundary overlay
- Restricted map movement and location picking
- Improved user feedback and error handling

## State Boundaries

The system includes boundaries for all 36 Nigerian states plus FCT:
- Abuja FCT, Abia, Adamawa, Akwa Ibom, Anambra, Bauchi, Bayelsa
- Benue, Borno, Cross River, Delta, Ebonyi, Edo, Ekiti, Enugu
- Gombe, Imo, Jigawa, Kaduna, Kano, Katsina, Kebbi, Kogi
- Kwara, Lagos, Nasarawa, Niger, Ogun, Ondo, Osun, Oyo
- Plateau, Rivers, Sokoto, Taraba, Yobe, Zamfara

## Usage

### Basic Usage
```dart
// Navigate to the map picker
final selectedLocation = await Navigator.push<LocationModel>(
  context,
  MaterialPageRoute(
    builder: (context) => const MapPickerScreen(),
  ),
);

if (selectedLocation != null) {
  // Use the selected location (guaranteed to be within user's state)
  print('Selected: ${selectedLocation.formattedAddress}');
}
```

### State Boundary Access
```dart
// Check if a location is within a specific state
bool isInState = StateBoundaries.isLocationInState(
  LatLng(6.5244, 3.3792), // Lagos coordinates
  'Lagos'
);

// Get state center coordinates
LatLng? center = StateBoundaries.getStateCenter('Lagos');

// Get camera position for entire state
CameraPosition? cameraPos = StateBoundaries.getStateCameraPosition('Lagos');
```

## User Experience Features

### Visual Feedback
- **State Boundary Overlay**: Semi-transparent polygon showing state boundaries
- **Info Banner**: Clear message indicating state restrictions
- **Warning Messages**: SnackBar notifications for boundary violations

### Smart Positioning
- **Current Location**: If user is within their state, starts at their current location
- **State Center**: If user is outside their state, centers on state boundaries
- **Auto-snap**: Automatically returns to state boundaries if user tries to pick outside

### Error Handling
- **No State Profile**: Shows error message and falls back to default location
- **Invalid State**: Handles unsupported state names gracefully
- **Boundary Issues**: Provides clear feedback for location restrictions

## Requirements

### User Profile
Users must have a `currentState` field in their profile for this feature to work optimally.

### Dependencies
- `google_maps_flutter` for map functionality
- `flutter_riverpod` for state management
- User provider with state information

## Future Enhancements

### Potential Improvements
1. **Dynamic Boundaries**: Fetch state boundaries from external API for more accuracy
2. **Multi-State Support**: Allow users to select from multiple states if needed
3. **Boundary Refinement**: More precise boundary definitions using actual geographic data
4. **Offline Support**: Cache state boundaries for offline usage

### Customization Options
1. **Boundary Styling**: Customizable polygon colors and styles
2. **Restriction Levels**: Configurable strictness of boundary enforcement
3. **Override Options**: Admin ability to bypass state restrictions when needed

## Troubleshooting

### Common Issues

1. **"Unable to determine your state"**
   - User profile missing `currentState` field
   - Solution: Update user profile with current state

2. **Map not showing state boundaries**
   - State name not recognized by boundary system
   - Solution: Check state name format and spelling

3. **Location picking restricted unexpectedly**
   - User's current location outside their profile state
   - Solution: Update profile state or verify location accuracy

### Debug Information
Enable debug logging to see:
- State detection results
- Boundary validation outcomes
- Location restriction events

## Security Considerations

- State boundaries are approximate and should not be used for legal/regulatory purposes
- User location data is processed locally and not transmitted
- Boundary restrictions are enforced client-side for better performance
