vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

set(BDE_TOOLS_VERSION "${VERSION}")

# Acquire Python and add it to PATH
vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_EXE_PATH ${PYTHON3} DIRECTORY)

# Acquire BDE Tools and add them to PATH
vcpkg_from_github(
    OUT_SOURCE_PATH TOOLS_PATH
    REPO "bloomberg/bde-tools"
    REF "${BDE_TOOLS_VERSION}"
    SHA512 e59560810acfe562d85a13585d908decce17ec76c89bd61f43dac56cddfdf6c56269566da75730f8eda14b5fc046d2ebce959b24110a428e8eac0e358d2597c2
    HEAD_REF 3.123.0.0
)

message(STATUS "Configure bde-tools-v${BDE_TOOLS_VERSION}")
vcpkg_add_to_path("${PYTHON3_EXE_PATH}")
vcpkg_add_to_path("${TOOLS_PATH}/bin")

# Acquire BDE sources
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "bloomberg/bde"
    REF "${VERSION}"
    SHA512 f1c3c5ddec7ff1d301ca6f8ab00e6be42ab6a5fa3c889639e7797df74f68425d57d8b71978098331c9247820c7c831edeaf4427ae64c890d81f704343b1bb112
    HEAD_REF 3.123.0.0
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -DBDE_BUILD_TARGET_CPP17=ON
        -DCMAKE_CXX_STANDARD=17
        -DCMAKE_CXX_STANDARD_REQUIRED=ON
        -DCMAKE_CXX_EXTENSIONS=OFF
        -DBBS_BUILD_SYSTEM=1
        "-DBdeBuildSystem_DIR:PATH=${TOOLS_PATH}/BdeBuildSystem"
    OPTIONS_RELEASE
        -DBDE_BUILD_TARGET_OPT=1
    OPTIONS_DEBUG
        -DBDE_BUILD_TARGET_DBG=1
)

# Build release
vcpkg_cmake_build()

# Install release
vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
list(APPEND SUBPACKAGES "ryu" "inteldfp" "pcre2" "s_baltst" "bsl" "bdl" "bal")
include(GNUInstallDirs) # needed for CMAKE_INSTALL_LIBDIR
foreach(subpackage IN LISTS SUBPACKAGES)
    vcpkg_cmake_config_fixup(PACKAGE_NAME ${subpackage} CONFIG_PATH /${CMAKE_INSTALL_LIBDIR}/cmake/${subpackage} DO_NOT_DELETE_PARENT_CONFIG_PATH)
endforeach()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/${CMAKE_INSTALL_LIBDIR}/cmake" "${CURRENT_PACKAGES_DIR}/debug/${CMAKE_INSTALL_LIBDIR}/cmake")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE
     DESTINATION ${CURRENT_PACKAGES_DIR}/share/bde
     RENAME copyright
)
vcpkg_fixup_pkgconfig()
