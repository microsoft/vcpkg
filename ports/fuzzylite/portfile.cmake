include(vcpkg_common_functions)

if(EXISTS "${CURRENT_BUILDTREES_DIR}/src/.git")
    file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/src)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fuzzylite/fuzzylite
    REF v6.0
    SHA512 6f5d40d0359458e109ac2aebfbf571f61867a8b49920f4a5e1b5d86bdf578dba038b942c9e05eab0d4620f73e8cded770abe7b5e597a3b4c39dbcf6a1259f4af
    HEAD_REF master
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(FL_BUILD_SHARED ON)
    set(FL_BUILD_STATIC OFF)
else()
    set(FL_BUILD_SHARED OFF)
    set(FL_BUILD_STATIC ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/fuzzylite
    PREFER_NINJA
    OPTIONS
        -DFL_BUILD_SHARED=${FL_BUILD_SHARED}
        -DFL_BUILD_STATIC=${FL_BUILD_STATIC}
        -DFL_BUILD_BINARY=OFF
        -DFL_BUILD_TESTS=OFF
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/pkgconfig)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/fuzzylite-static.lib ${CURRENT_PACKAGES_DIR}/lib/fuzzylite.lib)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/fuzzylite-static-debug.lib ${CURRENT_PACKAGES_DIR}/debug/lib/fuzzylite-debug.lib)
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/fuzzylite RENAME copyright)
