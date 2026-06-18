if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY) # https://github.com/Mbed-TLS/mbedtls/issues/470
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Mbed-TLS/mbedtls
    REF "v${VERSION}"
    SHA512 d7a1e0098fed7b000ac2e4de31d43f427e8a046aeace91719f58222e1289470e15af5ed2a5390cf3693cf93a1efd79f34de9a6a960dc63cc0fd135072809e6e4
    HEAD_REF development
    PATCHES
        enable-pthread.patch
)
file(WRITE "${SOURCE_PATH}/framework/CMakeLists.txt" "# empty placeholder")

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        pthreads    LINK_WITH_PTHREAD
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" USE_SHARED_MBEDTLS_LIBRARY)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" USE_STATIC_MBEDTLS_LIBRARY)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DENABLE_TESTING=OFF
        -DENABLE_PROGRAMS=OFF
        -DMBEDTLS_FATAL_WARNINGS=FALSE
        -DUSE_SHARED_MBEDTLS_LIBRARY=${USE_SHARED_MBEDTLS_LIBRARY}
        -DUSE_STATIC_MBEDTLS_LIBRARY=${USE_STATIC_MBEDTLS_LIBRARY}
    OPTIONS_DEBUG
        -DINSTALL_MBEDTLS_HEADERS=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/MbedTLS")

if(LINK_WITH_PTHREAD)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/mbedtls/mbedtls_config.h" "#ifdef LINK_WITH_PTHREAD" "#if 1")
    file(COPY "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
endif()

file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
