vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lief-project/LIEF
    REF 274d887e176aaa404a60cf6eea239f84f191349e # master commit 2022-02-14
    SHA512 5a5a57f4dc36eb4d74dfd4d7a66f4c5a7eb83b6b58202944ead9be86a576c141cd3c54b5b45f7182a4a7710349da16e16b67e7074523c18fedb98ecf8ba43fba
    HEAD_REF master
    PATCHES
        support_distribution.patch
        fix_span_include.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
FEATURES
    "tests"          LIEF_TESTS             # Enable tests
    "doc"            LIEF_DOC               # Enable documentation
    "c-api"          LIEF_C_API             # C API
    "examples"       LIEF_EXAMPLES          # Build LIEF C++ examples
    "force32"        LIEF_FORCE32           # Force build LIEF 32 bits version
    "coverage"       LIEF_COVERAGE          # Perform code coverage
    "use-ccache"     LIEF_USE_CCACHE        # Use ccache to speed up compilation
    "extra-warnings" LIEF_EXTRA_WARNINGS    # Enable extra warning from the compiler
    "logging"        LIEF_LOGGING           # Enable logging
    "logging-debug"  LIEF_LOGGING_DEBUG     # Enable debug logging
    "enable-json"    LIEF_ENABLE_JSON       # Enable JSON-related APIs

    "elf"            LIEF_ELF               # Build LIEF with ELF module
    "pe"             LIEF_PE                # Build LIEF with PE  module
    "macho"          LIEF_MACHO             # Build LIEF with MachO module

    "oat"            LIEF_OAT               # Build LIEF with OAT module
    "dex"            LIEF_DEX               # Build LIEF with DEX module
    "vdex"           LIEF_VDEX              # Build LIEF with VDEX module
    "art"            LIEF_ART               # Build LIEF with ART module

    # Sanitizer
    "asan"          LIEF_ASAN               # Enable Address sanitizer
    "lsan"          LIEF_LSAN               # Enable Leak sanitizer
    "tsan"          LIEF_TSAN               # Enable Thread sanitizer
    "usan"          LIEF_USAN               # Enable undefined sanitizer

    # Fuzzer
    "fuzzing"       LIEF_FUZZING            # Fuzz LIEF

    # Profiling
    "profiling"     LIEF_PROFILING          # Enable performance profiling

    # INVERTED_FEATURES
    # TODO: Not sure how to remove a dependency from list of defaults
    # "disable-frozen" LIEF_DISABLE_FROZEN    # Disable Frozen even if it is supported
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"

    OPTIONS
        ${FEATURE_OPTIONS}

        -DLIEF_PYTHON_API=OFF

        # Build with external vcpkg dependencies
        -DLIEF_OPT_MBEDTLS_EXTERNAL=ON
        -DLIEF_OPT_UTFCPP_EXTERNAL=ON
        -DLIEF_EXTERNAL_SPDLOG=ON
        -DLIEF_OPT_NLOHMANN_JSON_EXTERNAL=ON
        -DLIEF_OPT_FROZEN_EXTERNAL=ON
        -DLIEF_OPT_EXTERNAL_LEAF=ON
        "-DLIEF_EXTERNAL_LEAF_DIR=${CURRENT_INSTALLED_DIR}/include"
        -DLIEF_OPT_EXTERNAL_SPAN=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/LIEF/cmake)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Check if all-caps directory is empty (it won't be on case-insensitive filesystems).
# These files could have been moved during vcpkg_cmake_config_fixup
file(GLOB dir_files "${CURRENT_PACKAGES_DIR}/share/LIEF/*")
list(LENGTH dir_files dir_files_len)
if(dir_files_len EQUAL 0)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/LIEF")
endif()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
