vcpkg_check_linkage(ONLY_STATIC_LIBRARY)


# Acquire Python and add it to PATH
vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_EXE_PATH ${PYTHON3} DIRECTORY)

# Acquire BDE Tools and add them to PATH
vcpkg_from_github(
    OUT_SOURCE_PATH TOOLS_PATH
    REPO "bloomberg/bde-tools"
    REF "${VERSION}"
    SHA512 3aa64215c473ccecbd213234826b0c8cffd9491e7bf358e5947c80103e0723ef56da8ec7cc9cf51c6b7a887e5b0b52e80f3201d933accf7f6d5cc95fc1cb35dc
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
    SHA512 27e204e22883065e3ae9ab92d2c87d8e26a2871a36ede01367ee0e4d4a0e0de4f7b9452a0c219066dbb37a6f06ec3acabd6be029b8fdaab6c6ea4094300371d0
    HEAD_REF main
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
