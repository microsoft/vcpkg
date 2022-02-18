vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lcm-proj/lcm
    REF v1.4.0
    SHA512 ca036aa2c31911e0bfaeab9665188c97726201267314693a1c333c4efe13ea598b39a55a19bc1d48e65462ac9d1716adfda5af86c645d59c3247192631247cc6
    HEAD_REF master
    PATCHES 
        only-install-one-flavor.patch
        fix-build-error.patch
        glib.link.patch
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
if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)
else()
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/lcm/cmake)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/lcm" "${CURRENT_PACKAGES_DIR}/lib/lcm")
endif()


file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/aclocal")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/java")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/man")

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
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/lcm)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_copy_pdbs()
