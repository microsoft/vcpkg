vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

set(BDE_VERSION 3.117.0.0)
set(BDE_TOOLS_VERSION 3.117.0.0)

# Paths used in build
set(SOURCE_PATH_DEBUG ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/bde-${BDE_VERSION})
set(SOURCE_PATH_RELEASE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bde-${BDE_VERSION})

# Acquire Python and add it to PATH
vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_EXE_PATH ${PYTHON3} DIRECTORY)

# Acquire BDE Tools and add them to PATH
vcpkg_from_github(
    OUT_SOURCE_PATH TOOLS_PATH
    REPO "bloomberg/bde-tools"
    REF 3.117.0.0
    SHA512 3c39da8d1ea40459e36e11ada93cc2821ae1b16a831f93cccab463996394a400cc08bb1654642eae1aa5187f139d7fb80c4729e464051eee182133eb8a74158d
    HEAD_REF 3.117.0.0
)

message(STATUS "Configure bde-tools-v${BDE_TOOLS_VERSION}")
if(VCPKG_CMAKE_SYSTEM_NAME)
    set(ENV{PATH} "$ENV{PATH}:${PYTHON3_EXE_PATH}")
    set(ENV{PATH} "$ENV{PATH}:${TOOLS_PATH}/bin")
else()
    set(ENV{PATH} "$ENV{PATH};${PYTHON3_EXE_PATH}")
    set(ENV{PATH} "$ENV{PATH};${TOOLS_PATH}/bin")
endif()

# Acquire BDE sources
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "bloomberg/bde"
    REF 3.117.0.0
    SHA512 810b4a06a08739dcd990751dd543aa7dc58355f9d64a7c96ef0cf45c81501946434db42ad5bcf5d16110d5a463586b587ce09a446136e824298f39a8a871b490
    HEAD_REF 3.117.0.0
)

# Clean up previous builds
file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
                    ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    cxx17 BDE_USE_CXX17
)

if (BDE_USE_CXX17)
    set(BDE_OPTIONS "-DBDE_BUILD_TARGET_CPP17=ON" "-DCMAKE_CXX_STANDARD=17" "-DCMAKE_CXX_STANDARD_REQUIRED=ON" "-DCMAKE_CXX_EXTENSIONS=OFF")
endif ()

# Configure release
if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    list(APPEND BDE_OPTIONS "-DBDE_BUILD_TARGET_OPT=1")
else()
    list(APPEND BDE_OPTIONS "-DBDE_BUILD_TARGET_DBG=1")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    WINDOWS_USE_MSBUILD
    OPTIONS 
    ${BDE_OPTIONS}
    -DBBS_BUILD_SYSTEM=1
    -DBdeBuildSystem_DIR:PATH=${TOOLS_PATH}/BdeBuildSystem
)

# Build release
vcpkg_cmake_build()

# Install release
vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE
     DESTINATION ${CURRENT_PACKAGES_DIR}/share/bde
     RENAME copyright
)

vcpkg_fixup_pkgconfig()
