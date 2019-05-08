include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY ONLY_DYNAMIC_CRT)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO themoos/core-moos
    REF v10.4.0
    SHA512 8a82074bd219bbedbe56c2187afe74a55a252b0654a675c64d1f75e62353b0874e7b405d9f677fadb297e955d11aea50a07e8f5f3546be3c4ddab76fe356a51e
    HEAD_REF master
    PATCHES
        cmake_fix.patch
)

message(STATUS "MOOS VCPKG SOURCE_PATH ${SOURCE_PATH}")
message(STATUS "MOOS INSTALL -DCMAKE_INSTALL_PREFIX=${CURRENT_PACKAGES_DIR}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_SHARED_LIBS=OFF
        -DCMAKE_ENABLE_EXPORT=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/MOOS")

set(MOOS_EXEC_SUFFIX "")
if (WIN32)
    set(MOOS_EXEC_SUFFIX ".exe")
endif()

# Stage tools
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/tools/${PORT})
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin ${CURRENT_PACKAGES_DIR}/debug/include)

# Put the licence file where vcpkg expects it
file(COPY ${SOURCE_PATH}/Core/GPLCore.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)
