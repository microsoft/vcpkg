vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO moehoshio/NekoFunction
    REF v1.0.7
    SHA512 afe897309bf9c793268b34c7410fa986c5f123a1440dc6542c493c0c763642697d387df2f917c2f1dad9eb862ad03da0348e76f324289466dbcb3ff01cece81b
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        archive  NEKO_FUNCTION_ENABLE_ARCHIVE
        hash     NEKO_FUNCTION_ENABLE_HASH
)

function(neko_function_is_header_only OUT_IS_HEADER_ONLY)
    if(NOT "archive" IN_LIST FEATURES AND NOT "hash" IN_LIST FEATURES)
        set(${OUT_IS_HEADER_ONLY} TRUE PARENT_SCOPE)
    else()
        set(${OUT_IS_HEADER_ONLY} FALSE PARENT_SCOPE)
    endif()
endfunction()

neko_function_is_header_only(IS_HEADER_ONLY)
if(IS_HEADER_ONLY)
    set(VCPKG_BUILD_TYPE release)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DNEKO_FUNCTION_BUILD_TESTS=OFF
        -DNEKO_FUNCTION_AUTO_FETCH_DEPS=OFF
        -DNEKO_FUNCTION_ENABLE_MODULE=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/NekoFunction PACKAGE_NAME nekofunction)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

neko_function_is_header_only(IS_HEADER_ONLY)
if(IS_HEADER_ONLY)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
