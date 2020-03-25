if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(PATCHES meson.build.patch)
    if(NOT VCPKG_TARGET_IS_WINDOWS)
        set(ENV{LDFLAGS} "$ENV{LDFLAGS} -lxau -lxdmcp -lx11-xcb")
    endif()
endif()

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO anholt/libepoxy
    REF 1.5.3
    SHA512 e831f4f918f08fd5f799501efc0e23b8d404478651634f5e7b35f8ebcc29d91abc447ab20da062dde5be75e18cb39ffea708688e6534f7ab257b949f9c53ddc8
    HEAD_REF master
    PATCHES ${PATCHES})

if (VCPKG_TARGET_IS_WINDOWS)
    set(OPTIONS -Denable-glx=no -Denable-egl=no)
else()
    set(OPTIONS -Denable-x11=yes -Denable-glx=yes -Denable-egl=yes)
endif()
vcpkg_configure_meson(SOURCE_PATH ${SOURCE_PATH}
    OPTIONS ${OPTIONS} -Dtests=false
    )
vcpkg_install_meson()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/pkgconfig)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share/pkgconfig)

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(RENAME ${CURRENT_PACKAGES_DIR}/share/${PORT}/COPYING ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)
