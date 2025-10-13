# iOS Design System Analysis

## Overview
This document provides a comprehensive analysis of the JabruTouch iOS app's design system, including colors, fonts, and styling patterns used throughout the authentication flows and the application.

---

## Color Palette

### Primary Colors (from Colors.swift)

#### 1. App Blue
- **Variable**: `Colors.appBlue`
- **RGB**: `UIColor(red: 0.35, green: 0.34, blue: 0.87, alpha: 1)`
- **Decimal RGB**: 89, 87, 222
- **Hex**: `#5957DE`
- **Usage**: Primary brand color, button borders, text links

#### 2. App Orange/Red (Primary Action)
- **Variable**: `Colors.appOrange`
- **RGB**: `UIColor(red: 255/255, green: 95/255, blue: 80/255, alpha: 1)`
- **Decimal RGB**: 255, 95, 80
- **Hex**: `#FF5F50`
- **Usage**: Primary action buttons (Sign In, Send buttons)

#### 3. Text Medium Blue
- **Variable**: `Colors.textMediumBlue`
- **RGB**: `UIColor(red: 0.18, green: 0.17, blue: 0.66, alpha: 1)`
- **Decimal RGB**: 46, 43, 168
- **Hex**: `#2E2BA8`
- **Usage**: Text links, secondary text

#### 4. Border Gray
- **Variable**: `Colors.borderGray`
- **RGB**: `UIColor(red: 0.17, green: 0.17, blue: 0.34, alpha: 0.15)`
- **Decimal RGB**: 43, 43, 87, Alpha: 0.15
- **Hex**: `#2B2B57` with 15% opacity
- **Usage**: Input field borders, container borders

#### 5. Off White Light (Background)
- **Variable**: `Colors.offwhiteLight`
- **RGB**: `UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1)`
- **Decimal RGB**: 249, 249, 249
- **Hex**: `#F9F9F9`
- **Usage**: Background color

#### 6. App Light Gray
- **Variable**: `Colors.appLightGray`
- **RGB**: `UIColor(red: 0.73, green: 0.73, blue: 0.79, alpha: 0.5)`
- **Decimal RGB**: 186, 186, 201, Alpha: 0.5
- **Hex**: `#BABABC9` with 50% opacity
- **Usage**: Disabled states, secondary backgrounds

### Shadow Colors

#### 1. Shadow Color (Standard)
- **Variable**: `Colors.shadowColor`
- **RGB**: `UIColor(red: 0.1, green: 0.12, blue: 0.57, alpha: 0.1)`
- **Decimal RGB**: 26, 31, 145, Alpha: 0.1
- **Hex**: `#1A1F91` with 10% opacity
- **Usage**: General shadows for cards and containers

#### 2. Player Shadow Color
- **Variable**: `Colors.playerShadowColor`
- **RGB**: `UIColor(red: 0.09, green: 0.09, blue: 0.28, alpha: 0.33)`
- **Decimal RGB**: 23, 23, 71, Alpha: 0.33
- **Hex**: `#171747` with 33% opacity
- **Usage**: Media player shadows

#### 3. Bright Shadow Color
- **Variable**: `Colors.brightShadowColor`
- **RGB**: `UIColor(red: 0.1, green: 0.12, blue: 0.57, alpha: 0.05)`
- **Decimal RGB**: 26, 31, 145, Alpha: 0.05
- **Hex**: `#1A1F91` with 5% opacity
- **Usage**: Lighter shadows

### Additional Colors Used in Authentication

#### Dark Blue (Button Pressed State)
- **Color Literal**: `#colorLiteral(red: 0.18, green: 0.17, blue: 0.66, alpha: 1)`
- **Decimal RGB**: 46, 43, 168
- **Hex**: `#2E2BA8`
- **Usage**: Button pressed state in SignIn

#### Modal Background Overlay
- **RGB**: `UIColor(red: 0.15, green: 0.158, blue: 0.35, alpha: 0.32)`
- **Decimal RGB**: 38, 40, 89, Alpha: 0.32
- **Hex**: `#262859` with 32% opacity
- **Usage**: Background overlay for ForgotPassword modal

#### Container Shadow (ForgotPassword)
- **Color Literal**: `#colorLiteral(red: 0.16, green: 0.17, blue: 0.39, alpha: 0.5)`
- **Decimal RGB**: 41, 43, 99, Alpha: 0.5
- **Hex**: `#292B63` with 50% opacity
- **Usage**: Shadow for modal containers

