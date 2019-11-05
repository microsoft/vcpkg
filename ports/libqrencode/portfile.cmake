include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fukuchi/libqrencode
    REF v4.0.2
    SHA512 847e32bd13358319f3beabde103b5335a6e11c3f9275425b74e89a00b0ee4d67af8a428f12acc8b80a0419382480e5aeb02e58602a69ee750c21b28f357af6bc
    HEAD_REF master
    PATCHES
        fix-found-wingetopt.patch
)

if("tool" IN_LIST FEATURES)
    set(WITH_TOOLS YES)
else()
    set(WITH_TOOLS NO)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DWITH_TOOLS=${WITH_TOOLS}
        -DWITH_TEST=NO
        -DSKIP_INSTALL_PROGRAMS=ON
        -DSKIP_INSTALL_EXECUTABLES=ON
        -DSKIP_INSTALL_FILES=ON
    OPTIONS_DEBUG
        -DSKIP_INSTALL_HEADERS=ON
        -DWITH_TOOLS=NO
)

vcpkg_install_cmake()

if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore") # Windows
	set(EXECUTABLE_SUFFIX ".exe")
else()
	set(EXECUTABLE_SUFFIX "")
endif()

if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/qrencode.dll)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/qrencode.dll ${CURRENT_PACKAGES_DIR}/bin/qrencode.dll)
endif()
if(EXISTS ${CURRENT_PACKAGES_DIR}/debug/lib/qrencoded.dll)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/qrencoded.dll ${CURRENT_PACKAGES_DIR}/debug/bin/qrencoded.dll)
endif()
if(EXISTS ${CURRENT_PACKAGES_DIR}/bin/qrencode${EXECUTABLE_SUFFIX})
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/qrencode")
    file(RENAME "${CURRENT_PACKAGES_DIR}/bin/qrencode${EXECUTABLE_SUFFIX}" "${CURRENT_PACKAGES_DIR}/tools/qrencode/qrencode${EXECUTABLE_SUFFIX}")
    vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/qrencode)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libqrencode)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libqrencode/COPYING ${CURRENT_PACKAGES_DIR}/share/libqrencode/copyright)

vcpkg_copy_pdbs()

file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
