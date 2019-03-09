include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cutelyst/cutelyst
    REF 7f594d2b2d227e9e6a0474a55906db7d1ee1cd7e
    SHA512 de04efd7bd9b07f7b0dd2b014eed93e26f0760ef8e458f8c56dc655977235f237bbc71cfe1c05d6791c2237073497ca4566548327ad01b99b4dbec7c491542c7
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTS:BOOL=OFF
)

vcpkg_install_cmake()

# Move CMake config files to the right place
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/Cutelyst2Qt5 TARGET_PATH share/cutelyst2qt5)

file(GLOB EXES ${CURRENT_PACKAGES_DIR}/bin/cutelyst2 ${CURRENT_PACKAGES_DIR}/bin/cutelyst2-wsgi ${CURRENT_PACKAGES_DIR}/bin/cutelyst2.exe ${CURRENT_PACKAGES_DIR}/bin/cutelyst-wsgi2.exe)
file(GLOB DEBUG_EXES ${CURRENT_PACKAGES_DIR}/debug/bin/cutelyst2 ${CURRENT_PACKAGES_DIR}/debug/bin/cutelyst2-wsgi ${CURRENT_PACKAGES_DIR}/debug/bin/cutelyst2.exe ${CURRENT_PACKAGES_DIR}/debug/bin/cutelyst-wsgi2.exe)
if(EXES OR DEBUG_EXES)
    file(COPY ${EXES} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/cutelyst2)
    file(REMOVE ${EXES} ${DEBUG_EXES})
    vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/cutelyst2)
endif()

if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/cutelyst2-plugins/ActionREST.dll)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/cutelyst2-plugins ${CURRENT_PACKAGES_DIR}/bin/cutelyst2-plugins)
endif()
if(EXISTS ${CURRENT_PACKAGES_DIR}/debug/lib/cutelyst2-plugins/ActionREST.dll)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/cutelyst2-plugins ${CURRENT_PACKAGES_DIR}/debug/bin/cutelyst2-plugins)
endif()

file(GLOB BINS ${CURRENT_PACKAGES_DIR}/bin/* ${CURRENT_PACKAGES_DIR}/debug/bin/*)
if(NOT BINS)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
configure_file(${SOURCE_PATH}/COPYING ${CURRENT_PACKAGES_DIR}/share/cutelyst2/copyright COPYONLY)

vcpkg_copy_pdbs()
