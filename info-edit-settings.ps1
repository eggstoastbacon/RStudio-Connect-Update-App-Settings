#RStudio Connect Application Update POSH
#EggsToastBacon 10/28/2020

#csv file should contain 3 columns; 
#1. host: url of the RStudio connect server "https://connect.company.com", 
#2. guid: guid of the existing application to update
#3. key: api key of the server to authenticate

#Use the config file to specify, config file stays in the same directory as the script.
#1. CSV File location
#2. CURL location (use the latest CURL binaries)
#3. Location of the application update tar.gz file
#4. App name


$config = get-content .\config.txt
$nodes = Invoke-Expression $config[1]
$curl_loc = Invoke-Expression $config[3]
$package_loc = Invoke-Expression $config[5]
$appname = Invoke-Expression $config[7]
cls

$go = read-host "This will edit or read back settings of the app: $appname, press ENTER to continue"

cls

do{
$play = read-host "play or edit?"

if($play -like "*e*"){
write-host "
==== Common Settings =====

max_processes (int value)
min_processes (int value)
max_conns_per_process (int value)
load_factor (int value between 0 and 1 eg. 0.50)
connection_timeout (int value)
read_timeout (int value)
init_timeout (int value)
idle_timeout (int value)
access_type (all, acl, or logged_in)
url (enter shortname url eg. covidapps, [not working])

" -ForeGroundColor Yellow
$setting = read-host "What is the setting?"
$value = read-host "What is the value?"
$rtn = ""
if([double]::TryParse($value,[ref]$rtn)){$valuetype = "int"}else{$valuetype = "string"}
$go = read-host "Press ENTER to confirm $setting to $value"


if($setting -notlike "*url*"){
if($valueType -like "*int*"){
$json = @"
{"$setting":$value}
"@} else {
$json = @"
{"$setting":"$value"}
"@}

$json = $json| ConvertTo-Json
}
}

clear-variable errors -ErrorAction SilentlyContinue
foreach($node in $nodes){
$hostname = $node.host
$guid = $node.guid
$key = $node.key

if($setting -like "*url*"){
$json = @"
"$setting":"$value"}
"@ 

$json = $json | ConvertTo-Json

}

try{
if($play -like "*e*"){
write-host "Editing for $hostname" -ForegroundColor Cyan
cmd.exe /C $curl_loc --silent --show-error --max-redirs 10 -X POST -H "Authorization: Key $key" -H "Accept: application/json" -d $json -L "$hostname/__api__/v1/experimental/content/$guid/"
}

if($play-like "*p*"){
write-host "Info for $hostname" -ForegroundColor Cyan
cmd.exe /C $curl_loc --silent --show-error -L --max-redirs 10 --fail -H "Authorization: Key $key" "$hostname/__api__/v1/experimental/content/$guid"   
}}catch{}

}
$done = read-host "Are you done? (yes or no)"
}while($done -notlike "*y*")
