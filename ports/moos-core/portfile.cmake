include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO themoos/core-moos
    REF v10.4.0
    SHA512 8a82074bd219bbedbe56c2187afe74a55a252b0654a675c64d1f75e62353b0874e7b405d9f677fadb297e955d11aea50a07e8f5f3546be3c4ddab76fe356a51e 
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/cmake_fix.patch
)


string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

message(STATUS "MOOS VCPKG SOURCE_PATH ${SOURCE_PATH}")
message(STATUS "MOOS INSTALL -DCMAKE_INSTALL_PREFIX=${CURRENT_PACKAGES_DIR}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_SHARED_LIBS=${BUILD_SHARED}
        -DCMAKE_ENABLE_EXPORT=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/MOOS")

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/MOOS)
if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/MOOSDB")
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/MOOSDB ${CURRENT_PACKAGES_DIR}/tools/MOOS/MOOSDB)
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/atm ${CURRENT_PACKAGES_DIR}/tools/MOOS/atm)
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/gtm ${CURRENT_PACKAGES_DIR}/tools/MOOS/gtm)
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/ktm ${CURRENT_PACKAGES_DIR}/tools/MOOS/ktm)
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/mqos ${CURRENT_PACKAGES_DIR}/tools/MOOS/mqos)
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/mtm ${CURRENT_PACKAGES_DIR}/tools/MOOS/mtm)
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/umm ${CURRENT_PACKAGES_DIR}/tools/MOOS/umm)
endif()


if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Put the licence file where vcpkg expects it
file(COPY
    ${SOURCE_PATH}/Core/GPLCore.txt
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(RENAME
    ${CURRENT_PACKAGES_DIR}/share/${PORT}/GPLCore.txt
    ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)


