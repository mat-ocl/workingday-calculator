# Workingday calculator in PowerShell
# https://github.com/mat-ocl

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [DateTime]$StartDate,

    [Parameter(Mandatory = $true)]
    [DateTime]$EndDate,

    [Parameter(Mandatory = $true)]
    [string]$CountryCode = "FI", # Two-letter ISO country code (e.g., FI, US, GB)

    [switch]$Json
)

# Ensure StartDate is before EndDate
if ($StartDate -gt $EndDate) {
    Write-Error "Start date must be before or equal to the end date."
    return
}

# 1. Fetch Public Holidays from Nager.Date API
$yearList = ($StartDate.Year)..($EndDate.Year)
$holidays = @()

foreach ($year in $yearList) {
    $url = "https://date.nager.at/api/v3/PublicHolidays/$year/$CountryCode"
    try {
        $response = Invoke-RestMethod -Uri $url -Method Get -ErrorAction Stop
        if ($response) {
            # Store the entire response objects
            $holidays += $response
        }
    }
    catch {
        Write-Warning "Could not fetch holidays for year $year and country $CountryCode. Proceeding with weekends only."
    }
}

# 2. Filter holidays to only those within the requested date range
$holidaysInRange = $holidays | Where-Object {
    $holidayDate = [DateTime]$_.date
    $holidayDate -ge $StartDate -and $holidayDate -le $EndDate
}

# Extract just the date strings for the fast lookup array in the while loop
$holidayDateStrings = $holidays.date

# 3. Iterate through dates and count working days
$workingDaysCount = 0
$currentDate = $StartDate

while ($currentDate -le $EndDate) {
    $dateString = $currentDate.ToString("yyyy-MM-dd")
        
    # Check if the day is a weekend (Saturday or Sunday)
    $isWeekend = ($currentDate.DayOfWeek -eq 'Saturday' -or $currentDate.DayOfWeek -eq 'Sunday')
        
    # Check if the day is a public holiday using the string array
    $isHoliday = $holidayDateStrings -contains $dateString

    # If it's neither, count it as a working day
    if (-not $isWeekend -and -not $isHoliday) {
        $workingDaysCount++
    }

    # Move to the next day
    $currentDate = $currentDate.AddDays(1)
}

# 4. Clean up the holiday data for output (optional, but keeps the object tidy)
$holidayDetails = $holidaysInRange | Select-Object date, localName, name, fixed, global, types

# 5. Build the result object
$result = [PSCustomObject]@{
    StartDate      = $StartDate.ToShortDateString()
    EndDate        = $EndDate.ToShortDateString()
    Country        = $CountryCode.ToUpper()
    WorkingDays    = $workingDaysCount
    HolidaysCount  = $holidaysInRange.Count
    HolidayDetails = $holidayDetails
}

# 6. Output the result based on the AsJson switch
if ($Json) {
    $result | ConvertTo-Json -Depth 3
} else {
    $result
}