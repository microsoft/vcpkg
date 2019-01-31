include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ome/ome-files-cpp
    REF c9b6def0e1e07816d6827d361744b344e7da5f20
    SHA512 c5aadbe530c3faaebb2ec71dfe973418de93b91ddbaab7d1f9f2d6639eeafda26bf39389f3be45ec8c0fdd4de44dc03849ecbdacd39d8b9a9b7e5ba5db706f1f
    HEAD_REF master
    PATCHES
        checks.patch
        cmakelists.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
       -Dtest:BOOL=OFF
       -Dextended-tests:BOOL=OFF
       -Drelocatable-install:BOOL=ON
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/OMEFiles TARGET_PATH share/OMEFiles)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(COPY ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/omefiles)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/omefiles/LICENSE.md ${CURRENT_PACKAGES_DIR}/share/omefiles/copyright)