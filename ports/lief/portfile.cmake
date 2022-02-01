vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lief-project/LIEF
    REF 12c5bf4489a40ee0ca3f1debec4b476ac8c64c37 # master commit 1/31/22
    SHA512 b49a1502f24a493a120592834819153c84d014c687ed324d6cb0394974e50e892bea3f8c1844e7f5332ff32dd98d3b08d006d44b92c9c3a02fb2631239e666b7
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
FEATURES
    "tests"          LIEF_TESTS             # Enable tests
    "doc"            LIEF_DOC               # Enable documentation
    "python-api"     LIEF_PYTHON_API        # Enable Python API
    "install-python" LIEF_INSTALL_PYTHON    # Install Python bindings
    "c-api"          LIEF_C_API             # C API
    "examples"       LIEF_EXAMPLES          # Build LIEF C++ examples
    "force32"        LIEF_FORCE32           # Force build LIEF 32 bits version
    "coverage"       LIEF_COVERAGE          # Perform code coverage
    "use-ccache"     LIEF_USE_CCACHE        # Use ccache to speed up compilation
    "extra-warnings" LIEF_EXTRA_WARNINGS    # Enable extra warning from the compiler
    "logging"        LIEF_LOGGING           # Enable logging
    "logging-debug"  LIEF_LOGGING_DEBUG     # Enable debug logging
    "enable-json"    LIEF_ENABLE_JSON       # Enable JSON-related APIs

    # "disable_frozen" LIEF_DISABLE_FROZEN    # Disable Frozen even if it is supported

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

INVERTED_FEATURES
    "disable-frozen" LIEF_DISABLE_FROZEN    # Disable Frozen even if it is supported
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"

    OPTIONS
        ${FEATURE_OPTIONS}
        -DLIEF_OPT_MBEDTLS_EXTERNAL=ON
        -DLIEF_OPT_UTFCPP_EXTERNAL=ON
        -DLIEF_EXTERNAL_SPDLOG=ON
        -DLIEF_OPT_NLOHMANN_JSON_EXTERNAL=ON
        # TODO:
        # -DLIEF_EXTERNAL_LEAF=ON
        # -DLIEF_EXTERNAL_LEAF_DIR=<path to boost leaf include>
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

# # Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/lief" RENAME copyright)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
