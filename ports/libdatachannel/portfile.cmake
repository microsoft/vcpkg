vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO paullouisageneau/libdatachannel
    REF "v${VERSION}"
    SHA512 fc4e1ae2b640e8439fb8ca490cfaa27461e74ee44abc1798d49a97a97f1de7fec5cc776b7dedf58e72eb0ccbb5bf0edaf92e4db8052980667567ef6e783b4b39
    HEAD_REF master
    PATCHES
        dependencies.diff
        uwp-warnings.patch
        nominmax.patch
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

foreach(header IN ITEMS common.hpp rtc.h)
    if(NOT "srtp" IN_LIST FEATURES)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/rtc/${header}" "#define RTC_ENABLE_MEDIA 1" "#define RTC_ENABLE_MEDIA 0")
    endif()
    if(NOT "ws" IN_LIST FEATURES)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/rtc/${header}" "#define RTC_ENABLE_WEBSOCKET 1" "#define RTC_ENABLE_WEBSOCKET 0")
    endif()
endforeach()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
