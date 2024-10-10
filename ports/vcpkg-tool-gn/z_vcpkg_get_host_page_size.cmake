include_guard(GLOBAL)
function(z_vcpkg_get_host_page_size)
    if(NOT TARGET_TRIPLET STREQUAL _HOST_TRIPLET)
        message(FATAL_ERROR "z_vcpkg_get_host_page_size() must only be called from a host port build")
    endif()

    set(BUILD_DIR "${CURRENT_BUILDTREES_DIR}/host_page_size")
    set(SRC "${BUILD_DIR}/get_host_page_size.c")

    file(WRITE "${SRC}" "
         #include <stdlib.h>
#ifdef _WIN32
    #include <windows.h>
#else
    #include <unistd.h>

    #if defined __APPLE__
        #include <sys/sysctl.h>
    #elif defined __linux__
        #include <stdio.h>
    #elif (defined(__FreeBSD__) || defined(__NetBSD__))
        #include <sys/param.h>
    #else
        #error unrecognized platform
    #endif
#endif

#include <stdio.h>
int main() {
    long result = 0;
    size_t cache_line_size = 0;
    #ifdef _WIN32
        SYSTEM_INFO si;
        DWORD bufferSize = 0;
        DWORD i = 0;
        SYSTEM_LOGICAL_PROCESSOR_INFORMATION *buffer = 0;

        GetSystemInfo(&si);
        result = si.dwSizes;
    #else
        result = sysconf(_SC_PAGESIZE);
    #endif
    printf(\"%ld\", result);

    return 0;
}
")

    # FIXME: Is there a vcpkg approved :tm: try_run replacement?
    vcpkg_find_acquire_program(CLANG)
    vcpkg_execute_required_process(
        COMMAND "${CLANG}" -o "${BUILD_DIR}/get_host_page_size" "${SRC}"
        WORKING_DIRECTORY "${BUILD_DIR}"
        LOGNAME "get_host_page_size-compile"
    )

    execute_process(
        COMMAND "${BUILD_DIR}/get_host_page_size"
        OUTPUT_VARIABLE RUN_OUTPUT
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_VARIABLE RUN_ERROR
    )

    if (NOT RUN_ERROR STREQUAL "")
        message(FATAL_ERROR "Error running get_host_page_size: ${RUN_ERROR}")
    endif()

    message(STATUS "Host page size: ${RUN_OUTPUT}")
    set(Z_VCPKG_HOST_PAGE_SIZE "${RUN_OUTPUT}" PARENT_SCOPE)
endfunction()
