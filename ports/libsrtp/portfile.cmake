vcpkg_download_distfile(CMAKE_PR_PATCH
    URLS https://patch-diff.githubusercontent.com/raw/cisco/libsrtp/pull/573.diff
    FILENAME libsrtp-pr-573.patch
    SHA512 58c07977ccbd3dce114f59583a5e10813bbee907af5ef23ec1961b4cfd0791c14326845a376470430978e878c78fb1f598851898a9e9031225628739fb248176
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cisco/libsrtp
    REF v2.4.2
    SHA512 6E4805E6D34B2050A6F68F629B0B42356B1D27F2CBAA6CC6166E56957609C3D9AA6B723DCC674E5C74180D122D27BADD2F9496639CCB1E0C210B9E1F7949D0E2
    PATCHES 
        ${CMAKE_PR_PATCH}
        fix-runtime-destination.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DCMAKE_PROJECT_INCLUDE=${CMAKE_CURRENT_LIST_DIR}/cmake-project-include.cmake"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    CONFIG_PATH lib/cmake/libSRTP
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/libsrtp" RENAME copyright)
