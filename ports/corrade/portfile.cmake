include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mosra/corrade
    REF b87c50db3543367b6eb20dc72246c6687449b029
    SHA512 882ccba210c6db7dc8a70e425e1cc119dd1c1a880b8b7d36b2c9478a2105294294680495e7bafb8c0bc7f667bd247dbd008e8ff133a8ea26b13df781a8896297
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