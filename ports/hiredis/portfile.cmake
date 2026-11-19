vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO redis/hiredis
    REF "v${VERSION}"
    SHA512 3322b676c7edcfa8c0cef4389b380f86a8870824bb13ccc068ef887fceb9b9f33c767ce5e1b957862126a12ea93c652d4c12e9170ca3e59d25740a5f428c753f
    HEAD_REF master
    PATCHES
        fix-timeval.patch
        support-static.patch
        fix-cmake-conf-install-dir.patch
        fix-ssl-cmake-dependency.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        ssl     ENABLE_SSL
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DDISABLE_TESTS=ON
        -DBUILD_SHARED_LIBS=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

if("ssl" IN_LIST FEATURES)
    vcpkg_replace_string(
        "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/hiredis_ssl.pc"
        "Libs.private: -lssl -lcrypto"
        "Requires.private: openssl"
    )
    if(NOT VCPKG_BUILD_TYPE)
        vcpkg_replace_string(
            "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/hiredis_ssl.pc"
            "Libs.private: -lssl -lcrypto"
            "Requires.private: openssl"
        )
    endif()
endif()

vcpkg_fixup_pkgconfig()

if(NOT VCPKG_BUILD_TYPE)
    vcpkg_replace_string(
        "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/hiredis.pc"
        " -lhiredis"
        " -lhiredisd"
    )
    if("ssl" IN_LIST FEATURES)
        vcpkg_replace_string(
            "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/hiredis_ssl.pc"
            " -lhiredis_ssl"
            " -lhiredis_ssld"
        )
    endif()
endif()
if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(APPEND
        "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/hiredis.pc"
        "Libs.private: -lws2_32 -lcrypt32\n"
    )

    if(NOT VCPKG_BUILD_TYPE)
        file(APPEND
            "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/hiredis.pc"
            "Libs.private: -lws2_32 -lcrypt32\n"
        )
    endif()
endif()

vcpkg_cmake_config_fixup()
if("ssl" IN_LIST FEATURES)
    vcpkg_cmake_config_fixup(PACKAGE_NAME hiredis_ssl CONFIG_PATH share/hiredis_ssl)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/COPYING"
        "${SOURCE_PATH}/ffc.h"
)
