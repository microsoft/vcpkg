./vcpkg.exe --feature-flags=versions x-ci-verify-versions --verbose |
ForEach-Object -Begin {
  $long_error = ''
} -Process {
  if ($long_error -ne '' -and $_ -match '^$|^       ') {
     # Extend multi-line message
     $long_error = -join($long_error, "%0D%0A", $_ -replace '^       ','' `
       -replace '(git add) [^ ]*\\ports\\([^ ]*)', '$1 ports/$2' )
  } else {
    if ($long_error -ne '') {
      # Flush multi-line message
      $long_error
      $long_error = ''
    }
    if ($_ -match '^Error: ') {
      # Start multi-line message
      $long_error = $_ -replace '^Error: ', '##vso[task.logissue type=error]' `
        -replace '(^##vso[^\]]*)](.*) [^ ]*\\versions\\(.-)\\(.*.json)(.*)', '$1;sourcepath=versions/$3/$4;linenumber=2]$2 version/$3/$4$5'
    } else {
      # Normal line
      $_
    }
  }
} -End {
  if ($long_error -ne '') {
    # Flush multi-line message
    $long_error
  }
}