---

## Typography System

### Font Family
The app uses **SF Pro Display** and **SF Pro Text** font families with various weights.

### Font Methods (from Fonts.swift)

#### 1. Regular Font
```swift
Fonts.regularFont(size: CGFloat)
```
- **Font**: SFProDisplay-Regular
- **Common Sizes**: 14, 18, 19, 24

#### 2. Medium Display Font
```swift
Fonts.mediumDisplayFont(size: CGFloat)
```
- **Font**: SFProDisplay-Medium
- **Common Sizes**: 18, 24

#### 3. Medium Text Font
```swift
Fonts.mediumTextFont(size: CGFloat)
```
- **Font**: SFProText-Medium
- **Common Sizes**: 18 (text fields, buttons)

#### 4. Bold Font
```swift
Fonts.boldFont(size: CGFloat)
```
- **Font**: SFProDisplay-Bold
- **Common Sizes**: 18, 21, 27, 30

#### 5. Heavy Font
```swift
Fonts.heavyFont(size: CGFloat)
```
- **Font**: SFProDisplay-Heavy
- **Common Sizes**: 15, 30

#### 6. Semi Bold Font
```swift
Fonts.semiBold(size: CGFloat)
```
- **Font**: SFProDisplay-Semibold
- **Common Sizes**: 24

#### 7. Black Font
```swift
Fonts.blackFont(size: CGFloat)
```
- **Font**: SFProDisplay-Black
- **Usage**: Extra heavy emphasis

### Alternative Font Family (UI Display)
- `regularUiDisplayFont(size:)` - SFUiDisplay-Regular
- `mediumUiDisplayFont(size:)` - SFUiDisplay-Medium
- `boldUiDisplayFont(size:)` - SFUiDisplay-Bold
- `heavyUiDisplayFont(size:)` - SFUiDisplay-Heavy
- `semiUiDisplayBold(size:)` - SFUiDisplay-Semibold
- `blackUiDisplayFont(size:)` - SFUiDisplay-Black

---

## Authentication Flow Styling Patterns

### SignIn Screen

#### Layout Structure
```
Background: #F9F9F9 (offwhiteLight)
├── Title Label
│   Font: SFProDisplay-Bold, 30pt
│   Top margin: 120pt from safe area
├── Username Container View
│   Height: 50pt
│   Horizontal margins: 48pt
│   Background: systemColor groupTableViewBackgroundColor
│   Border: 1pt solid Colors.borderGray
│   Corner radius: height/2 (25pt)
│   ├── TextField (Email or phone number)
│       Font: SFProText-Medium, 18pt
│       Padding: 20pt leading/trailing
│       Top offset: 5pt within container
├── Password Container View
│   Same styling as Username Container
│   Top margin: 28pt from username
│   ├── TextField (Password)
│       Font: SFProText-Medium, 18pt
│       Secure text entry
├── Sign In Button
│   Width/Height ratio: 93:25
│   Background: #FF5F50 (appOrange)
│   Font: SFProText-Medium, 18pt
│   Text color: #F9F9FB (near white)
│   Corner radius: height/2
│   Top margin: 36pt from password field
│   Pressed state: #2E2BA8 (darker blue)
├── Sign Up Button
│   Height: 43pt
│   Background: transparent
│   Font: SFProText-Medium, 18pt
│   Text color: #2E2BA8 (textMediumBlue)
│   Border: 2pt solid #5957DE (appBlue)
│   Corner radius: height/2
│   "Sign up" text is bold
├── Forgot Password Button
    Font: SFProText-Medium, 18pt
    Text color: #2E2BA8 (textMediumBlue)
    Top margin: 16pt from sign up button
    Bottom margin: 30pt from safe area
```

#### Key Styling Details
- **Text Fields**: Have a 5pt top offset within their container views
- **Container Views**: Use grouped table view background color with rounded corners and borders
- **Corner Radius Pattern**: Most elements use height/2 for fully rounded corners
- **Button States**: Sign In button changes from orange to blue when pressed

### ForgotPassword Screen

