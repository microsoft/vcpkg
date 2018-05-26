include(vcpkg_common_functions)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(STATUS "Warning: Dynamic building not supported yet. Building static.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rpclib/rpclib
    REF v2.2.0
    SHA512 73d2344debb3a6ced6a045ba3bf8839a6f91d8f43dfac8760c65d19d1fc7960e778457a20fddbd771d7dd4b12e32d8a925f1fc008d11ccc5654dbeb08ba0f50a
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/rpclib)

vcpkg_copy_pdbs()

file(COPY ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/rpclib)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/rpclib/LICENSE.md ${CURRENT_PACKAGES_DIR}/share/rpclib/copyright)
