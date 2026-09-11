param([switch]$SelfTest)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path $PSScriptRoot -Parent
function Read-Repo([string]$Path) { [IO.File]::ReadAllText((Join-Path $repoRoot $Path), [Text.Encoding]::UTF8) }
function Require([bool]$Condition, [string]$Message) { if (-not $Condition) { throw $Message } }
function Tokens([string]$Text, [string]$Pattern) {
    @([regex]::Matches($Text, $Pattern) | ForEach-Object { $_.Value })
}
function Same-Set($Actual, $Expected, [string]$Label) {
    $a = @($Actual); $e = @($Expected)
    Require (@($a | Select-Object -Unique).Count -eq $a.Count) "$Label duplicate"
    Require (($a.Count -eq $e.Count) -and ((@($a | Sort-Object) -join ',') -eq (@($e | Sort-Object) -join ','))) "$Label mismatch"
}
function Rows([string]$Text, [string]$Heading, [string]$Pattern) {
    $active = $Heading -eq ''
    foreach ($line in ($Text -split '\r?\n')) {
        if ($Heading -ne '' -and $line -eq "## $Heading") { $active = $true; continue }
        if ($Heading -ne '' -and $active -and $line -match '^## ') { break }
        if ($active -and $line -match "^\| ($Pattern) \|") {
            $parts = @($line.Split('|') | ForEach-Object { $_.Trim() })
            ,@($parts[1..($parts.Count - 2)])
        }
    }
}
$reqPattern = '(?:FR|DR|VR)-\d{3}|(?:NFR|EXT)-[A-Z]+-\d{3}'
function Req-Ids([string]$Text) {
    $expanded = [regex]::Replace($Text, '([A-Z]+(?:-[A-Z]+)?-)(\d+)~(\d+)', {
        param($m)
        $prefix = $m.Groups[1].Value; $width = $m.Groups[2].Length
        (@([int]$m.Groups[2].Value..[int]$m.Groups[3].Value | ForEach-Object { $prefix + $_.ToString().PadLeft($width, '0') }) -join ', ')
    })
    Tokens $expanded $reqPattern
}
$source = Read-Repo 'docs/02-technical/requirements.md'
$sourceRows = @{}; $sourceAC = @{}
foreach ($r in @(Rows $source '' $reqPattern)) {
    Require (-not $sourceRows.ContainsKey($r[0])) "Source duplicate $($r[0])"
    $sourceRows[$r[0]] = $r
}
foreach ($r in @(Rows $source '' 'AC-\d{2}')) {
    Require (-not $sourceAC.ContainsKey($r[0])) "Source AC duplicate $($r[0])"
    $sourceAC[$r[0]] = $r
}
$decisionSource = (Read-Repo 'docs/02-technical/architecture.md') + [char]10 + (Read-Repo 'docs/02-technical/data-model.md')
$decisionIds = @(Rows $decisionSource '' '(?:AD|DDI|MIN)-\d{2}' | ForEach-Object { $_[0] })
$wbsText = Read-Repo 'docs/03-planning/implementation-plan.md'
$wbsIds = @([regex]::Matches($wbsText, '(?m)^\| \[(WBS-\d{2})\]') | ForEach-Object { $_.Groups[1].Value })
Require ($sourceRows.Count -eq 99 -and $sourceAC.Count -eq 24 -and $decisionIds.Count -eq 41 -and $wbsIds.Count -eq 31) 'Source inventory changed'
function Validate([string]$Text) {
    $rs = @(Rows $Text 'Requirement Matrix' $reqPattern)
    Same-Set @($rs | ForEach-Object { $_[0] }) @($sourceRows.Keys) 'Requirements'
    $ps = @(Rows $Text 'Owner Profiles' 'P-\d{2}')
    $pids = @($ps | ForEach-Object { $_[0] })
    Same-Set $pids @($pids | Select-Object -Unique) 'Profiles'
    foreach ($p in $ps) {
        Require ($p.Count -eq 4) 'Profile columns'
        foreach ($wid in @(Tokens ($p[1]+', '+$p[2]) 'WBS-\d{2}')) { Require ($wbsIds -contains $wid) "Profile WBS $wid" }
        foreach ($spk in @(Tokens $p[3] 'SPK-[A-Za-z0-9]+')) { Require ($spk -in @('SPK-01','SPK-02','SPK-03','SPK-04','SPK-05','SPK-06A','SPK-06B')) "Spike $spk" }
    }
    $hgCount = 0
    foreach ($r in $rs) {
        Require ($r.Count -eq 12) "Columns $($r[0])"
        $id = $r[0]
        Require ($r[1] -eq $sourceRows[$id][1]) "Priority $id"
        Require (($wbsIds -contains $r[2]) -and ($wbsIds -contains $r[3])) "Owner $id"
        Require ($pids -contains $r[4]) "Profile $id"
        $ds = @(Tokens $r[5] '(?:AD|DDI|MIN)-\d{2}')
        Require ($ds.Count -gt 0) "Missing decision $id"
        Same-Set $ds @($ds | Select-Object -Unique) "Decision list $id"
        foreach ($d in $ds) { Require ($decisionIds -contains $d) "Unknown decision $d" }
        Require ($r[7].StartsWith("EV-$($id):")) "Evidence ID $id"
        Require ($r[8].Trim([char]96) -eq "evidence/$($r[3])/EV-$id/<run-id>/manifest.json") "Evidence path $id"
        if ($r[1] -eq 'P0-HG') { $hgCount++; Require ($r[9] -ne '-' -and $r[9].Length -gt 10) "Negative evidence $id" }
        Require ($r[10] -eq 'not_run') "Unexecuted status $id"
        Require ($r[11] -eq 'B-01, B-02, B-03') "Blockers $id"
    }
    Require ($hgCount -eq 34) 'P0-HG inventory'
    $reverse = @(Rows $Text 'WBS Reverse Index' 'WBS-\d{2}')
    Same-Set @($reverse | ForEach-Object { $_[0] }) $wbsIds 'WBS reverse inventory'
    foreach ($r in $reverse) {
        Require ($r.Count -eq 5) 'WBS reverse columns'
        Same-Set @(Req-Ids $r[1]) @($rs | Where-Object { $_[2] -eq $r[0] } | ForEach-Object { $_[0] }) "WBS realization $($r[0])"
        Same-Set @(Req-Ids $r[2]) @($rs | Where-Object { $_[3] -eq $r[0] } | ForEach-Object { $_[0] }) "WBS verification $($r[0])"
        $expectedProfiles = @($ps | Where-Object { @(Tokens ($_[1]+', '+$_[2]) 'WBS-\d{2}') -contains $r[0] } | ForEach-Object { $_[0] })
        Same-Set @(Tokens $r[3] 'P-\d{2}') $expectedProfiles "WBS profiles $($r[0])"
    }
    Same-Set @($rs | ForEach-Object { $_[4] } | Select-Object -Unique) $pids 'Profile orphans'
    $acs = @(Rows $Text 'AC Reverse Map' 'AC-\d{2}')
    Same-Set @($acs | ForEach-Object { $_[0] }) @($sourceAC.Keys) 'AC inventory'
    foreach ($a in $acs) {
        Require ($a.Count -eq 4 -and $a[3] -eq 'not_run') "AC status $($a[0])"
        Same-Set @(Req-Ids $a[1]) @(Req-Ids $sourceAC[$a[0]][1]) "AC source $($a[0])"
        Require ($a[2] -eq $sourceAC[$a[0]][2]) "AC evidence $($a[0])"
    }
    foreach ($r in $rs) {
        $expected = @($acs | Where-Object { @(Req-Ids $_[1]) -contains $r[0] } | ForEach-Object { $_[0] })
        Same-Set @(Tokens $r[6] 'AC-\d{2}') $expected "AC reverse $($r[0])"
    }
    $nonAC = @(Rows $Text 'Non-AC Product Sources' $reqPattern)
    Same-Set @($nonAC | ForEach-Object { $_[0] }) @($rs | Where-Object { $_[6] -eq '-' } | ForEach-Object { $_[0] }) 'Non-AC inventory'
    foreach ($r in $nonAC) {
        $column = if ($r[0].StartsWith('DR-')) { 5 } else { 3 }
        Require ($r.Count -eq 2 -and $r[1] -eq $sourceRows[$r[0]][$column] -and $r[1].Length -gt 0) "Product source $($r[0])"
    }
    $decisions = @(Rows $Text 'Decision Reverse Map' '(?:AD|DDI|MIN)-\d{2}')
    Same-Set @($decisions | ForEach-Object { $_[0] }) $decisionIds 'Decisions'
    foreach ($d in $decisions) {
        $expected = @($rs | Where-Object { @(Tokens $_[5] '(?:AD|DDI|MIN)-\d{2}') -contains $d[0] } | ForEach-Object { $_[0] })
        Require ($expected.Count -gt 0) "Decision orphan $($d[0])"
        Same-Set @(Req-Ids $d[1]) $expected "Decision reverse $($d[0])"
    }
    $gates = @(Rows $Text 'Hard Gate Evidence Map' 'HG-\d{2}')
    Same-Set @($gates | ForEach-Object { $_[0] }) @('HG-01','HG-02','HG-03','HG-04','HG-05','HG-06') 'Hard Gates'
    foreach ($g in $gates) {
        Require ($g.Count -eq 8 -and $g[7] -eq 'not_run') "Gate status $($g[0])"
        Require ($wbsIds -contains $g[3]) "Gate owner $($g[0])"
        $ids = @(Req-Ids $g[2]); Require ($ids.Count -gt 0) "Gate requirements $($g[0])"
        foreach ($id in $ids) { Require ($sourceRows.ContainsKey($id)) "Gate requirement $id" }
        $chain = @(Tokens $g[4] 'WBS-\d{2}')
        Require ($chain -contains 'WBS-30') "Gate actual evidence $($g[0])"
        foreach ($wid in $chain) { Require ($wbsIds -contains $wid) "Gate verification $wid" }
        Require ($g[5].Length -gt 10) "Gate negative $($g[0])"
        Require ($g[6].Trim([char]96) -eq "evidence/HG/$($g[0])/<run-id>/manifest.json") "Gate path $($g[0])"
    }
}
$baseline = (Read-Repo 'docs/03-planning/traceability-baseline.md').Replace(([string][char]13), '')
Validate $baseline
Write-Output 'PASS: 99 requirements, 24 AC, 41 decisions, 34 P0-HG negatives, 6 gates; structural only.'
if ($SelfTest) {
    $line = @($baseline -split '\n' | Where-Object { $_.StartsWith('| FR-002 |') })[0]
    $cases = [ordered]@{
        missing = $baseline.Replace($line + [char]10, '')
        duplicate = $baseline.Replace($line, $line + [char]10 + $line)
        owner = $baseline.Replace('| WBS-14 | WBS-23 | P-14 |', '| WBS-99 | WBS-23 | P-14 |')
        negative = $baseline.Replace($line, (($line.Split('|')[0..9] -join '|') + '| - | not_run | B-01, B-02, B-03 |'))
        ac_drift = $baseline.Replace('| AC-01 | FR-001, FR-003, EXT-GN-001 |', '| AC-01 | FR-001, FR-003 |')
        decision_orphan = $baseline.Replace('MIN-08, DDI-07 |', 'MIN-08 |')
        false_pass = $baseline.Replace('| not_run | B-01, B-02, B-03 |', '| pass | B-01, B-02, B-03 |')
    }
    $expectedErrors = @{ missing='Requirements mismatch'; duplicate='Requirements duplicate'; owner='Owner'; negative='Negative evidence'; ac_drift='AC source'; decision_orphan='Decision orphan DDI-07'; false_pass='Unexecuted status' }
    foreach ($name in $cases.Keys) {
        Require ($cases[$name] -ne $baseline) "Self-test did not mutate: $name"
        $rejected = $false
        try { Validate $cases[$name] } catch { $rejected = $_.Exception.Message.StartsWith($expectedErrors[$name]) }
        Require $rejected "Self-test failed to reject: $name"
        Write-Output "PASS: rejected $name"
    }
}
