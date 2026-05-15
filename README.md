# TravelExplorer

TravelExplorer is a modern travel platform built to help users discover destinations, compare flights, explore hotel options and create complete travel experiences in one place.

The project combines a public travel website, customer accounts, staff management tools and API-powered travel search to create a complete travel agency-style system.

## What TravelExplorer Does

TravelExplorer allows customers to search for trips by choosing an origin, destination, travel dates and number of passengers.

The platform then returns flight options, hotel suggestions and a personalized travel recommendation generated with AI.

The goal is to make trip planning feel simple, visual and complete, instead of forcing users to search flights, hotels and destination ideas separately.

## Main Features

### Travel Search

- Search by origin and destination
- Search by departure and return dates
- Passenger selector
- Airport autocomplete with IATA support
- Outbound and return flight results
- Hotel suggestions connected to the destination
- AI-generated travel package suggestion
- Selectable flights and hotels
- Clean trip-building interface

### Public Website

- Modern homepage
- Premium travel search interface
- Public offers page
- Offer details page
- Destination-inspired layout
- Responsive design for different screen sizes

### Customer Area

- Customer login and registration
- Customer dashboard
- Profile area
- Saved offers section
- Reservation overview structure
- Session stays active until logout

### Staff Area

- Staff login
- Staff dashboard
- Permission-based access control
- Admin area for creating staff accounts
- Package and offer management
- Promotions management
- Communication management
- Database-connected staff pages

### API Integration

TravelExplorer integrates external services to create real travel suggestions:

- Flight results through SerpAPI Google Flights
- Hotel results through SerpAPI Google Hotels
- AI travel suggestions through IAedu OpenAI agent

The API flow combines flight data, hotel data and destination context into a structured travel recommendation.

## User Flow

1. The user logs in as a customer.
2. The user searches for a trip.
3. TravelExplorer fetches flight options.
4. TravelExplorer fetches hotel options.
5. AI generates a personalized travel suggestion.
6. The user chooses a hotel.
7. The user chooses outbound and return flights.
8. The trip is prepared for a future reservation flow.

## Staff Flow

1. Staff logs in through the staff area.
2. Permissions define which pages the staff member can access.
3. Staff can manage packages, offers, promotions and communication.
4. Admin users can create new staff accounts and assign roles.
5. Public offers are connected to the database and can be managed internally.

## Tech Stack

- Java
- JSP
- Servlets
- MySQL
- HTML
- CSS
- JavaScript
- Tomcat
- SerpAPI
- IAedu OpenAI Agent

## Project Structure

```text
src/main/java/
├── Connection/
│   ├── Classes/
│   ├── CRUD/
│   ├── Security/
│   └── Servlets/
│
└── ExternalAPI/
    ├── ApiConfig.java
    ├── FlightsClient.java
    ├── HotelsClient.java
    └── OpenAIClient.java

src/main/webapp/
├── assets/
│   ├── css/
│   └── js/
├── components/
├── layouts/
├── pages/
└── index.jsp
