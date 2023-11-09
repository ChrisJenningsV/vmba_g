

// GetFlightPrices

// POST /LoganAirInHouse/VARS/webapiv2/api/flightcalendar/GetFlightPrices HTTP/1.1
// Accept: */*
// Accept-Encoding: gzip, deflate, br
// Accept-Language: en-GB,en;q=0.9,en-US;q=0.8
// Connection: keep-alive
// Content-Length: 183
// Content-Type: application/json
// Cookie: emcid=F-3XjyzRMSB; _ga=GA1.2.391149550.1637654953; _tq_id.TV-18453618-1.3d0a=23ddf2edf1848ed3.1639401743.0.1639401798..; _ga_2WKCHLQ6F9=GS1.1.1639401742.1.1.1639403000.0; Passenger1Details=FirstName=Chris&Surname=Jennings&Title=Mr&DateOfBirth=20-Dec-2000&ContactEmailAddress=chrisj@videcom.com&EmailMessageFormat=&CountryOfResidence=Philippines&Gender=&Weight=&PassportNumber=&PassportCountryOfIssue=&PassportExpiryDate=&PassportIssueDate=&ContactBusinessPhoneNumber=&ContactBusinessPhoneNumberInternationalDialCode=&ContactBusinessPhoneNumberAreaCode=&ContactGeneralPhoneNumber=&ContactGeneralPhoneNumberInternationalDialCode=&ContactGeneralPhoneNumberAreaCode=&ContactHomePhoneNumber=&ContactHomePhoneNumberInternationalDialCode=&ContactHomePhoneNumberAreaCode=&ContactMobilePhoneNumber=5434&ContactMobilePhoneNumberInternationalDialCode=63&ContactMobilePhoneNumberAreaCode=&ReceiveNewsletter=False&PaxExtraField=&SeniorDisabilityResidentDiscountCode=&SeniorDisabilityResidentHasPWD=&MiddleName=&RedressNo=&KnownTravellerNo=; permutive-session=%7B%22session_id%22%3A%22afbcc7f8-28ea-4a17-ac44-ed6a6ee5d353%22%2C%22last_updated%22%3A%222022-04-07T11%3A02%3A03.117Z%22%7D; ASP.NET_SessionId=ujyxfbzjachqj0kz0kz0dhxn; __RequestVerificationToken_L0xvZ2FuQWlyL1ZBUlMvUHVibGlj0=rbmZvI8maeWcIVsdoATXhj9fPivh23_K2g43W54RvIIPkkAZQcjzv_lt3MIy_3Qei8nb9FWpLrvaawGT8-bhZ9_KauqVG2xw7CWZ2o1nV-Q1; __RequestVerificationToken_L0xvZ2FuQWlySW5Ib3VzZS9WQVJTL1B1YmxpYw2=LzLUI8nr7UeZT69pgyNnMFzYWJH0VOi_z9sCnfAyhiWXoEeG2BVpRHyITuzDjL_107KfsUX7oBAt7stHzg-JIF1LkIo1; __RequestVerificationToken_L0FpclN3aWZ0L1ZBUlMvUHVibGlj0=iqs7OCjSPM74cb9pPygPHruSsR83piRz2dGQUTWXdlBUHfWOvxe5HsVAMjeofjFAPd9Qxi_nkRNvUd8zkK4qWm34uWzLj7LEn2h-k_BKhzg1; __RequestVerificationToken_L0F1cmlnbnlBaXJTZXJ2aWNlcy9WQVJTL1B1YmxpYw2=1Ky6WrNf-KTOamC-vsm6mz5pRqq-eVjgbtE7KoDHX5VrlW1XeOg2yNLbGXvdE3u-sfOr9IzSqcUqpZnXjt6mRneu15XPJ6uJPloeuLvVYXM1
// Host: customertest.videcom.com
// Origin: https://customertest.videcom.com
// Referer: https://customertest.videcom.com/LoganAirinhouse/VARS/public/CustomerPanels/RequirementsBS.aspx?lang=
// Sec-Fetch-Dest: empty
// Sec-Fetch-Mode: cors
// Sec-Fetch-Site: same-origin
// User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36 Edg/117.0.2045.47
// X-Requested-With: XMLHttpRequest
// sec-ch-ua: "Microsoft Edge";v="117", "Not;A=Brand";v="8", "Chromium";v="117"
// sec-ch-ua-mobile: ?0
// sec-ch-ua-platform: "Windows"
// {
//     "departCity": "ABZ",
//     "arrivalCity": "KOI",
//     "flightDateStart": "2023-11-01",
//     "flightDateEnd": "2023-12-01",
//     "isReturnJourney": 0,
//     "selectedCurrency": "GBP",
//     "isADS": false,
//     "ShowFlightPrices": null
// }

