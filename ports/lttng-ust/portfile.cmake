vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lttng/lttng-ust
    REF v2.12.5
    SHA512 1ba781218608ce10decedab49a947b7cc60bf8e69d77d5bc56629238b97e5006131eec4071143f14968e602c535f94a7c034d44e1f27eca3fbc5edb995a476d3
    HEAD_REF main
)

set(VCPKG_TARGET_ARCHITECTURE x64)

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
#set(VCPKG_CRT_LINKAGE dynamic)
#set(VCPKG_LIBRARY_LINKAGE dynamic)

set(VCPKG_CMAKE_SYSTEM_NAME Linux)

set(VCPKG_FIXUP_ELF_RPATH ON)

if(EXISTS "${src_dir}/configure" AND "${src_dir}/configure.ac")
     if(NOT VCPKG_MAINTAINER_SKIP_AUTOCONFIG)
         set(requires_autoconfig ON) 
         file(REMOVE "${SRC_DIR}/configure")
         set(arg_AUTOCONFIG ON) 
     endif() 
 elseif(EXISTS "${src_dir}/configure" AND NOT arg_SKIP_CONFIGURE)
 endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS
        --prefix=/usr
        --disable-man-pages
        ${OPTIONS}

)

vcpkg_install_make()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_fixup_pkgconfig()

file(
	INSTALL "${SOURCE_PATH}/LICENSE"
	DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
	RENAME copyright)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
