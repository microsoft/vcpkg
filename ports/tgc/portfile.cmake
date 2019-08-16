include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

set(SOURCE_VERSION 35207051557c79ea25942c021fb18856c72af8e3)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/orangeduck-tgc-${SOURCE_VERSION})

file(MAKE_DIRECTORY ${SOURCE_PATH})

# See ports/nlohmann-json/portfile.cmake
function(download_src SUBPATH SHA512)
    vcpkg_download_distfile(
        FILE
        URLS "https://raw.githubusercontent.com/orangeduck/tgc/master/${SUBPATH}"
        FILENAME "orangeduck-tgc-${SOURCE_VERSION}/${SUBPATH}"
        SHA512 ${SHA512}
    )
    get_filename_component(SUBPATH_DIR "${SOURCE_PATH}/${SUBPATH}" DIRECTORY)
    file(COPY ${FILE} DESTINATION ${SUBPATH_DIR})
endfunction()

download_src(
    tgc.h
    55944055fa83cfc1cbdf026f6ea65d42c1704800d26a7cb6d31a0afcfc61a2ca61d5e539edbf354c4572a885dbc6f38cbb6593cbb66d5dc78eb7d3b66d613dd8
)
download_src(
    tgc.c
    942eefd9b02558f94315023734e9b3b74e326d5a705e9e8809cb4ddb0c6272d8ba9b9715f7d53d7a6151b8cff1377561d169a310c48d200698f9d26ba2c106c3
)
download_src(
    LICENSE.md
    89c46e23f61d2912f47a10e807ee823e78b708804c5cfea2382e1d5a9955f0f1a67e421453b5868db2f71229aae8b83c271bb1cf89631b43e91e5d6c4fcbf1a7
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-${PORT} TARGET_PATH share/unofficial-${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE.md ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

# CMake integration test
vcpkg_test_cmake(PACKAGE_NAME unofficial-${PORT})
