include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cutelyst/cutelyst
    REF e25026edf836621a1d82745ce625509d307f5dc1 # v2.9.0
    SHA512 39afa6bb73217341e741a7dcf40b0d73ccabd018ba68df248e7092d80077c23be8bf31c244590a7fe8a37209c09395423eb945d21a1a11109ee7da60644802b3
    HEAD_REF master
    PATCHES fix-static-build.patch
)

set(BUILD_WIN_STATIC OFF)
if (VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(BUILD_WIN_STATIC ON)
endif()

vcpkg_configure_cmake( 
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTS:BOOL=OFF
        -DBUILD_WIN_STATIC=${BUILD_WIN_STATIC}
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
