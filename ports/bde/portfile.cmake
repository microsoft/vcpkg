vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

# Acquire Python and add it to PATH
vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_EXE_PATH ${PYTHON3} DIRECTORY)

# Acquire BDE Tools and add them to PATH
set (BDE_TOOLS_VER "${VERSION}")
vcpkg_from_github(
    OUT_SOURCE_PATH TOOLS_PATH
    REPO "bloomberg/bde-tools"
    REF "${BDE_TOOLS_VER}"
    SHA512 3d15bb0aff27facd167e243a5c5c77c33e1c27e340c84e7deb870c98525a1e653f8d25b82ea7d89c703b87c82b61bc39a94da406b94654d211739618a89d8293
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
    SHA512 d895d11de518eb67805baaa50ef08d2c8c872375a23134c55dd9db8c790436143823ac8dd5707e1cce583f23a5e455fe9f13d7907d92cc2e86b85c3f3d0a5309
    HEAD_REF main
    PATCHES
        fix-bdlar-target.patch
        use-vcpkg-pcre2.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -DBDE_BUILD_TARGET_CPP17=ON
        -DCMAKE_CXX_STANDARD=17
        -DCMAKE_CXX_STANDARD_REQUIRED=ON
        -DCMAKE_CXX_EXTENSIONS=OFF
        -DBBS_BUILD_SYSTEM=1
        -DBDE_USE_EXTERNAL_PCRE2=1
        "-DBdeBuildSystem_DIR:PATH=${TOOLS_PATH}/BdeBuildSystem"
)

# Build release
vcpkg_cmake_build()

# Install release
vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
list(APPEND SUBPACKAGES "inteldfp" "s_baltst" "bsl" "bbryu" "bdl" "bbl" "bal")
include(GNUInstallDirs) # needed for CMAKE_INSTALL_LIBDIR
foreach(subpackage IN LISTS SUBPACKAGES)
    vcpkg_cmake_config_fixup(PACKAGE_NAME "${subpackage}" CONFIG_PATH "/${CMAKE_INSTALL_LIBDIR}/cmake/${subpackage}" DO_NOT_DELETE_PARENT_CONFIG_PATH)
endforeach()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/${CMAKE_INSTALL_LIBDIR}/cmake" "${CURRENT_PACKAGES_DIR}/debug/${CMAKE_INSTALL_LIBDIR}/cmake")

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE"
        "${SOURCE_PATH}/thirdparty/bbryu/LICENSE-Boost"
        "${SOURCE_PATH}/thirdparty/inteldfp/eula.txt"
)
vcpkg_fixup_pkgconfig()
