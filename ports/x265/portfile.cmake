include(vcpkg_common_functions)

vcpkg_from_bitbucket(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO multicoreware/x265
    REF 2.9
    SHA512 5bd9732b6af67e7f7c5b1e71d26acbd98fb98e9e81c6052cda2e1e9254e3eaaa28914805d3f8cd2535dd042022047e54f8ae49ea02269160b609d191a7d99e94
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/disable-install-pdb.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" ENABLE_SHARED)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/source
    PREFER_NINJA
    OPTIONS -DENABLE_SHARED=${ENABLE_SHARED}
    OPTIONS_DEBUG -DENABLE_CLI=OFF
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

# remove duplicated include files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/x265)

if(UNIX)
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/x265 ${CURRENT_PACKAGES_DIR}/tools/x265/x265)
elseif(WIN32)    
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/x265.exe ${CURRENT_PACKAGES_DIR}/tools/x265/x265.exe)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
endif()

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/x265)

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/x265)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/x265/COPYING ${CURRENT_PACKAGES_DIR}/share/x265/copyright)