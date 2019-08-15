include(vcpkg_common_functions)

# Update to latest LibRaw-201903 snapshot at d4f05dd1b9b2d44c8f7e82043cbad3c724db2416
# LibRaw publishes:
# - snapshots every 5-7 months (in master branch)
# - releases (0.18, 0.19, etc.) every 1-1.5 years.
# - security hotfixes for releases (0.19.1, 0.19.2, etc.)
# Hence, from user point of view, it is practical to refer to the latest snapshot,
# instead of the latest release.
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LibRaw/LibRaw
    REF d4f05dd1b9b2d44c8f7e82043cbad3c724db2416
    SHA512 5794521f535163afd7815ad005295301c5e0e2f8b2f34ef0a911d9dd1572c1f456b292777548203f9767957a55782b5bc9041c033190d25d1e9b4240d7df32b9
    HEAD_REF master
)

set(LIBRAW_CMAKE_COMMIT "a71f3b83ee3dccd7be32f9a2f410df4d9bdbde0a")
set(LIBRAW_CMAKE_SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/LibRaw-cmake-${LIBRAW_CMAKE_COMMIT})
vcpkg_download_distfile(CMAKE_BUILD_ARCHIVE
    URLS "https://github.com/LibRaw/LibRaw-cmake/archive/${LIBRAW_CMAKE_COMMIT}.zip"
    FILENAME "LibRaw-cmake-${LIBRAW_CMAKE_COMMIT}"
    SHA512 54216e6760e2339dc3bf4b4be533a13160047cabfc033a06da31f2226c43fc93eaea9672af83589e346ce9231c1a57910ac5e800759e692fe2cd9d53b7fba0c6
)

vcpkg_extract_source_archive(${CMAKE_BUILD_ARCHIVE} ${CURRENT_BUILDTREES_DIR}/src)

# Copy the CMake build system from the external repo
file(COPY ${LIBRAW_CMAKE_SOURCE_PATH}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${LIBRAW_CMAKE_SOURCE_PATH}/cmake DESTINATION ${SOURCE_PATH})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/findlibraw_debug_fix.patch
        ${CMAKE_CURRENT_LIST_DIR}/lcms2_debug_fix.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DINSTALL_CMAKE_MODULE_PATH=${CURRENT_PACKAGES_DIR}/share/libraw
        -DCMAKE_DEBUG_POSTFIX=d
)

vcpkg_install_cmake()

file(READ ${CURRENT_PACKAGES_DIR}/include/libraw/libraw_types.h LIBRAW_H)
if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    string(REPLACE "#ifdef LIBRAW_NODLL" "#if 1" LIBRAW_H "${LIBRAW_H}")
else()
    string(REPLACE "#ifdef LIBRAW_NODLL" "#if 0" LIBRAW_H "${LIBRAW_H}")
endif()
file(WRITE ${CURRENT_PACKAGES_DIR}/include/libraw/libraw_types.h "${LIBRAW_H}")

if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    # Rename thread-safe version to be "raw.lib". This is unfortunately needed
    # because otherwise libraries that build on top of libraw have to choose.
    file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/raw.lib ${CURRENT_PACKAGES_DIR}/debug/lib/rawd.lib)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/raw_r.lib ${CURRENT_PACKAGES_DIR}/lib/raw.lib)
    if(NOT VCPKG_BUILD_TYPE STREQUAL "release")
        file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/raw_rd.lib ${CURRENT_PACKAGES_DIR}/debug/lib/rawd.lib)
    endif()

    # Cleanup
    file(GLOB RELEASE_EXECUTABLES ${CURRENT_PACKAGES_DIR}/bin/*.exe)
    file(REMOVE ${RELEASE_EXECUTABLES})
    if(NOT VCPKG_BUILD_TYPE STREQUAL "release")
        file(GLOB DEBUG_EXECUTABLES ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe)
        file(REMOVE ${DEBUG_EXECUTABLES})
    endif()
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
else()
    if(VCPKG_CMAKE_SYSTEM_NAME AND NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
        file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/raw.dll ${CURRENT_PACKAGES_DIR}/debug/bin/rawd.dll)
    endif()
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Rename cmake module into a config in order to allow more flexible lookup rules
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libraw/FindLibRaw.cmake ${CURRENT_PACKAGES_DIR}/share/libraw/LibRaw-config.cmake)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(COPY ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/libraw)
endif()

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/libraw)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libraw/COPYRIGHT ${CURRENT_PACKAGES_DIR}/share/libraw/copyright)

vcpkg_copy_pdbs()
