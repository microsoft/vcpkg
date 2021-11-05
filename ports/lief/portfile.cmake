vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lief-project/LIEF
    REF 551ede538abeca63a158bd7c42b6b6337c92a26e # v0.11.5
    SHA512 2f98e6e63dd79300f43c39eb4c032dbe72402140cc12061c38d8df3b0f40166f22f8e41f37112255b019f2478c164e89e384b6826dd7b6cc0b9cdb6de407c564
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
    "shared-lib"     LIEF_SHARED_LIB        # Enable shared lib

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

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja

    OPTIONS 
        # -DCMAKE_TOOLCHAIN_FILE="${VCPKG_ROOT_DIR}\\scripts\\buildsystems\\vcpkg.cmake"
        ${FEATURE_OPTIONS}
    OPTIONS_DEBUG    
        # -DCMAKE_DEBUG_POSTFIX=d
        # -DLIEF_USE_CRT_DEBUG=MTd
        -DLIEF_USE_CRT_DEBUG=MDd

    OPTIONS_RELEASE
        # -DLIEF_USE_CRT_RELEASE=MT
        -DLIEF_USE_CRT_RELEASE=MD
)

vcpkg_install_cmake()

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    if(VCPKG_TARGET_IS_WINDOWS)
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
            if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/LIEF.dll")
                file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/bin")
                file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/LIEF.dll" "${CURRENT_PACKAGES_DIR}/debug/bin/LIEF.dll")
            endif()
        endif()
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
            if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/LIEF.dll")
                file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/bin")
                file(RENAME "${CURRENT_PACKAGES_DIR}/lib/LIEF.dll" "${CURRENT_PACKAGES_DIR}/bin/LIEF.dll")
            endif()
        endif()
    endif()
endif()

vcpkg_copy_pdbs()

# # Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/LIEF RENAME copyright)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

message(STATUS "[LIEF DEBUG] Installing done")