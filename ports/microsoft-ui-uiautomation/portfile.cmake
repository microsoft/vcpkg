# portfile.cmake
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/Microsoft-UI-UIAutomation
    REF master
    SHA512 a1388b50a70b14d545adfdce995cc8c88b410d49166ec58ed12b8457248884574e428d8d22c01510907b49042363f4608d4fb4a86f3d79f9fefff746c692e9d1
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
vcpkg_install_copyright(FILE_PATH "${SOURCE_PATH}/LICENSE.txt")
