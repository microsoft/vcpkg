if ($IsWindows) {
    & cmd.exe /c "echo `"This is an error that should fail the run`" 1>&2"
} else {
    & bash "echo `"This is an error that should fail the run`" 1>&2"
}
