include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lcm-proj/lcm
    REF 82bd3a223e3227c70832307e53a65c13c1e5f81b
    SHA512 5d3abf457e18a3bb50489ed17393c5416a459134f73c264e67d174a29411d6deb70c754b5669422a438ea3e5793b9b1b91d67e9d842151c5a910245fede5879f
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/only-install-one-flavor.patch
)

vcpkg_configure_cmake(
     SOURCE_PATH ${SOURCE_PATH}
     PREFER_NINJA
     OPTIONS
        -DLCM_ENABLE_JAVA=OFF
        -DLCM_ENABLE_LUA=OFF
        -DLCM_ENABLE_PYTHON=OFF
        -DLCM_ENABLE_TESTS=OFF
        -DLCM_INSTALL_M4MACROS=OFF
        -DLCM_INSTALL_PKGCONFIG=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/aclocal)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/java)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/man)

file(GLOB EXES ${CURRENT_PACKAGES_DIR}/bin/*.exe)
if(EXES)
    file(COPY ${EXES} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/lcm)
    file(REMOVE ${EXES})
endif()
file(GLOB DEBUG_EXES ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe)
if(DEBUG_EXES)
    file(REMOVE ${DEBUG_EXES})
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/lcm)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/lcm RENAME copyright)

vcpkg_copy_pdbs()
