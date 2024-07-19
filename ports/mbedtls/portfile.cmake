set(VCPKG_LIBRARY_LINKAGE static)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ARMmbed/mbedtls
    REF "v${VERSION}"
    SHA512 7e50cf2bb2c9abeb56f18a25bc126b96ac5e3329702cf5b2e266df6b649b9544ab5f2ac00bd57e06091e10cdcf907e600c14eb415942d028000d7b6f1c0cfa42
    PATCHES
        enable-pthread.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH FRAMEWORK_SOURCE_PATH
    REPO Mbed-TLS/mbedtls-framework
    REF 750634d3a51eb9d61b59fd5d801546927c946588
    SHA512 b22687ba164502a12bb39f46cde9bc012cd0e1e4493de815f8f43c835d3385b4bb43f423f2991ba8062191b40ce3ea14955e1a6601a9688819cead5861715267
    HEAD_REF main
)

file(REMOVE_RECURSE "${SOURCE_PATH}/framework")
file(RENAME "${FRAMEWORK_SOURCE_PATH}" "${SOURCE_PATH}/framework")

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        pthreads ENABLE_PTHREAD
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        ${FEATURE_OPTIONS}
        -DENABLE_TESTING=OFF
        -DENABLE_PROGRAMS=OFF
        -DMBEDTLS_FATAL_WARNINGS=FALSE
)

vcpkg_cmake_install()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

if (VCPKG_TARGET_IS_WINDOWS AND pthreads IN_LIST FEATURES)
    file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
endif ()

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
