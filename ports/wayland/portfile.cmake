if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(PATCHES meson.build.patch) 
    # this patch is not 100% correct since xcb and xcb-xkb can be build dynamically in a custom triplet
    # However, VCPKG currently is limited by the possibilities of meson and they have to fix their lib dependency detection
endif()

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wayland/wayland
    REF  eb1339edd398b9f5328816931e585db4229aa132 #1.18.0
    SHA512 96a96c87475efea68e39a542afd6ab1c0eece28dc43aad88ba4980be6a903943bf398f8500c8d56d4cc6281ad6a51fd0a2a041e17fe88dcf6f43fa9c66d0bcb5
    HEAD_REF master # branch name
    PATCHES ${PATCHES}
) 

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS -Ddtd_validation=false
            -Ddocumentation=false
)
vcpkg_install_meson()

if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/" AND VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/src/${VCPKG_TARGET_STATIC_LIBRARY_PREFIX}wayland-private${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}"
                 DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/src/${VCPKG_TARGET_STATIC_LIBRARY_PREFIX}wayland-util${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}"
             DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/" AND VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/src/${VCPKG_TARGET_STATIC_LIBRARY_PREFIX}wayland-private${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}"
                 DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
    file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/src/${VCPKG_TARGET_STATIC_LIBRARY_PREFIX}wayland-util${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}"
                 DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
endif()
vcpkg_fixup_pkgconfig(SYSTEM_LIBRARIES "-pthread")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# # Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
file(RENAME "${CURRENT_PACKAGES_DIR}/bin/wayland-scanner${VCPKG_TARGET_EXECUTABLE_SUFFIX}" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/wayland-scanner${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
file(MAKE_DIRECTORY  "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/aclocal" "${CURRENT_PACKAGES_DIR}/share/${PORT}/aclocal")
if(VCPKG_LIBRARY_LINKAGE STREQUAL static OR NOT VCPKG_TARGET_IS_WINDOWS)
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

#TODO: Check this again!
set(_file "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/wayland-scanner.pc")
if(EXISTS "${_file}")
    file(READ "${_file}" _contents)
    string(REPLACE "bindir=\${prefix}/bin" "bindir=\${prefix}/tools/${PORT}" _contents "${_contents}")
    file(WRITE "${_file}" "${_contents}")
endif()

set(_file "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/wayland-scanner.pc")
if(EXISTS "${_file}")
    file(READ "${_file}" _contents)
    string(REPLACE "bindir=\${prefix}/bin" "bindir=\${prefix}/../tools/${PORT}" _contents "${_contents}")
    file(WRITE "${_file}" "${_contents}")
endif()

