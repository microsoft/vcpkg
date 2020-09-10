include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO qhull/qhull
    REF v8.0.0 # Qhull 2020.1
    SHA512 b6ac17193b7c8a4ffb5f5a64cc057d1d5123f155f1c4fcd290fe1768356fef5c58d511707bba8c4814ca754bc6cdf5c370af23953d00c24a5ec28b8a1e489d31
    HEAD_REF master
    PATCHES
        mac-fix.patch
)
if(${TARGET_TRIPLET} STREQUAL "x64-windows-static")
# workaround for visual studio toolset regression LNK1201 (remove if solved)
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DINCLUDE_INSTALL_DIR=${CURRENT_PACKAGES_DIR}/include
        -DMAN_INSTALL_DIR=${CURRENT_PACKAGES_DIR}/doc/qhull
        -DDOC_INSTALL_DIR=${CURRENT_PACKAGES_DIR}/doc/qhull
    OPTIONS_RELEASE
        -DLIB_INSTALL_DIR=${CURRENT_PACKAGES_DIR}/lib
    OPTIONS_DEBUG
        -DLIB_INSTALL_DIR=${CURRENT_PACKAGES_DIR}/debug/lib
)
else()
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DINCLUDE_INSTALL_DIR=${CURRENT_PACKAGES_DIR}/include
        -DMAN_INSTALL_DIR=${CURRENT_PACKAGES_DIR}/doc/qhull
        -DDOC_INSTALL_DIR=${CURRENT_PACKAGES_DIR}/doc/qhull
    OPTIONS_RELEASE
        -DLIB_INSTALL_DIR=${CURRENT_PACKAGES_DIR}/lib
    OPTIONS_DEBUG
        -DLIB_INSTALL_DIR=${CURRENT_PACKAGES_DIR}/debug/lib
)
endif()

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/Qhull)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(GLOB_RECURSE HTMFILES ${CURRENT_PACKAGES_DIR}/include/*.htm)
file(REMOVE ${HTMFILES})
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/doc)

file(GLOB EXEFILES_RELEASE ${CURRENT_PACKAGES_DIR}/bin/*.exe)
file(GLOB EXEFILES_DEBUG ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe)
file(COPY ${EXEFILES_RELEASE} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/qhull)
if(EXEFILES_RELEASE OR EXEFILES_DEBUG)
    file(REMOVE ${EXEFILES_RELEASE} ${EXEFILES_DEBUG})
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/qhull.lib ${CURRENT_PACKAGES_DIR}/debug/lib/qhull_d.lib)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/qhull_p.lib ${CURRENT_PACKAGES_DIR}/debug/lib/qhull_pd.lib)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/qhull_r.lib ${CURRENT_PACKAGES_DIR}/debug/lib/qhull_rd.lib)
else()
    file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/qhullcpp.lib ${CURRENT_PACKAGES_DIR}/debug/lib/qhullcpp_d.lib)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/qhullstatic.lib ${CURRENT_PACKAGES_DIR}/debug/lib/qhullstatic_d.lib)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/qhullstatic_r.lib ${CURRENT_PACKAGES_DIR}/debug/lib/qhullstatic_rd.lib)
endif()

file(COPY ${SOURCE_PATH}/README.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/qhull)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/qhull/README.txt ${CURRENT_PACKAGES_DIR}/share/qhull/copyright)
