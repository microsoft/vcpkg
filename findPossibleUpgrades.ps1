$possible_ports = git grep -l vcpkg_from_github | % { $_ -replace "/portfile.cmake","" } | ? { $_ -notmatch "boost" }

$possible_ports | % {
    $ver = gc "$_/control" | select-string "Version:"
    if ($ver -match "\d\d\d\d-\d\d?-\d\d?|[\da-fA-F]{15}")
    {
        $result = New-Object -TypeName PSObject
        Add-Member -InputObject $result -MemberType NoteProperty -Name Name -Value $_
        Add-Member -InputObject $result -MemberType NoteProperty -Name MatchType -Value rolling
        Add-Member -InputObject $result -MemberType NoteProperty -Name Version -Value $($ver -replace "Version: *","")
        $result
    }
}
