<#  Find Duplicate
	Just a small and simple POC Powershell script that searches for duplicate files, comparing their file hashes.
#>

$Paths=@("$($Env:USERPROFILE)\Documents", "\\NAS\Documents")
$Alg="SHA256"
 
ForEach ($Path in $Paths) {
   Write-Host "Indexing '$Path'"
   $Files += $(gci $Path -Recurse | Where-Object{!$_.PSIsContainer} | Select FullName, @{Name="Size";Expression={$_.Length}})
}
 
$Files = $Files | Group-Object Size | Where-Object {$_.Count -gt 1}
Write-Host "Files indexed, $($Files.Group.count) files found that have one or more equal sized files, checking $Alg FileHash.`n"
 
$Files.Group | ForEach-Object { Get-FileHash -Algorithm $Alg -Path $_.FullName } | Group-Object Hash | Where-Object {$_.Count -gt 1} `
    | ForEach-Object {$_.Group} | Format-Table -AutoSize -GroupBy Hash -Property Path, Hash
 
Write-Host "`nDone..."
