vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lief-project/LIEF
    REF ${VERSION}
    SHA512 d9e51724249d720d76cf67b99d1f80d722e6bbef57ebf3cf4bf976e18901cd1bfe689db1eca615657cfea7727bb685ff7b3eebb1879a6174ed0ddfb89bfe2a8e
    HEAD_REF master
    PATCHES
        fix-cmakelists.patch
        fix-liefconfig-cmake-in.patch
        fix-vcpkg-includes.patch
)

file(REMOVE_RECURSE "${SOURCE_PATH}/third-party")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "c-api"          LIEF_C_API             # C API
        "enable-json"    LIEF_ENABLE_JSON       # Enable JSON-related APIs
        "extra-warnings" LIEF_EXTRA_WARNINGS    # Enable extra warning from the compiler
        "logging"        LIEF_LOGGING           # Enable logging
        "logging-debug"  LIEF_LOGGING_DEBUG     # Enable debug logging

        "use-ccache"     LIEF_USE_CCACHE        # Use ccache to speed up compilation

        "oat"            LIEF_OAT               # Build LIEF with OAT module
        "dex"            LIEF_DEX               # Build LIEF with DEX module
        "vdex"           LIEF_VDEX              # Build LIEF with VDEX module
        "art"            LIEF_ART               # Build LIEF with ART module
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DLIEF_EXAMPLES=OFF

        # Build with external vcpkg dependencies
        -DLIEF_OPT_MBEDTLS_EXTERNAL=ON
        -DLIEF_EXTERNAL_SPDLOG=ON
        -DLIEF_OPT_NLOHMANN_JSON_EXTERNAL=ON
        -DLIEF_OPT_FROZEN_EXTERNAL=ON
        -DLIEF_OPT_EXTERNAL_SPAN=ON
        -DLIEF_OPT_UTFCPP_EXTERNAL=ON
        -DLIEF_OPT_EXTERNAL_EXPECTED=ON
        -DLIEF_DISABLE_FROZEN=OFF
        -DLIEF_DISABLE_EXCEPTIONS=OFF

        # https://github.com/lief-project/LIEF/blob/0.16.6/src/paging.cpp requires ELF/PE/MACHO in any case
        -DLIEF_ELF=ON
        -DLIEF_PE=ON
        -DLIEF_MACHO=ON

        "-DLIEF_EXTERNAL_SPAN_DIR=${_VCPKG_INSTALLED_DIR}/${TARGET_TRIPLET}/include/tcb"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/LIEF")

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/lief/LIEFConfig.cmake"
    [[include("${LIEF_${lib_type}_export}")]]
    [[include("${CMAKE_CURRENT_LIST_DIR}/LIEFExport-${lib_type}.cmake")]]
)

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
