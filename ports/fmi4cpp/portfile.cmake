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
    REF v0.5.3
    SHA512 1c62f1fce4d3c0c18bc0a470827be13bc143ec8152ac75781e4d61d332b97389afc5943001e7cb8ae0ea7ebc141d88b00033de73a3d5696923a3f1c05f8ff904
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
