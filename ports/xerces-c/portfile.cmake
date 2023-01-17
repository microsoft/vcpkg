vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/xerces-c
    REF "v${VERSION}"
    SHA512 0da61e000e871c045fb6e546cabba244eb6470a7a972c1d1b817ba5ce91c0d1d12dfb3ff1479d8b57ab06c49deefd1c16c36dc2541055e41a1cdb15dbd769fcf
    HEAD_REF master
    PATCHES
        dependencies.patch
        disable-tests.patch
        remove-dll-export-macro.patch
)
file(REMOVE "${SOURCE_PATH}/cmake/FindICU.cmake")

vcpkg_check_features(
    OUT_FEATURE_OPTIONS options
    FEATURES
        icu     CMAKE_REQUIRE_FIND_PACKAGE_ICU
    INVERTED_FEATURES
        icu     CMAKE_DISABLE_FIND_PACKAGE_ICU
)
if("icu" IN_LIST FEATURES)
    vcpkg_list(APPEND options transcoder=icu)
elseif(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_list(APPEND options transcoder=windows)
elseif(VCPKG_TARGET_IS_OSX)
    vcpkg_list(APPEND options transcoder=macosunicodeconverter)
else()
    # xercesc chooses gnuiconv or iconv (cmake/XercesTranscoderSelection.cmake)
endif()
if("xmlch-wchar" IN_LIST FEATURES)
    vcpkg_list(APPEND options -Dxmlch-type=wchar_t)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DDISABLE_TESTS=ON
        -DDISABLE_DOC=ON
        -DDISABLE_SAMPLES=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_CURL=ON
        ${options}
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_cmake_config_fixup(CONFIG_PATH cmake PACKAGE_NAME xercesc)
else()
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/XercesC PACKAGE_NAME xercesc)
endif()

configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" "${CURRENT_PACKAGES_DIR}/share/xercesc/vcpkg-cmake-wrapper.cmake" @ONLY)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_fixup_pkgconfig()
if (VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/xerces-c.pc" "-lxerces-c" "-lxerces-c_3")
    if(NOT VCPKG_BUILD_TYPE)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/xerces-c.pc" "-lxerces-c" "-lxerces-c_3D")
    endif()
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
