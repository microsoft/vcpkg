vcpkg_fail_port_install(ON_TARGET "Linux" "OSX" "UWP" ON_ARCH "x86")

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ofiwg/libfabric
    REF 9682913a72c982b4a872b6b18cf2889e158a029b # v1.13.1
    HEAD_REF master
    SHA512 a484126d5f2b6ada1a081af4ae4b60ca00da84814f485cd39746f2ab82948dc68fac5fb47cda39510996e61765d3cf07c409f7a8646f33922d2486b6fb7ee2ab
    PATCHES
        add_additional_includes.patch
)

set(LIBFABRIC_RELEASE_CONFIGURATION "Release-v142")
set(LIBFABRIC_DEBUG_CONFIGURATION "Debug-v142")

vcpkg_install_msbuild(
    SOURCE_PATH ${SOURCE_PATH}
    PROJECT_SUBPATH libfabric.vcxproj
    INCLUDES_SUBPATH include
    LICENSE_SUBPATH COPYING
    PLATFORM "x64"
    RELEASE_CONFIGURATION ${LIBFABRIC_RELEASE_CONFIGURATION}
    DEBUG_CONFIGURATION ${LIBFABRIC_RELEASE_CONFIGURATION}
    USE_VCPKG_INTEGRATION
    ALLOW_ROOT_INCLUDES
    OPTIONS
      /p:SolutionDir=${SOURCE_PATH}
      /p:AdditionalIncludeDirectories="${CURRENT_INSTALLED_DIR}/include"
)

#Move includes under subdirectory to avoid colisions with other libraries
file(RENAME "${CURRENT_PACKAGES_DIR}/include" "${CURRENT_PACKAGES_DIR}/includetemp")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/include")
file(RENAME "${CURRENT_PACKAGES_DIR}/includetemp" "${CURRENT_PACKAGES_DIR}/include/libfabric")

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
