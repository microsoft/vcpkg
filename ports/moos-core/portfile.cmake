include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO themoos/core-moos
    REF v10.4.0
    SHA512 8a82074bd219bbedbe56c2187afe74a55a252b0654a675c64d1f75e62353b0874e7b405d9f677fadb297e955d11aea50a07e8f5f3546be3c4ddab76fe356a51e 
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

message(STATUS "MOOS INSTALL -DCMAKE_INSTALL_PREFIX=${CURRENT_PACKAGES_DIR}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_SHARED_LIBS=${BUILD_SHARED}
#        -DCMAKE_INSTALL_PREFIX=${CURRENT_PACKAGES_DIR}
        -DCMAKE_ENABLE_EXPORT=OFF
)

vcpkg_install_cmake()

# Move CMake config files to the right place
if(EXISTS ${CURRENT_PACKAGES_DIR}/CMake)
    vcpkg_fixup_cmake_targets(CONFIG_PATH "CMake" TARGET_PATH share/${PORT})
else()
	vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/MOOS" TARGET_PATH share/${PORT})
endif()

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools)
if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/MOOSDB")
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/MOOSDB ${CURRENT_PACKAGES_DIR}/tools/MOOSDB)
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/atm ${CURRENT_PACKAGES_DIR}/tools/atm)
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/gtm ${CURRENT_PACKAGES_DIR}/tools/gtm)
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/ktm ${CURRENT_PACKAGES_DIR}/tools/ktm)
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/mqos ${CURRENT_PACKAGES_DIR}/tools/mqos)
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/mtm ${CURRENT_PACKAGES_DIR}/tools/mtm)
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/umm ${CURRENT_PACKAGES_DIR}/tools/umm)
endif()


if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/MOOS/libMOOS/Thirdparty/getpot)

# Put the licence file where vcpkg expects it
file(COPY
    ${SOURCE_PATH}/Core/GPLCore.txt
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(RENAME
    ${CURRENT_PACKAGES_DIR}/share/${PORT}/GPLCore.txt
    ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)


