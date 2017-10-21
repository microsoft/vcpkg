include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mosra/corrade
    REF c182fe636894a998f241212d0205d0c126b7926f
    SHA512 d664c7884c0c6c7977261a851948b2b591ac0fbdbcfddab1d8e578e629a252f48fa786cf9f96525e10aa76c95919dfc3452ccbe5e930aa4a69e61269e4ee07ee
    HEAD_REF master
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(BUILD_STATIC 1)
else()
    set(BUILD_STATIC 0)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS -DBUILD_STATIC=${BUILD_STATIC}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Drop a copy of tools
file(COPY ${CURRENT_PACKAGES_DIR}/bin/corrade-rc.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools/corrade)

# Tools require dlls
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/corrade)

file(GLOB_RECURSE TO_REMOVE 
   ${CURRENT_PACKAGES_DIR}/bin/*.exe
   ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe)
file(REMOVE ${TO_REMOVE})

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
   file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
   file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/corrade)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/corrade/COPYING ${CURRENT_PACKAGES_DIR}/share/corrade/copyright)

vcpkg_copy_pdbs()
