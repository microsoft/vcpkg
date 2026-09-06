vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jfalcou/tts
    REF "${VERSION}"
    SHA512 2b692bad6c7c64b766915881c614b5edeb95443ba7e3a42f0ad11677923e4098c1319060a5755f89acc7c2d1fb2ab895ad7ab7560e99e09f32046302f274c17c
    HEAD_REF main
)

# 3.0 downloads CPM itself at configure time, at the version its dependencies.cmake pins.
# Seeding CPM_SOURCE_CACHE with the file keeps the configure step off the network.
vcpkg_download_distfile(CPM_CMAKE
    URLS "https://github.com/cpm-cmake/CPM.cmake/releases/download/v0.40.2/CPM.cmake"
    FILENAME "CPM-0.40.2.cmake"
    SHA512 5cb650049473690466c9678ac5f1c42185429c0c12f95e2bab0577c34640fa80c1331b0f46af18ecae258a9eb3c6ed980df4f1cca07650f5ca2a084a88415ffc
)
set(CPM_CACHE "${CURRENT_BUILDTREES_DIR}/cpm-cache")
file(INSTALL "${CPM_CMAKE}" DESTINATION "${CPM_CACHE}/cpm" RENAME "CPM_0.40.2.cmake")

# The build is written with copacabana, which CPM fetches at configure time; the
# copacabana port is handed to CPM instead, so nothing is downloaded here.
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DCPM_SOURCE_CACHE=${CPM_CACHE}"
        "-DCPM_COPACABANA_SOURCE=${CURRENT_HOST_INSTALLED_DIR}/share/jfalcou-copacabana"
        -DCPM_LOCAL_PACKAGES_ONLY=ON
        -DTTS_BUILD_TEST=OFF
        -DTTS_BUILD_DOCUMENTATION=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/tts)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
