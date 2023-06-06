vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO irrlicht/Irrlicht%20SDK
    REF 1.8/${VERSION}
    FILENAME "irrlicht-${VERSION}.zip"
    SHA512 d11c7a056bfb8c9737ed583c5bc5794223bc59fb4620411b63bc4d1eedc41db2ed1cab5cb7a37fee42a7f38c0e0645f5fc53fd329fff0f2aa78e0df6804c47c9
    PATCHES
        fix-encoding.patch
        fix-osx-compilation.patch
)

if(VCPKG_TARGET_IS_LINUX)
    message(
"Irrlicht currently requires the following libraries from the system package manager:
    libgl1-mesa
    xf86vmode

These can be installed on Ubuntu systems via sudo apt-get install libgl1-mesa-dev libxxf86vm-dev")
endif()

configure_file("${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" "${SOURCE_PATH}/CMakeLists.txt" COPYONLY)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        unicode     IRR_UNICODE_PATH
        fast-fpu    IRR_FAST_MATH
        tools       IRR_BUILD_TOOLS
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" SHARED_LIB)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DIRR_SHARED_LIB=${SHARED_LIB}
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/irrlicht/")
endif()

file(WRITE "${CURRENT_PACKAGES_DIR}/share/irrlicht/irrlicht-config.cmake" "include(\${CMAKE_CURRENT_LIST_DIR}/irrlicht-targets.cmake)")

vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(COPY "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/irrlicht")
endif()

vcpkg_install_copyright(FILE_LIST "${CMAKE_CURRENT_LIST_DIR}/LICENSE.txt")
