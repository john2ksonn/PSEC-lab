# TODO(felix): set the correct printer server and name

# Define the network printer path and credentials
$printerPath = "\\\\printserver\\printername"
# flag{L0g0n_AD_Pr1nt3r_M4g1c}
$username = "AAFABRIK\\felix.frucht"
$password = "k1w1fru1t"

# Convert the plain text password to a secure string
$securePassword = ConvertTo-SecureString -String $password -AsPlainText -Force

# Create a PSCredential object
$credential = New-Object System.Management.Automation.PSCredential ($username, $securePassword)

# Map a network drive to the printer server with credentials
New-PSDrive -Name "P" -PSProvider FileSystem -Root "\\printserver" -Credential $credential -Persist

# Add the network printer connection
Add-Printer -ConnectionName $printerPath

# Clean up the network drive mapping
Remove-PSDrive -Name "P"

# Confirm printer connection
Write-Host "Printer connected successfully: $printerPath"

