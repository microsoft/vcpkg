vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

# Acquire Python and add it to PATH
vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_EXE_PATH ${PYTHON3} DIRECTORY)

# Acquire BDE Tools and add them to PATH
vcpkg_from_github(
    OUT_SOURCE_PATH TOOLS_PATH
    REPO "bloomberg/bde-tools"
    REF "${VERSION}"
    SHA512 e5c5a0639e06a554f0f3ba7d18db8947f84a3645494b6dd5642be4bb9457d65e5d1ad1f047bb2f5fd61553fa10ae93a6a9573e5c799e9baab1b943be1000b7e2
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
    SHA512 f35fdfbae64d8405264420f0e7c983e628adbba1219b3f75ae99c6a58d91bf8bc7f8690b56a891798d3e32620cb9e98ac6234e55d6227caf52d622b0ce05456c
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
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
vcpkg_fixup_pkgconfig()
