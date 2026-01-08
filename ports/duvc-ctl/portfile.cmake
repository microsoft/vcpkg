vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO allanhanan/duvc-ctl
    REF "v${VERSION}"
    SHA512 5cc63ef7c3a46fb351015ae2b1b96837ea46dbb7656ab1cf633af6027d32ae447dfc60a8757677eae07dabfb3ec1aca90f7019a6d7b5344c66324d39e9f0c464
    HEAD_REF main
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(DUVC_BUILD_SHARED ON)
    set(DUVC_BUILD_STATIC OFF)
else()
    set(DUVC_BUILD_SHARED OFF)
    set(DUVC_BUILD_STATIC ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DDUVC_BUILD_SHARED=${DUVC_BUILD_SHARED}
        -DDUVC_BUILD_STATIC=${DUVC_BUILD_STATIC}
        -DDUVC_BUILD_C_API=OFF
        -DDUVC_BUILD_CLI=OFF
        -DDUVC_BUILD_TESTS=OFF
        -DDUVC_BUILD_EXAMPLES=OFF
        -DDUVC_BUILD_PYTHON=OFF
        -DDUVC_BUILD_DOCS=OFF
        -DDUVC_INSTALL=ON
        -DDUVC_INSTALL_CMAKE_CONFIG=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/duvc-ctl")
vcpkg_fixup_pkgconfig()


vcpkg_copy_pdbs()

if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/include")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/share")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
endif()

file(INSTALL "${SOURCE_PATH}/LICENSE"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")