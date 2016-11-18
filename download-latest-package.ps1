Param(
    [parameter(Mandatory=$true)][string] $package,
    [parameter(Mandatory=$true)][string] $tag,
	[string] $destination = $null	
)

if (!$destination) {
	$destination = "c:\www\${package}"
}

Write-Host "Looking for ${tag} or latest master for package ${package}"

$versions = Invoke-RestMethod -Uri "http://proget.stormwind.local/upack/BuildAssets/versions?name=${package}"

$selected_tagged = $null
$selected_master = $null

foreach ($version in $versions) {
	write-host $version.version
	if ($version.version.EndsWith("-${tag}")) {
		if (($version.version -gt $selected_tagged) -Or !($selected_tagged)) {
			$selected_tagged = $version.version
		}
	}
	
	if ($version.version.Contains("-")) {
	} else {
		Write-Host "$($version.version) > $selected_master"
		if (($version.version -gt $selected_master) -Or !($selected_master)) {
			$selected_master = $version.version
		}
	}
}

Write-Host "Selected master: ${selected_master}"
Write-Host "Selected tagged: ${selected_tagged}"

$selected = $selected_master
if ($selected_tagged) {
	$selected = $selected_tagged
}

if (!$selected) {
	Write-Host "no version found to select"
	exit 1
}

Write-Host "Selected: $selected"
Write-Host "Destination: $destination"

& c:\bin\upack.exe install $package --version $selected --source=http://10.100.69.79/upack/BuildAssets --target=$destination --overwrite --user=upack:foobar12