//
// response
// [
//     {
//         "flightDate": "2023-11-26",
//         "price": 0.0,
//         "currency": "fhp",
//         "selectable": true,
//         "cssClass": "flight-hide-price"
//     },
//     {
//         "flightDate": "2023-11-27",
//         "price": 0.0,
//         "currency": "fhp",
//         "selectable": true,
//         "cssClass": "flight-hide-price"
//     },
//     {
//         "flightDate": "2023-11-28",
//         "price": 0.0,
//         "currency": "fhp",
//         "selectable": true,
//         "cssClass": "flight-hide-price"
//     },
//     {
//         "flightDate": "2023-11-29",
//         "price": 0.0,
//         "currency": "fhp",
//         "selectable": true,
//         "cssClass": "flight-hide-price"
//     },
//     {
//         "flightDate": "2023-11-30",
//         "price": 0.0,
//         "currency": "fhp",
//         "selectable": true,
//         "cssClass": "flight-hide-price"
//     },
//     {
//         "flightDate": "2023-12-01",
//         "price": 0.0,
//         "currency": "fhp",
//         "selectable": true,
//         "cssClass": "flight-hide-price"
//     },
//     {
//         "flightDate": "2023-12-02",
//         "price": 0.0,
//         "currency": "fhp",
//         "selectable": true,
//         "cssClass": "flight-hide-price"
//     },
//     {
//         "flightDate": "2023-12-03",
//         "price": 0.0,
//         "currency": "fhp",
//         "selectable": true,
//         "cssClass": "flight-hide-price"
//     },
//     {
//         "flightDate": "2023-12-04",
//         "price": 0.0,
//         "currency": "fhp",
//         "selectable": true,
//         "cssClass": "flight-hide-price"
//     },
//     {
//         "flightDate": "2023-12-05",
//         "price": 0.0,
//         "currency": "fhp",
//         "selectable": true,
//         "cssClass": "flight-hide-price"
//     },
//     {
//         "flightDate": "2023-12-06",
//         "price": 0.0,
//         "currency": "fhp",
//         "selectable": true,
//         "cssClass": "flight-hide-price"
//     },
//     {
//         "flightDate": "2023-12-07",
//         "price": 0.0,
//         "currency": "fhp",
//         "selectable": true,
//         "cssClass": "flight-hide-price"
//     },
//     {
//         "flightDate": "2023-12-08",
//         "price": 0.0,
//         "currency": "fhp",
//         "selectable": true,
//         "cssClass": "flight-hide-price"
//     },
//     {
//         "flightDate": "2023-12-09",
//         "price": 0.0,
//         "currency": "fhp",
//         "selectable": true,
//         "cssClass": "flight-hide-price"
//     },
//     {
//         "flightDate": "2023-12-10",
//         "price": 0.0,
//         "currency": "fhp",
//         "selectable": true,
//         "cssClass": "flight-hide-price"
//     },
//     {
//         "flightDate": "2023-12-11",
//         "price": 0.0,
//         "currency": "fhp",
//         "selectable": true,
//         "cssClass": "flight-hide-price"
//     },
//     {
//         "flightDate": "2023-12-12",
//         "price": 0.0,
//         "currency": "fhp",
//         "selectable": true,
//         "cssClass": "flight-hide-price"
//     },
//     {
//         "flightDate": "2023-12-13",
//         "price": 0.0,
//         "currency": "fhp",
//         "selectable": true,
//         "cssClass": "flight-hide-price"
//     },
//     {
//         "flightDate": "2023-12-14",
//         "price": 0.0,
//         "currency": "fhp",
//         "selectable": true,
//         "cssClass": "flight-hide-price"
//     },
//     {
//         "flightDate": "2023-12-15",
//         "price": 0.0,
//         "currency": "fhp",
//         "selectable": true,
//         "cssClass": "flight-hide-price"
//     },
//     {
//         "flightDate": "2023-12-16",
//         "price": 0.0,
//         "currency": "fhp",
//         "selectable": true,
//         "cssClass": "flight-hide-price"
//     },
//     {
//         "flightDate": "2023-12-17",
//         "price": 0.0,
//         "currency": "fhp",
//         "selectable": true,
//         "cssClass": "flight-hide-price"
//     },
//     {
//         "flightDate": "2023-12-18",
//         "price": 0.0,
//         "currency": "fhp",
//         "selectable": true,
//         "cssClass": "flight-hide-price"
//     },
//     {
//         "flightDate": "2023-12-19",
//         "price": 0.0,
//         "currency": "fhp",
//         "selectable": true,
//         "cssClass": "flight-hide-price"
//     },
//     {
//         "flightDate": "2023-12-20",
//         "price": 0.0,
//         "currency": "fhp",
//         "selectable": true,
//         "cssClass": "flight-hide-price"
//     },
//     {
//         "flightDate": "2023-12-21",
//         "price": 0.0,
//         "currency": "fhp",
//         "selectable": true,
//         "cssClass": "flight-hide-price"
//     },
//     {
//         "flightDate": "2023-12-22",
//         "price": 0.0,
//         "currency": "fhp",
//         "selectable": true,
//         "cssClass": "flight-hide-price"
//     },
//     {
//         "flightDate": "2023-12-23",
//         "price": 0.0,
//         "currency": "fhp",
//         "selectable": true,
//         "cssClass": "flight-hide-price"
//     },
//     {
//         "flightDate": "2023-12-24",
//         "price": 0.0,
//         "currency": "fhp",
//         "selectable": true,
//         "cssClass": "flight-hide-price"
//     },
//     {
//         "flightDate": "2023-12-25",
//         "price": 0.0,
//         "currency": "fna",
//         "selectable": false,
//         "cssClass": "flight-not-available"
//     },
//     {
//         "flightDate": "2023-12-26",
//         "price": 0.0,
//         "currency": "fhp",
//         "selectable": true,
//         "cssClass": "flight-hide-price"
//     },
//     {
//         "flightDate": "2023-12-27",
//         "price": 0.0,
//         "currency": "fhp",
//         "selectable": true,
//         "cssClass": "flight-hide-price"
//     },
//     {
//         "flightDate": "2023-12-28",
//         "price": 0.0,
//         "currency": "fhp",
//         "selectable": true,
//         "cssClass": "flight-hide-price"
//     },
//     {
//         "flightDate": "2023-12-29",
//         "price": 0.0,
//         "currency": "fhp",
//         "selectable": true,
//         "cssClass": "flight-hide-price"
//     },
//     {
//         "flightDate": "2023-12-30",
//         "price": 0.0,
//         "currency": "fhp",
//         "selectable": true,
//         "cssClass": "flight-hide-price"
//     },
//     {
//         "flightDate": "2023-12-31",
//         "price": 0.0,
//         "currency": "fhp",
//         "selectable": true,
//         "cssClass": "flight-hide-price"
//     },
//     {
//         "flightDate": "2024-01-01",
//         "price": 0.0,
//         "currency": "fna",
//         "selectable": false,
//         "cssClass": "flight-not-available"
//     }
// ]
