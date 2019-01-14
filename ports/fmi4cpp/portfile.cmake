# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT_DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)
#

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO NTNU-IHB/FMI4cpp
    REF v0.5.2
    SHA512 a52007b635da537a8c0404519b91981f2a7dd0f357bdde29bc7e6d83ed44384a5b4f3746e3defd951ae281b32110290d126b23599225f9a87e1924a1abdf907e
    HEAD_REF master
)

set(WITH_ODEINT OFF)
if("odeint" IN_LIST FEATURES)
    set(WITH_ODEINT ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS 
        -DFMI4CPP_BUILD_TOOL=OFF
        -DFMI4CPP_BUILD_TESTS=OFF
        -DFMI4CPP_BUILD_EXAMPLES=OFF
	-DFMI4CPP_WITH_ODEINT=${WITH_ODEINT}
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/FMI4cpp")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/fmi4cpp RENAME copyright)

vcpkg_copy_pdbs()
