# execute_process

Intercepts all calls to execute_process() inside portfiles and fails when Download Mode
is enabled.

In order to execute a process in Download Mode call `vcpkg_execute_in_download_mode()` instead.


## Source
[scripts/cmake/execute_process.cmake](https://github.com/Microsoft/vcpkg/blob/master/scripts/cmake/execute_process.cmake)
