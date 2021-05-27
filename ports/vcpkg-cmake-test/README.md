# vcpkg-cmake-test

This port contains cmake functions for testing the generated cmake config files.

In the common case, any port that generates `*[C][c]onfig.cmake` should call this
function to check whether the generated configuration is correct.
