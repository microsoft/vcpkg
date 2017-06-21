
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libsndfile-c3688284765cdf4eb2d6b5f1c34c883ca690440f)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/erikd/libsndfile/archive/c3688284765cdf4eb2d6b5f1c34c883ca690440f.zip"
    FILENAME "libsndfile-1.0.29-c3688284.zip"
    SHA512 c42c32f542ad256cfe2e85e7b908118ec20a582ade38b6b04da07c27e76bab9c4328e0b31e287bf632afef5be38785f1e9ac065289661cf20843455fab7c75fa
)
vcpkg_extract_source_archive(${ARCHIVE})

# Generate usable pkg-config.pc
vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/pkgconfig_cmake.patch"
)

if (VCPKG_CRT_LINKAGE STREQUAL "dynamic")
    set(CRT_LIB_STATIC 0)
elseif (VCPKG_CRT_LINKAGE STREQUAL "static")
    set(CRT_LIB_STATIC 1)
endif()

if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(BUILD_STATIC 1)
    set(BUILD_DYNAMIC 0)
elseif (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(BUILD_STATIC 0)
    set(BUILD_DYNAMIC 1)
endif()

option(BUILD_EXECUTABLES "Build sndfile tools and install to folder tools" OFF)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_PROGRAMS=${BUILD_EXECUTABLES}
        -DBUILD_EXAMPLES=0
        -DBUILD_REGTEST=0
        -DBUILD_TESTING=0
        -DENABLE_STATIC_RUNTIME=${CRT_LIB_STATIC}
        -DBUILD_STATIC_LIBS=${BUILD_STATIC}
        -DBUILD_SHARED_LIBS=${BUILD_DYNAMIC}
        -DENABLE_PACKAGE_CONFIG=1

    # Avoid building tools in debug-build:
    OPTIONS_DEBUG
        -DBUILD_PROGRAMS=0
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(COPY ${CURRENT_PACKAGES_DIR}/debug/cmake/LibSndFileTargets-debug.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/cmake)
file(COPY ${CURRENT_PACKAGES_DIR}/share/doc/libsndfile DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(RENAME ${CURRENT_PACKAGES_DIR}/share/${PORT}/libsndfile ${CURRENT_PACKAGES_DIR}/share/${PORT}/doc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/doc)
file(COPY ${CURRENT_PACKAGES_DIR}/cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/cmake )

if(BUILD_EXECUTABLES)
    file(GLOB TOOLS ${CURRENT_PACKAGES_DIR}/bin/*.exe)
    file(COPY ${TOOLS} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})
    file(REMOVE ${TOOLS})
endif(BUILD_EXECUTABLES)

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(RENAME ${CURRENT_PACKAGES_DIR}/share/${PORT}/COPYING ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)
