vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jfalcou/kumi
    REF "v${VERSION}"
    SHA512 e34b4a5886dc9051453d6e27d3618c0fc09762e31cad6760cac25f5edb5b3c086ea5c0eaa75947d76d130e45732a0299224a5317cbeb2d23bbe937c6c11d1b6e
    HEAD_REF main
)

# This release downloads CPM itself at configure time, at the version its dependencies.cmake
# pins. Seeding CPM_SOURCE_CACHE with the file keeps the configure step off the network.
vcpkg_download_distfile(CPM_CMAKE
    URLS "https://github.com/cpm-cmake/CPM.cmake/releases/download/v0.40.8/CPM.cmake"
    FILENAME "CPM-0.40.8.cmake"
    SHA512 46cd734f4c00dc2fdb40913a8e609154641c3a631e521ac4809d54243ae87bb82db8839b34a04856352372552f08e9332b963042df2c464f524689d7734eca6d
)
set(CPM_CACHE "${CURRENT_BUILDTREES_DIR}/cpm-cache")
file(INSTALL "${CPM_CMAKE}" DESTINATION "${CPM_CACHE}/cpm" RENAME "CPM_0.40.8.cmake")

# The build is written with copacabana, which CPM fetches at configure time; the
# copacabana port is handed to CPM instead, so nothing is downloaded here.
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DCPM_SOURCE_CACHE=${CPM_CACHE}"
        "-DCPM_COPACABANA_SOURCE=${CURRENT_HOST_INSTALLED_DIR}/share/jfalcou-copacabana"
        -DCPM_LOCAL_PACKAGES_ONLY=ON
        -DKUMI_BUILD_TEST=OFF
        -DKUMI_BUILD_DOCUMENTATION=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/kumi)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
