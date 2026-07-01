# workingday-calculator
Project managers have situations where they need to know how many workdays there are for a certain period of time. Instead of running an expensive and world destroying Claude LLM, they can now use a lightweight PowerShell script instead.

## Usage

```code
./days.ps1 -StartDate "2026-12-20" -EndDate "2026-12-31" -CountryCode "SE" -Json
```

#### Update
Added more info that is available and a -Json flag to add json formating. Without it, output is normal PoSh Objects.

### Output
```json
{
  "StartDate": "20/12/2026",
  "EndDate": "31/12/2026",
  "Country": "SE",
  "WorkingDays": 6,
  "HolidaysCount": 4,
  "HolidayDetails": [
    {
      "date": "2026-12-24",
      "localName": "Julafton",
      "name": "Christmas Eve",
      "fixed": false,
      "global": true,
      "types": [
        "Public"
      ]
    },
    {
      "date": "2026-12-25",
      "localName": "Juldagen",
      "name": "Christmas Day",
      "fixed": false,
      "global": true,
      "types": [
        "Public"
      ]
    },
    {
      "date": "2026-12-26",
      "localName": "Annandag jul",
      "name": "St. Stephen's Day",
      "fixed": false,
      "global": true,
      "types": [
        "Public"
      ]
    },
    {
      "date": "2026-12-31",
      "localName": "Nyårsafton",
      "name": "New Year's Eve",
      "fixed": false,
      "global": true,
      "types": [
        "Public"
      ]
    }
  ]
}
```
