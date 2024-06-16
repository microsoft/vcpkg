set(VCPKG_TARGET_ARCHITECTURE arm64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE static)
set(VCPKG_CMAKE_SYSTEM_NAME iOS)
#set(VCPKG_OSX_DEPLOYMENT_TARGET 16.0) # uncomment to specify the min ios version you want to support
                                       # (not all ports support this option)

# setting the sysroot for cmake and for the env
execute_process(
        COMMAND /usr/bin/xcrun --sdk iphoneos --show-sdk-path
        OUTPUT_VARIABLE sdk_path
        ERROR_VARIABLE xcrun_error
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_STRIP_TRAILING_WHITESPACE
)
if (NOT sdk_path)
    message(FATAL_ERROR "Can't determine iphoneos SDK path. Error: ${xcrun_error}")
endif ()
set(VCPKG_OSX_SYSROOT "${sdk_path}")

set(VCPKG_BUILD_TYPE release)
