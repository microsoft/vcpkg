if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eclipse-iceoryx/iceoryx2
    REF 6a84763cefcec0f0a8dd4e56f4a2e146b1473b1b # "2025-12-09"
    SHA512 c7176fd24ecdd64931e1729c10522d4d3ec00c30ab4b68c414258afe61de8575badb83c9ee200ce6e00e27af7ecf36176600e04c2eee96059f8afd1ee7b35aa7
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
        "build-cxx"                 BUILD_CXX
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME iceoryx2-c CONFIG_PATH lib/cmake/iceoryx2-c DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(PACKAGE_NAME iceoryx2-bb-cxx CONFIG_PATH lib/cmake/iceoryx2-bb-cxx DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(PACKAGE_NAME iceoryx2-cxx CONFIG_PATH lib/cmake/iceoryx2-cxx)


file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/doc"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE-APACHE" "${SOURCE_PATH}/LICENSE-MIT")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
