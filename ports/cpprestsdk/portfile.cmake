vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/cpprestsdk
    REF 41e7d0074b6cb5b22c89f835b4531d848ab66987
    SHA512 29ad2cf9884cd9df9b4c92b89a852d207c5e210af59e773333e122aa58a4981b52b1e6186c121430295bd4eb0ca1abc002e29177a6753cd62dcd8937a3244e0c
    HEAD_REF master
    PATCHES fix-find-openssl.patch
)

set(OPTIONS)
if(NOT VCPKG_TARGET_IS_UWP)
    SET(WEBSOCKETPP_PATH "${CURRENT_INSTALLED_DIR}/share/websocketpp")
    list(APPEND OPTIONS
        -DWEBSOCKETPP_CONFIG=${WEBSOCKETPP_PATH}
        -DWEBSOCKETPP_CONFIG_VERSION=${WEBSOCKETPP_PATH})
endif()

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
      brotli CPPREST_EXCLUDE_BROTLI
      compression CPPREST_EXCLUDE_COMPRESSION
      websockets CPPREST_EXCLUDE_WEBSOCKETS
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/Release
    PREFER_NINJA
    OPTIONS
        ${OPTIONS}
        ${FEATURE_OPTIONS}
        -DBUILD_TESTS=OFF
        -DBUILD_SAMPLES=OFF
        -DCPPREST_EXPORT_DIR=share/cpprestsdk
        -DWERROR=OFF
        -DPKG_CONFIG_EXECUTABLE=FALSE
    OPTIONS_DEBUG
        -DCPPREST_INSTALL_HEADERS=OFF
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/share/${PORT})
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/share ${CURRENT_PACKAGES_DIR}/lib/share)

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/cpprest/details/cpprest_compat.h
        "#ifdef _NO_ASYNCRTIMP" "#if 1")
endif()

file(INSTALL ${SOURCE_PATH}/license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
