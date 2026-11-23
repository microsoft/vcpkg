# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dpilger26/NumCpp
    REF "Version_${VERSION}"
    SHA512 0415fcf3547b047e16a21cf790b24cf90b61ac9b70a2048e8b7657fe395f188efe83631a2a4e972e124ea81857e7dcd7a629001e1bf8eb4f94e2f67afe2c0354
    HEAD_REF master
    PATCHES
        fix-boost-config.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
        boost NUMCPP_NO_USE_BOOST
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME NumCpp CONFIG_PATH share/NumCpp/cmake)

if(NOT "boost" IN_LIST FEATURES)
    file(GLOB_RECURSE numcpp_headers "${CURRENT_PACKAGES_DIR}/include/*.hpp")
    foreach(numcpp_header IN LISTS numcpp_headers)
        file(READ "${numcpp_header}" numcpp_header_contents)
        if(numcpp_header_contents MATCHES "NUMCPP_NO_USE_BOOST")
            string(REPLACE
                "#pragma once"
                "#pragma once\n\n#ifndef NUMCPP_NO_USE_BOOST\n#define NUMCPP_NO_USE_BOOST\n#endif"
                numcpp_header_contents
                "${numcpp_header_contents}"
            )
            file(WRITE "${numcpp_header}" "${numcpp_header_contents}")
        endif()
    endforeach()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
