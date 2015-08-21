function Get-Gist {
    
    param(
        [Parameter(Mandatory)]
        [string]$User,
        [string]$FileName,
        [switch]$clip,
        [switch]$sendToISE
    )    
    $gists = Invoke-RestMethod -Headers (Get-GistAuthHeader) -Uri "https://api.github.com/users/$($User)/gists" 
    foreach ($gist in $gists) {
        $GistFileName = ($gist.files| Get-Member -MemberType NoteProperty).Name
        if ($GistFileName -notmatch $FileName){
            continue
        }
        $rawUrl = ($gist.files).($GistFileName).raw_url
        $content = ''
        if ($rawUrl){
            $content = Invoke-RestMethod -Uri $RawUrl -Headers $Header
            if ($clip){
                $content | clip
            }
            if ($sendToISE){
                $temp = "$env:TEMP\$GistFileName"
                $content | Out-File -FilePath $temp
                [void]$psise.CurrentPowerShellTab.Files.Add($temp)
                del $temp -force
            }
        }
        [PSCustomObject]@{            
            FileName    = $GistFileName
            Description = $gist.Description
            Url         = $gist.url
            RawUrl      = $rawUrl
            GistID      = Split-Path -Leaf $gist.url
            Content     = $content
        }
    }
    
}