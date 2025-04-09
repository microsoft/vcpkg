vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO docopt/docopt.cpp
    REF 400e6dd8e59196c914dcc2c56caf7dae7efa5eb3
    SHA512 a9ef466ba40127f636bc20beb7508c4da2dc32c0c37acb5729644f31d4910d9c0253f311457f39ed57605775e72f3370aff4e5ef88e60a49d190bc4760c40ea3
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

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE-MIT" "${SOURCE_PATH}/LICENSE-Boost-1.0")

vcpkg_copy_pdbs()
