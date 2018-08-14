[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls11

Set-Location (Split-Path $MyInvocation.MyCommand.Path -Parent)

# Replace your domain.
$domain = "http://example.com/"

# If you need, change file name.
$htaccess = Get-Content -Encoding UTF8 ./htaccess

echo "Dir,URL,StatusCode,StatusDescription,RedirectedStatus,RedirectedDescription" > check_log.txt

for($i=0; $i -lt $htaccess.Count; $i++){

    if (-Not($htaccess[$i].Contains("RewriteRule"))){ Continue }

    $dir = ($htaccess[$i].Split(' '))[1].Remove(0,1)

    $url = $domain + $dir

    try {
        $res = Invoke-webrequest -uri $url -method get -MaximumRedirection 0 -ErrorAction Ignore
        $row = $dir + "," + $url + "," + [string]$res.StatusCode + "," + $res.StatusDescription
    } catch {
        $row = $url + "," + 404 + "," 
    }

    if ($res.StatusCode -eq 301) {
        try {
            $redirect = Invoke-webrequest -uri $url -method get -ErrorAction Ignore
            $row += "," + [string]$redirect.StatusCode + "," + $redirect.StatusDescription
        } catch {
            $row += ",404,,"  
        }
    }

    echo $row >> ./check_log.txt

}