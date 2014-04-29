<#
|==============================================================================>|
   AP-Compiler by APoorv Verma [AP] on 4/21/2014
|==============================================================================>|
      $) Compiles AP-Programs Independent of the AP-Modules file
      $) Reads And Calculates all the Modules needed!
      $) Adds code with comment in a neat BASE64 Code
|==============================================================================>|
#>
param([String]$File,[String]$OutputFolder = '.')
$Ver = '1.0'
if (!$File -or !(Test-Path -type Leaf $File)) {Throw "Invalid File";exit}
if (!(Test-Path -type Container $OutputFolder)) {Throw "Invalid Folder";exit}
$File = "{0}" -f (Resolve-Path $File)
$OutputFolder = "{0}" -f (Resolve-Path $OutputFolder)
$Modules = $Dep | % {$_[0]};$TmpHash = @{};$Modules | % {$TmpHash.$_ = $_}
$Aliases = Get-Alias | ? {$TmpHash.($_.Definition)} | % {"$_"}
$Data = [IO.File]::ReadAllLines($File)
$Script:OtroFunc = @{}
$Script:Need2Import = @{}
$Script:Need2ImportAL = @{}
$BEG = "((^|[\(;\=])( ?)+)";$END = "( ?)+((\S+ )+(\S+))?([;\)\(""]|$)"
foreach ($Ln in $Data) {
    if ($LN -match "^ +function (?<Name>\w+)") {$OtroFunc += {$Matches.Name = "Added"};continue}
    $Modules | ? {$LN -match "$BEG$([Regex]::Escape($_))$END"} | % {$Need2Import.$_++}
    $Aliases | ? {$LN -match "$BEG$([Regex]::Escape($_))$END"} | % {$Need2ImportAL.$_++;$Need2Import.((Get-Alias $_).Definition)++}
}
$FinalSet = @($Need2Import.Keys) | ? {!$OtroFunc.$_}
$FinalAlSet = @($Need2ImportAL.Keys)
$Code = $FinalSet | % {"function $_ {1}`n{0}{2}" -f (iex "`${Function:$_}"),"{","}`n"}
$Code += $FinalAlSet | % {"Set-Alias $_ {0}" -f ((Get-Alias $_).Definition)}
if ($Code) {
if ($FinalSet) {Write-AP "*Adding Functions $(Print-List $FinalSet)"}
if ($FinalALSet) {Write-AP "*Adding Aliases   $(Print-List $FinalALSet)"}
$Injecter = @"
# =======================================START=OF=COMPILER==========================================================|
#    The Following Code was added by AP-Compiler Version [$Ver] To Make this program independent of AP-Core Engine
# ==================================================================================================================|
iex ([System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("$(Convert-ToBase64 ($Code -join "`n"))")))
# ========================================END=OF=COMPILER===========================================================|
"@}
$Symb = "$(0..3|%{Get-Random})"
$Data = $Data -join $Symb
if ($Data -match "(?<ParamCode>Param( ?)+\(.*$Symb\)$Symb)") {
    $Data=$Data.replace($Matches['ParamCode'],"$($Matches['ParamCode'])`n$Injecter")
} elseif ($Data -match "(?<ParamCode>Param( ?)+\(.*\))") {
#    @($Data -match "(?<ParamCode>Param\(.*\))")[0] -match "(?<ParamCode>Param\(.*\))" | Out-Null;$Data=$Data.replace($Matches['ParamCode'],"$($Matches['ParamCode'])`n$Injecter")
    $Data=$Data.replace($Matches['ParamCode'],"$($Matches['ParamCode'])`n$Injecter")
} else {
    $Data = "$Injecter",$Data
}
$Data = $Data.replace($Symb,"`n")
$APStructure = (Flatten $Data) -join "`n"
if ((Split-Path $File) -eq $OutputFolder) {
    $Outfile = "$((Split-Path -leaf $File).replace('.ps1','-Compiled.ps1'))"
} else {$Outfile = "$(Split-Path -leaf $File)
# =======================================START=OF=COMPILER==========================================================|
#    The Following Code was added by AP-Compiler Version [1.0] To Make this program independent of AP-Core Engine
# ==================================================================================================================|
iex ([System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("ZnVuY3Rpb24gQ29udmVydC1Ub0Jhc2U2NCB7CnBhcmFtKFtTdHJpbmddJFRleHQpDQoNCiAgICBbU3lzdGVtLkNvbnZlcnRdOjpUb0Jhc2U2NFN0cmluZyhbU3lzdGVtLlRleHQuRW5jb2RpbmddOjpVVEY4LkdldEJ5dGVzKCRUZXh0KSkNCn0KCmZ1bmN0aW9uIEZsYXR0ZW4gewpwYXJhbShbb2JqZWN0W11dJHgpDQppZiAoJFguY291bnQgLWVxIDEpIHtyZXR1cm4gJHggfCAlIHskX319IGVsc2UgeyR4IHwgJSB7RmxhdHRlbiAkX319fQoKZnVuY3Rpb24gV3JpdGUtQVAgewpwYXJhbShbUGFyYW1ldGVyKE1hbmRhdG9yeT0kVHJ1ZSldW1N0cmluZ10kVGV4dCkNCg0KICAgICRhY2MgID0gQCgoJysnLCcyJyksKCctJywnMTInKSwoJyEnLCcxNCcpLCgnKicsJzMnKSkNCiAgICAkdGIgICA9ICcnOyRmdW5jICAgPSAkZmFsc2UNCiAgICB3aGlsZSAoJFRleHQuY2hhcnMoMCkgLWVxICd4JykgeyRmdW5jID0gJHRydWU7ICRUZXh0ID0gJFRleHQuc3Vic3RyaW5nKDEpLnRyaW0oKX0NCiAgICB3aGlsZSAoJFRleHQuY2hhcnMoMCkgLWVxICc+JykgeyR0YiArPSAiICAgICI7ICRUZXh0ID0gJFRleHQuc3Vic3RyaW5nKDEpLnRyaW0oKX0NCiAgICAkU2lnbiA9ICRUZXh0LmNoYXJzKDApDQogICAgJFRleHQgPSAkVGV4dC5zdWJzdHJpbmcoMSkudHJpbSgpLnJlcGxhY2UoJy94XCcsJycpLnJlcGxhY2UoJ1suXScsJ1tDdXJyZW50IERpcmVjdG9yeV0nKQ0KICAgICR2ZXJzID0gJGZhbHNlDQogICAgZm9yZWFjaCAoJGFyIGluICRhY2MpIHtpZiAoJGFyWzBdIC1lcSAkc2lnbikgeyR2ZXJzID0gJHRydWU7ICRjbHIgPSAkYXJbMV07ICRTaWduID0gIlske1NpZ259XSAifX0NCiAgICBpZiAoISR2ZXJzKSB7VGhyb3cgIkluY29ycmVjdCBTaWduIFskU2lnbl0gUGFzc2VkISJ9DQogICAgaWYgKCEoJFNpbGVudCAtYW5kICRTaWduIC1lcSAnWypdICcpKSB7aWYgKCRmdW5jKSAge1dyaXRlLUhvc3QgLW5vbmV3bGluZSAtZiAkY2xyICR0YiRTaWduJFRleHR9IGVsc2Uge3dyaXRlLWhvc3QgLWYgJGNsciAkdGIkU2lnbiRUZXh0fX0NCn0K")))
# ========================================END=OF=COMPILER===========================================================|"}
Write-AP "+Compiled [$OutFile]"
$APStructure | Out-File -Encoding Unicode "$OutputFolder\$OutFile"
