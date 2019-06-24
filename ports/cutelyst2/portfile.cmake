include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cutelyst/cutelyst
    REF v2.7.0
    SHA512 78848d6d4e79149d9e9ae07211875dd212eb046bcdde7cde0bd781ed89d006247b21bc7a37c4e028d0982bb0f69654d469eb37b857dc0d585e9adc79ecd6291d
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

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
configure_file(${SOURCE_PATH}/COPYING ${CURRENT_PACKAGES_DIR}/share/cutelyst2/copyright COPYONLY)

vcpkg_copy_pdbs()
