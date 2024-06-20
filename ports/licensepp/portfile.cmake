vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO amrayn/licensepp
    REF e9501da1470a3bd29254975577d806612a3d3e3c
    SHA512 6f70904d1214036af3891dc54f71ea2052acd8f60c277dbd2a5f3190ce4610771f36108d4d5a123c0e7312aded410d652460018d74586fc4f41b05fabb6100bd
    HEAD_REF master
    PATCHES
        0001-use-old-pem-pack.patch
        0002-fix-compilation-macos.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/FindCryptoPP.cmake" DESTINATION "${SOURCE_PATH}/cmake")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dtest=OFF
        -Dtravis=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/${PORT}/cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
