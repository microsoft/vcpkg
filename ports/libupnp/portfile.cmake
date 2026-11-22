vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pupnp/pupnp
    REF "release-${VERSION}"
    SHA512 ae4e904948dff2e471f741db14aeeb25dcd8cac912a0f7dd24b278bc9b7fb74a14ed346a38759bdd865e1cba404ae9a71bd79c851e3bb2fef0dc03674053bd00
    PATCHES
        fix-pthreads4w-targets.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" LIBUPNP_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" LIBUPNP_BUILD_SHARED)

if(LIBUPNP_BUILD_STATIC)
    set(UPNP_TARGET "Static")
else()
    set(UPNP_TARGET "Shared")
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    client-api      UPNP_ENABLE_CLIENT_API
    ipv6            UPNP_ENABLE_IPV6
    ssl             UPNP_ENABLE_OPEN_SSL
    webserver       UPNP_ENABLE_WEBSERVER
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=ON
        -DUPNP_BUILD_SAMPLES=OFF
        -DUPNP_BUILD_SHARED=${LIBUPNP_BUILD_SHARED}
        -DUPNP_BUILD_STATIC=${LIBUPNP_BUILD_STATIC}
        -DUPNP_ENABLE_BLOCKING_TCP_CONNECTIONS=OFF
        -DUPNP_ENABLE_DEVICE_API=${UPNP_ENABLE_WEBSERVER}
        -DUPNP_ENABLE_GENA=ON
        -DUPNP_ENABLE_SOAP=ON
        -DUPNP_ENABLE_SSDP=ON
        -DUPNP_ENABLE_TESTING=OFF
        -DUPNP_ENABLE_UNSPECIFIED_SERVER=OFF
        -DUPNP_MINISERVER_REUSEADDR=${UPNP_ENABLE_WEBSERVER}
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

foreach(config IN ITEMS release debug)
    if(VCPKG_BUILD_TYPE AND NOT VCPKG_BUILD_TYPE STREQUAL "${config}")
        continue()
    endif()

    if(config STREQUAL "debug")
        set(pc_file "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libupnp.pc")
        set(debug_suffix "d")
    else()
        set(pc_file "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libupnp.pc")
        set(debug_suffix "")
    endif()

    if("ssl" IN_LIST FEATURES)
        vcpkg_replace_string("${pc_file}" "Libs.private: -lssl" "Requires.private: openssl\nLibs.private:")
    endif()

    if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
        set(static_suffix "")
        if(LIBUPNP_BUILD_STATIC)
            set(static_suffix "s")
        endif()
        vcpkg_replace_string("${pc_file}" "-lupnp -lixml"
            "-llibupnp${static_suffix}${debug_suffix} -lixml${static_suffix}${debug_suffix}")
    endif()

    if(VCPKG_TARGET_IS_WINDOWS AND LIBUPNP_BUILD_STATIC)
        set(pc_private_libs "-lws2_32 -liphlpapi")
        if(NOT VCPKG_TARGET_IS_MINGW)
            string(PREPEND pc_private_libs "-lpthreadVC3${debug_suffix} ")
        endif()
        vcpkg_replace_string("${pc_file}" "Libs.private:" "Libs.private: ${pc_private_libs}")
    endif()
endforeach()

vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/UPNP PACKAGE_NAME UPNP)
vcpkg_copy_pdbs()

if(VCPKG_TARGET_IS_WINDOWS AND LIBUPNP_BUILD_STATIC)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/upnp/UpnpGlobal.h"
        "#define UPNPGLOBAL_H"
        "#define UPNPGLOBAL_H\n\n#ifndef UPNP_STATIC_LIB\n#define UPNP_STATIC_LIB\n#endif")
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/COPYING"
    "${SOURCE_PATH}/upnp/inc/list.h"
    "${SOURCE_PATH}/upnp/src/inc/uuid.h"
    "${SOURCE_PATH}/upnp/src/inc/md5.h"
    "${SOURCE_PATH}/upnp/src/inet_pton.c"
)
