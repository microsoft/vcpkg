vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO docopt/docopt.cpp
    REF 05d507da0d153faff381f44968833ebffdc03447
    SHA512 7927231ede15c64c904694d107035a11275517adebfc90ad9843a7a590f95507372be280d1689b0b5e15cba0e9e8920aaf2634ddb864bfc64366f946290cbbd2
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DWITH_EXAMPLE=OFF
        -DWITH_TESTS=OFF
        -DUSE_BOOST_REGEX=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/docopt)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(READ "${CURRENT_PACKAGES_DIR}/include/docopt/docopt.h" _contents)
    string(REPLACE "#ifdef DOCOPT_DLL" "#ifdef _WIN32" _contents "${_contents}")
    file(WRITE "${CURRENT_PACKAGES_DIR}/include/docopt/docopt.h" "${_contents}")
endif()

# Header-only style when DOCOPT_HEADER_ONLY is defined
file(COPY
    "${SOURCE_PATH}/docopt.cpp"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include/docopt")

vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/LICENSE-MIT"
    "${SOURCE_PATH}/LICENSE-Boost-1.0"
)
