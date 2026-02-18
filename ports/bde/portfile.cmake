vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

# Acquire Python and add it to PATH
vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_EXE_PATH ${PYTHON3} DIRECTORY)

# Acquire BDE Tools and add them to PATH
set (BDE_TOOLS_VER 4.32.0.0)
vcpkg_from_github(
    OUT_SOURCE_PATH TOOLS_PATH
    REPO "bloomberg/bde-tools"
    REF "${BDE_TOOLS_VER}"
    SHA512 26937ac8c3540825ea6e50bc50fc675850498eecd9996d03b3e56771514703ad8f4c62f44ed79502d55fd0cd4d928a4d2cf0c8b6adc279f8327b092da157ac69
    HEAD_REF main
)

message(STATUS "Configure bde-tools-v${BDE_TOOLS_VERSION}")
vcpkg_add_to_path("${PYTHON3_EXE_PATH}")
vcpkg_add_to_path("${TOOLS_PATH}/bin")

# Acquire BDE sources
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "bloomberg/bde"
    REF "${VERSION}"
    SHA512 0228b861395737a5420a69c35c2ecbc1a3425863c5a7478752791cf3eecafd1ad0365497ad15c6f53308c4edafc6b74bb8b498c92a4cc042bd9a9e51363c34c6
    HEAD_REF main
    PATCHES
        bigobj.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -DBDE_BUILD_TARGET_CPP17=ON
        -DCMAKE_CXX_STANDARD=17
        -DCMAKE_CXX_STANDARD_REQUIRED=ON
        -DCMAKE_CXX_EXTENSIONS=OFF
        -DBBS_BUILD_SYSTEM=ON
        -DBDE_USE_EXTERNAL_PCRE2=ON
        "-DBdeBuildSystem_DIR:PATH=${TOOLS_PATH}/BdeBuildSystem"
)

# Build release
vcpkg_cmake_build()

# Install release
vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
list(APPEND SUBPACKAGES "bbryu" "inteldfp" "pcre2" "s_baltst" "bsl" "bdl" "bal")
include(GNUInstallDirs) # needed for CMAKE_INSTALL_LIBDIR
foreach(subpackage IN LISTS SUBPACKAGES)
    vcpkg_cmake_config_fixup(PACKAGE_NAME ${subpackage} CONFIG_PATH /${CMAKE_INSTALL_LIBDIR}/cmake/${subpackage} DO_NOT_DELETE_PARENT_CONFIG_PATH)
endforeach()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/${CMAKE_INSTALL_LIBDIR}/cmake" "${CURRENT_PACKAGES_DIR}/debug/${CMAKE_INSTALL_LIBDIR}/cmake")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
vcpkg_fixup_pkgconfig()
