include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME MATCHES "WindowsStore")
    set(WIN_PATCHES strdup-fix.patch strncpy-fix.patch)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Yubico/libu2f-server
    REF libu2f-server-1.1.0
    SHA512 085f8e7d74c1efb347747b8930386f18ba870f668f82e9bd479c9f8431585c5dc7f95b2f6b82bdd3a6de0c06f8cb2fbf51c363ced54255a936ab96536158ee59
    HEAD_REF master
    PATCHES
        windows.patch
        ${WIN_PATCHES}
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/u2f-server-version.h DESTINATION ${SOURCE_PATH}/u2f-server)

vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        PREFER_NINJA
    )

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
vcpkg_copy_pdbs()

# Handle copyright
configure_file(${SOURCE_PATH}/COPYING ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
