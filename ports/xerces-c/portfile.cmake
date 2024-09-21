vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/xerces-c
    REF "v${VERSION}"
    SHA512 55bf16456408af7c5aa420a55b27555889fc102a24e86aecb918c165acc80bbc344420687061e020fe223ea04dd78bef929ceedc4b3e24727787f12b8d79b610
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
        network network
    INVERTED_FEATURES
        icu     CMAKE_DISABLE_FIND_PACKAGE_ICU
)
if("icu" IN_LIST FEATURES)
    vcpkg_list(APPEND options -Dtranscoder=icu)
elseif(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_list(APPEND options -Dtranscoder=windows)
elseif(VCPKG_TARGET_IS_OSX)
    vcpkg_list(APPEND options -Dtranscoder=macosunicodeconverter)
elseif(VCPKG_HOST_IS_OSX)
    # Because of a bug in the transcoder selection script, the option
    # "macosunicodeconverter" is always selected when building on macOS,
    # regardless of the target platform. This breaks cross-compiling.
    # As a workaround we force "iconv", which should at least work for iOS.
    # Upstream fix: https://github.com/apache/xerces-c/pull/52
    vcpkg_list(APPEND options -Dtranscoder=iconv)
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
    MAYBE_UNUSED_VARIABLES
        CMAKE_DISABLE_FIND_PACKAGE_CURL
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

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