#### Layout Structure
```
Background: Semi-transparent overlay (#262859 @ 32%)
├── Container View (Modal)
│   Width: screen width - 34pt (17pt margins)
│   Height: 470pt
│   Top margin: 94pt (collapses to 20pt when keyboard appears)
│   Background: white
│   Corner radius: 31pt
│   Shadow: #292B63 @ 50%, radius 31pt, offset (0, 20)
│   ├── Exit Button (X)
│   │   Size: 18x18pt
│   │   Top/Right margins: 20pt/23pt
│   ├── Title Label (Forgot Password?)
│   │   Height: 60pt
│   │   Font: HelveticaNeue-Bold, 28pt
│   │   Top margin: 50pt
│   ├── Subtitle Label
│   │   Font: SFProDisplay-Medium, 24pt
│   │   Color: #2C2B56 @ 88% (rgba(0.174, 0.17, 0.338, 0.88))
│   │   Horizontal margins: 25pt
│   │   Top margin: 25pt from title
│   ├── TextField Container View
│   │   Height: 50pt
│   │   Horizontal margins: 20pt
│   │   Background: groupTableViewBackgroundColor
│   │   Border: 1pt solid Colors.borderGray
│   │   Corner radius: height/2
│   │   Top margin: 25pt from subtitle
│   │   ├── TextField (Email)
│   │       Font: System, 14pt
│   │       Type: email address
│   │       Top offset: 5pt
│   ├── Send Button
│       Height: 65pt
│       Horizontal margins: 18.5pt
│       Background: #2D2BA9 (rgb(0.178, 0.168, 0.663))
│       Font: HelveticaNeue-Bold, 18pt
│       Text: "SEND NOW" (white)
│       Corner radius: 18pt
│       Top margin: 50pt from text field
│       Bottom margin: 18pt
├── Success Container View (Initially hidden)
    Same dimensions and shadow as Container View
    ├── X Button (18x18pt)
    ├── Title Label (Email Sent)
    ├── Success Message View
    │   ├── Sent email label
    │   │   Font: SFProDisplay-Medium, 24pt
    │   ├── Email address label
    │       Font: SFProDisplay-Medium, 24pt
    │       Color: #FBB451 (rgb(0.984, 0.369, 0.318))
    ├── OK Button
        Height: 65pt
        Same styling as Send Button
```

#### Key Styling Details
- **Modal Presentation**: Uses overFullScreen presentation style
- **Shadow**: Larger shadow (radius 31, offset 20) for elevation effect
- **Corner Radius**: Larger radius (31pt) for modern, rounded appearance
- **Container Animation**: Top constraint changes from 94pt to 20pt when keyboard appears
- **Rate Limiting**: Button disabled for 60 seconds after request with countdown timer
- **Success State**: Shows different container with email confirmation

---

## Common UI Patterns

### Button Styling

#### Primary Action Button (Orange/Red)
```swift
backgroundColor: #FF5F50 (Colors.appOrange)
titleColor: #F9F9FB (near white)
font: SFProText-Medium, 18pt
cornerRadius: height/2
```

#### Secondary Action Button (Blue Border)
```swift
backgroundColor: transparent
borderColor: #5957DE (Colors.appBlue)
borderWidth: 2pt
titleColor: #2E2BA8 (Colors.textMediumBlue)
font: SFProText-Medium, 18pt
cornerRadius: height/2
```

#### Text Button (Link Style)
```swift
backgroundColor: transparent
titleColor: #2E2BA8 (Colors.textMediumBlue)
font: SFProText-Medium, 18pt
```

### Text Field Styling

#### Standard Input Field Pattern
```swift
Container View:
- backgroundColor: systemColor groupTableViewBackgroundColor
- borderColor: Colors.borderGray.cgColor
- borderWidth: 1.0
- cornerRadius: height/2
- height: 50pt

Text Field (inside container):
- backgroundColor: white
- font: SFProText-Medium, 18pt
- top offset: 5pt
- leadingPadding: 20pt
- trailingPadding: 20pt
- cornerRadius: height/2
```

**Pattern**: Text fields are nested inside container views with borders, creating a "shadow" effect

### Shadow Patterns

#### Standard Card Shadow
```swift
shadowColor: Colors.shadowColor (#1A1F91 @ 10%)
shadowRadius: 15-36pt (depending on element)
shadowOffset: CGSize(width: 0, height: 5-12)
```

#### Modal Container Shadow
```swift
shadowColor: #292B63 @ 50%
shadowRadius: 31pt
shadowOffset: CGSize(width: 0, height: 20)
```

#### Player Shadow
```swift
shadowColor: Colors.playerShadowColor (#171747 @ 33%)
shadowRadius: 36pt
shadowOffset: CGSize(width: 0, height: 12)
```

