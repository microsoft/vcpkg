if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(PATCHES meson.build.patch 
                dependency.patch)
    if(NOT VCPKG_TARGET_IS_WINDOWS)
       #set(VCPKG_LINKER_FLAGS "-lxau -lxdmcp -lx11-xcb")
    endif()
endif()

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO anholt/libepoxy
    REF 09edbe01d901c0f01e866aa08455c6d9ee6fd0ac # 1.5.4
    SHA512 cbe9fb1db2c03874c10632b572990e313d8ffdbbb1155b10e8d6f530c7c5117e7382f0c3777df91fe4ae201a6ff3ada98c793e8bcda017344885e5b7cee3ddcb
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
