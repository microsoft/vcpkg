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
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/Fast-CDR)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eProsima/Fast-CDR
    REF v1.0.6
    SHA512 80861ff6a0283e1398306e081fe70d7d185f980e5714ae51864cae012b8f79719efa24e7f41025b2bfb2052cb2a3098436c75a38407f8f5a331593cb91868fb2
    HEAD_REF master
)


vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/LICENSE)
file(REMOVE ${CURRENT_PACKAGES_DIR}/LICENSE)

# always build static and share library default
if("${VCPKG_LIBRARY_LINKAGE}" STREQUAL "static")
	file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
	file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/fastcdr-1.0.lib ${CURRENT_PACKAGES_DIR}/debug/lib/fastcdrd-1.0.lib)
	file(RENAME ${CURRENT_PACKAGES_DIR}/lib/libfastcdr-1.0.lib ${CURRENT_PACKAGES_DIR}/lib/fastcdr-1.0.lib)
	file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/libfastcdrd-1.0.lib ${CURRENT_PACKAGES_DIR}/debug/lib/fastcdrd-1.0.lib)
	
	file(READ ${CURRENT_PACKAGES_DIR}/include/fastcdr/eProsima_auto_link.h EPROSIMA_AUTO_LINK_H)
	string(REPLACE "#define EPROSIMA_LIB_PREFIX \"lib\"" "#define EPROSIMA_LIB_PREFIX" EPROSIMA_AUTO_LINK_H "${EPROSIMA_AUTO_LINK_H}")
	file(WRITE ${CURRENT_PACKAGES_DIR}/include/fastcdr/eProsima_auto_link.h "${EPROSIMA_AUTO_LINK_H}")
elseif("${VCPKG_LIBRARY_LINKAGE}" STREQUAL "dynamic")
	file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/libfastcdr-1.0.lib ${CURRENT_PACKAGES_DIR}/debug/lib/libfastcdrd-1.0.lib)
	file(READ ${CURRENT_PACKAGES_DIR}/include/fastcdr/config.h FASTCDR_H)
	string(REPLACE "#define _FASTCDR_CONFIG_H_" "#define _FASTCDR_CONFIG_H_\r\n#define FASTCDR_DYN_LINK" FASTCDR_H "${FASTCDR_H}")
	file(WRITE ${CURRENT_PACKAGES_DIR}/include/fastcdr/config.h "${FASTCDR_H}")
else()

endif()

# Handle copyright
file(COPY ${SOURCE_PATH}/license DESTINATION ${CURRENT_PACKAGES_DIR}/share/fastcdr)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/fastcdr/license ${CURRENT_PACKAGES_DIR}/share/fastcdr/copyright)