### Corner Radius Patterns

| Element Type | Corner Radius |
|--------------|---------------|
| Text Fields | height/2 (fully rounded) |
| Primary Buttons | height/2 (fully rounded) |
| Secondary Buttons | height/2 (fully rounded) |
| Modal Containers | 31pt |
| Cards/Containers | 15pt |
| Action Buttons (modal) | 18pt |
| Small Buttons | 4-10pt |
| Video Player | 15-16pt |

---

## Spacing and Layout Guidelines

### Margins
- **Horizontal Screen Margins**: 48pt (standard), 17pt (modal containers)
- **Vertical Spacing Between Elements**:
  - Title to first input: 70pt
  - Input to input: 28pt
  - Input to button: 36-50pt
  - Button to button: 16pt
- **Container Padding**: 20-25pt horizontal
- **Safe Area Bottom**: 30pt

### Element Heights
- **Text Fields**: 50pt (container)
- **Primary Buttons**: Variable, often 50-65pt
- **Text Buttons**: 34-43pt
- **Title Labels**: 36-60pt
- **Modal Containers**: 470pt (ForgotPassword)

---

## Authentication-Specific Notes

### Color Usage in Auth Flows
1. **Primary Actions**: Always use appOrange (#FF5F50)
2. **Links and Secondary Text**: Use textMediumBlue (#2E2BA8)
3. **Borders**: Use borderGray with 15% opacity
4. **Background**: Use offwhiteLight (#F9F9F9) for screens
5. **Modal Overlays**: Use dark blue with 32% opacity

### Font Usage in Auth Flows
1. **Titles**: Bold, 28-30pt
2. **Subtitles**: Medium, 24pt
3. **Input Fields**: Medium Text, 18pt
4. **Buttons**: Medium Text/Bold, 18pt
5. **Links**: Medium, 18pt

### Interaction States
1. **Default**: Orange button (#FF5F50)
2. **Pressed**: Dark blue (#2E2BA8)
3. **Disabled**: Gray with opacity
4. **Error**: Keep orange, show alert separately

---

## Implementation Notes

### Custom Classes
- **TextFieldWithPadding**: Custom UITextField with leading/trailing padding
- **ActivityView**: Loading indicator overlay

### Utility Methods
- `Utils.dropViewShadow()`: Apply shadow to views
- `Utils.showAlertMessage()`: Display error messages
- `Utils.showActivityView()`: Show loading indicator

### Keyboard Handling
- ForgotPassword adjusts container top constraint (94pt → 20pt) when keyboard appears
- SignIn dismisses keyboard on touch outside
- Text fields handle return key for keyboard dismissal/field navigation

---

## Design System Summary

### Core Principles
1. **Rounded Corners**: Fully rounded buttons and text fields (height/2)
2. **Soft Shadows**: Subtle shadows with blue tones
3. **Spacious Layout**: Generous padding and margins
4. **Clear Hierarchy**: Bold titles, medium body text
5. **Brand Colors**: Blue and orange/red as primary colors
6. **Clean Backgrounds**: Off-white with minimal texture

### Consistency Patterns
- All input fields use the same container + border pattern
- All primary buttons use appOrange with white text
- All secondary actions use appBlue for borders/text
- All modals use 31pt corner radius with large shadows
- All text fields use 18pt Medium font
- All spacing follows 4pt grid (mostly 8, 16, 20, 25, 28, 36, 48, 50)

---

## For ResetPassword Implementation

Based on this analysis, the ResetPassword storyboard should follow:

### Color Scheme
- Background: #F9F9F9 or modal overlay
- Primary button: #FF5F50 (orange/red)
- Text/links: #2E2BA8 (medium blue)
- Borders: borderGray (#2B2B57 @ 15%)
- Container: white with shadow

### Typography
- Title: Bold, 28-30pt
- Subtitle/Instructions: Medium, 24pt
- Input fields: Medium Text, 18pt
- Buttons: Medium or Bold, 18pt

### Layout
- Modal container: 31pt corner radius, shadow (31pt radius, 20pt offset)
- Text fields: 50pt height, fully rounded, nested in bordered container
- Buttons: 65pt height, 18pt corner radius
- Spacing: Follow established patterns (20-50pt between elements)

### Interaction
- Match ForgotPassword modal presentation style
- Use same shadow and corner radius patterns
- Implement keyboard handling (adjust constraints)
- Show success state in separate container
