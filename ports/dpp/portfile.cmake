vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO brainboxdotcc/DPP
    REF "v${VERSION}"
    SHA512 91c28f5ec96e3cb8312a01dffe03c0a4280d0499a310c594954ff1967d25f919805dfd069df2a77ad7e12d187438eba33763e433f8ed524ae48e73f976a5a2c7
    PATCHES
        "include.patch"
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        coro DPP_FORMATTERS # Using coro requires C++20, so let's enable formatters as well since we are using C++20
    INVERTED_FEATURES
        coro DPP_NO_CORO
)

if("coro" IN_LIST FEATURES)
    set(CXX_STANDARD 20)
else()
    set(CXX_STANDARD 17)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_CXX_STANDARD=${CXX_STANDARD}
        -DCMAKE_CXX_STANDARD_REQUIRED=ON
        -DDPP_BUILD_TEST=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(NO_PREFIX_CORRECTION)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share/dpp")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
