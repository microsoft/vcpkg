vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO qhull/qhull
    REF v7.3.2 # Qhull 2019.1
    SHA512 aea2c70179de10f648aba960129a3b9a3fe309a0eb085bdb86f697e3d4b214570c241e88d4f0b4d2974137759ee7086452d0a3957c4b2a256708402fb3c9eb3d
    HEAD_REF master
    PATCHES
        uwp.patch
        mac-fix.patch
        fix-target-cannot-found.patch
)

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

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/Qhull) 

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(GLOB_RECURSE HTMFILES ${CURRENT_PACKAGES_DIR}/include/*.htm)
file(REMOVE ${HTMFILES})
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/doc)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/qhull.lib ${CURRENT_PACKAGES_DIR}/debug/lib/qhull.lib)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/qhull_p.lib ${CURRENT_PACKAGES_DIR}/debug/lib/qhull_p.lib)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/qhull_r.lib ${CURRENT_PACKAGES_DIR}/debug/lib/qhull_r.lib)
endif()

file(INSTALL ${SOURCE_PATH}/README.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)