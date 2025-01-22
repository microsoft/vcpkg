vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO paullouisageneau/libdatachannel
    REF "v${VERSION}"
    SHA512 738bfa45b804cab178426301f97674af4d04b253f45c3caa41b9ec8f658672662e9a7e37a61ee1523b724f3888df85ece86105ae3951aac65a0f2b17fc5b4fac
    HEAD_REF master
    PATCHES 
        dependencies.diff
        uwp-warnings.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        stdcall CAPI_STDCALL
    INVERTED_FEATURES
        ws      NO_WEBSOCKET
        srtp    NO_MEDIA
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DPREFER_SYSTEM_LIB=ON
        -DNO_EXAMPLES=ON
        -DNO_TESTS=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/LibDataChannel)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/rtc/common.hpp" "#ifdef RTC_STATIC" "#if 1")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/rtc/rtc.h" "#ifdef RTC_STATIC" "#if 1")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
