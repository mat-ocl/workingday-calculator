param (
    [Parameter(Mandatory = $true)]
    [DateTime]$StartDate,

    [Parameter(Mandatory = $true)]
    [DateTime]$EndDate,

    [Parameter(Mandatory = $true)]
    [string]$CountryCode # Two-letter ISO country code (e.g., US, CA, GB, DE)
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
            # Extract just the date string (YYYY-MM-DD)
            $holidays += $response.date
        }
    }
    catch {
        Write-Warning "Could not fetch holidays for year $year and country $CountryCode. Proceeding with weekends only."
    }
}

# 2. Iterate through dates and count working days
$workingDaysCount = 0
$currentDate = $StartDate

while ($currentDate -le $EndDate) {
    $dateString = $currentDate.ToString("yyyy-MM-dd")
        
    # Check if the day is a weekend (Saturday or Sunday)
    $isWeekend = ($currentDate.DayOfWeek -eq 'Saturday' -or $currentDate.DayOfWeek -eq 'Sunday')
        
    # Check if the day is a public holiday
    $isHoliday = $holidays -contains $dateString

    # If it's neither, count it as a working day
    if (-not $isWeekend -and -not $isHoliday) {
        $workingDaysCount++
    }

    # Move to the next day
    $currentDate = $currentDate.AddDays(1)
}

# 3. Output the result
[PSCustomObject]@{
    StartDate   = $StartDate.ToShortDateString()
    EndDate     = $EndDate.ToShortDateString()
    Country     = $CountryCode.ToUpper()
    WorkingDays = $workingDaysCount
}
