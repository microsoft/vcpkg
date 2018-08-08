include(vcpkg_common_functions)

if(VCPKG_CMAKE_SYSTEM_NAME)
    message(FATAL_ERROR "getopt-win32 only supports building on Windows Desktop")
endif()

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY ONLY_DYNAMIC_CRT)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libimobiledevice-win32/getopt
    REF 0.1
    SHA512 40e2a901241a5d751cec741e5de423c8f19b105572c7cae18adb6e69be0b408efc6c9a2ecaeb62f117745eac0d093f30d6b91d88c1a27e1f7be91f0e84fdf199
    HEAD_REF master
)

vcpkg_install_msbuild(
    SOURCE_PATH ${SOURCE_PATH}
    PROJECT_SUBPATH getopt.vcxproj
    LICENSE_SUBPATH LICENSE
)

# Copy header
file(COPY ${SOURCE_PATH}/getopt.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/)
