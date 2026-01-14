# vcpkg portfile for iccdev (RefIccMAX)
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO InternationalColorConsortium/iccdev
  REF "v${VERSION}"
  SHA512 835ed762c3936e9a9e0d30c7f0cbfbff7d598431da660606609912b126df64c3c43c4daa59736aaf1191341a333a637954308515e0548280ae67f71e71970518
  HEAD_REF main
  PATCHES
    patches/001-link-liblzma.patch
    patches/003-fix-static-only-build.patch
)

# Disable IccDEVCmm which has PCH issues and is not needed for vcpkg
vcpkg_replace_string("${SOURCE_PATH}/Build/Cmake/CMakeLists.txt"
  "    message(STATUS \"Adding Subdirectory IccDEVCmm.\")\n    ADD_SUBDIRECTORY(Tools/IccDEVCmm)"
  "    # message(STATUS \"Adding Subdirectory IccDEVCmm.\")\n    # ADD_SUBDIRECTORY(Tools/IccDEVCmm)"
)

# Apply CMakeLists.txt fixes for MSVC static library builds (avoiding patch CRLF issues)
if(VCPKG_TARGET_IS_WINDOWS)
  # Fix main CMakeLists.txt to use correct library target names based on build type
  vcpkg_replace_string("${SOURCE_PATH}/Build/Cmake/CMakeLists.txt"
    "# Set default link target for IccProfLib\n# Use CACHE INTERNAL so that it's available in Tools/* subdirectories\nset(TARGET_LIB_ICCPROFLIB IccProfLib2 CACHE INTERNAL \"Link target for IccProfLib2\")"
    "# Set default link target for IccProfLib\n# Use CACHE INTERNAL so that it's available in Tools/* subdirectories\nif(ENABLE_SHARED_LIBS)\n  set(TARGET_LIB_ICCPROFLIB IccProfLib2 CACHE INTERNAL \"Link target for IccProfLib2\")\nelse()\n  set(TARGET_LIB_ICCPROFLIB IccProfLib2-static CACHE INTERNAL \"Link target for IccProfLib2\")\nendif()"
  )
  
  # Fix IccProfLib static library - add DEBUG_POSTFIX for proper debug/release builds
  vcpkg_replace_string("${SOURCE_PATH}/Build/Cmake/IccProfLib/CMakeLists.txt"
    "  ADD_LIBRARY(\${TARGET_NAME}-static STATIC \${SOURCES})\n  SET_TARGET_PROPERTIES(\${TARGET_NAME}-static PROPERTIES OUTPUT_NAME \"\${TARGET_NAME}-static\")"
    "  ADD_LIBRARY(\${TARGET_NAME}-static STATIC \${SOURCES})\n  SET_TARGET_PROPERTIES(\${TARGET_NAME}-static PROPERTIES \n    OUTPUT_NAME \"\${TARGET_NAME}-static\"\n    DEBUG_POSTFIX \"d\"\n    RELWITHDEBINFO_POSTFIX \"d\")"
  )
  
  # Fix IccXML static library - add DEBUG_POSTFIX for proper debug/release builds
  vcpkg_replace_string("${SOURCE_PATH}/Build/Cmake/IccXML/CMakeLists.txt"
    "  ADD_LIBRARY(\${TARGET_NAME}-static STATIC \${SOURCES})\n  SET_TARGET_PROPERTIES(\${TARGET_NAME}-static PROPERTIES OUTPUT_NAME \"\${TARGET_NAME}-static\")"
    "  ADD_LIBRARY(\${TARGET_NAME}-static STATIC \${SOURCES})\n  SET_TARGET_PROPERTIES(\${TARGET_NAME}-static PROPERTIES \n    OUTPUT_NAME \"\${TARGET_NAME}-static\"\n    DEBUG_POSTFIX \"d\"\n    RELWITHDEBINFO_POSTFIX \"d\")"
  )
  
  # Fix tools that hardcode library names instead of using TARGET_LIB variables
  vcpkg_replace_string("${SOURCE_PATH}/Build/Cmake/Tools/IccApplyNamedCmm/CMakeLists.txt"
    "  target_link_libraries(iccApplyNamedCmm PRIVATE\n    \${TARGET_LIB_ICCPROFLIB}\n    IccXML2\n    nlohmann_json::nlohmann_json\n  )"
    "  target_link_libraries(iccApplyNamedCmm PRIVATE\n    \${TARGET_LIB_ICCPROFLIB}\n    \${TARGET_LIB_ICCXML}\n    nlohmann_json::nlohmann_json\n  )"
  )
  vcpkg_replace_string("${SOURCE_PATH}/Build/Cmake/Tools/IccApplySearch/CMakeLists.txt"
    "target_link_libraries(iccApplySearch PRIVATE\n  IccProfLib2\n  IccXML2\n  nlohmann_json::nlohmann_json\n)"
    "target_link_libraries(iccApplySearch PRIVATE\n  \${TARGET_LIB_ICCPROFLIB}\n  \${TARGET_LIB_ICCXML}\n  nlohmann_json::nlohmann_json\n)"
  )
endif()

# Feature: tools (optional command-line utilities)
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    tools ENABLE_TOOLS
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}/Build/Cmake"
  OPTIONS
    ${FEATURE_OPTIONS}
    -DENABLE_INSTALL_RIM=ON
    -DENABLE_SHARED_LIBS=ON
    -DENABLE_STATIC_LIBS=ON
    -DENABLE_ICCXML=ON
    -DUSE_SYSTEM_LIBXML2=ON
    -DENABLE_TESTS=OFF
  OPTIONS_DEBUG
    -DCMAKE_DEBUG_POSTFIX=d
)

vcpkg_cmake_build()

vcpkg_cmake_install()

# Copy tools to the tools directory if tools feature is enabled
if("tools" IN_LIST FEATURES)
  vcpkg_copy_tools(
    TOOL_NAMES
      iccFromXml
      iccToXml
      iccJpegDump
      iccApplyNamedCmm
      iccDumpProfile
      iccRoundTrip
      iccFromCube
      iccV5DspObsToV4Dsp
      iccApplyToLink
      iccPngDump
      iccApplyProfiles
      iccSpecSepToTiff
      iccTiffDump
      iccDumpProfileGui
    AUTO_CLEAN
  )
endif()

# Move cmake config files to standard location
# Project installs to lib/cmake/reficcmax (PROJECT_DOWN_NAME)
vcpkg_cmake_config_fixup(
  PACKAGE_NAME RefIccMAX
  CONFIG_PATH lib/cmake/reficcmax
)

# Remove duplicate headers from debug
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Remove duplicate share from debug
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Remove debug binaries (tools are not needed in debug)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")

# Generate usage file
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
