include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO graeme-hill/crossguid
    REF v0.2.2
    SHA512 49a707f830b32ba136bd52e72dda191a7d29acee9795df54f225bb269853cc123390c01875dd1da7cbaebd5bb7001988d6f9758dcffa9171b5f2961f576682ca
    HEAD_REF master
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(STATUS "Warning: Dynamic building not supported.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DXG_TESTS:BOOL=OFF
)

vcpkg_build_cmake()

file(INSTALL ${SOURCE_PATH}/Guid.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/xg.lib  DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/xg.lib  DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/crossguid)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/crossguid/LICENSE ${CURRENT_PACKAGES_DIR}/share/crossguid/copyright)

