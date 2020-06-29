vcpkg_fail_port_install(ON_TARGET "UWP" ON_ARCH "arm")

set(MICROHTTPD_VERSION 0.9.63)

vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnu.org/gnu/libmicrohttpd/libmicrohttpd-${MICROHTTPD_VERSION}.tar.gz" "https://www.mirrorservice.org/sites/ftp.gnu.org/gnu/libmicrohttpd/libmicrohttpd-${MICROHTTPD_VERSION}.tar.gz"
    FILENAME "libmicrohttpd-${MICROHTTPD_VERSION}.tar.gz"
    SHA512 cb99e7af84fb6d7c0fd3894a9dc0fbff14959b35347506bd3211a65bbfad36455007b9e67493e97c9d8394834408df10eeabdc7758573e6aae0ba6f5f87afe17
)

vcpkg_extract_source_archive_ex(
    ARCHIVE ${ARCHIVE}
    OUT_SOURCE_PATH SOURCE_PATH
    PATCHES fix-msvc-project.patch
)

if (VCPKG_TARGET_IS_WINDOWS)
    if (TRIPLET_SYSTEM_ARCH MATCHES "x86")
        set(MSBUILD_PLATFORM "Win32")
    else ()
        set(MSBUILD_PLATFORM "x64")
    endif()
    
    if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        set(MICROHTTPD_CONFIGURATION_RELEASE "Release-dll")
        set(MICROHTTPD_CONFIGURATION_DEBUG "Debug-dll")
    else()
        set(MICROHTTPD_CONFIGURATION_RELEASE "Release-static")
        set(MICROHTTPD_CONFIGURATION_DEBUG "Debug-static")
    endif()

    vcpkg_install_msbuild(
        SOURCE_PATH ${SOURCE_PATH}
        PROJECT_SUBPATH w32/VS2015/libmicrohttpd.vcxproj
        PLATFORM ${MSBUILD_PLATFORM}
        RELEASE_CONFIGURATION ${MICROHTTPD_CONFIGURATION_RELEASE}
        DEBUG_CONFIGURATION ${MICROHTTPD_CONFIGURATION_DEBUG}
    )
    
    file(GLOB MICROHTTPD_HEADERS ${SOURCE_PATH}/src/include/*h)
    foreach(MICROHTTPD_HEADER ${MICROHTTPD_HEADERS})
        file(COPY ${MICROHTTPD_HEADER} DESTINATION ${CURRENT_PACKAGES_DIR}/include)
    endforeach()
else()
    vcpkg_configure_make(
        SOURCE_PATH "${SOURCE_PATH}"
    )

    vcpkg_install_make()
    
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
endif()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
