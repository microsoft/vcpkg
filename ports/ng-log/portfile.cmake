vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ng-log/ng-log
    REF "v${VERSION}"
    SHA512 efcd474311b789e24e72d9ba0b43a02a078d75775f04539f2755dfc24cd1fcfd05a0f6fb17028ce3ed32755013ded0e7f542bc753936684228dc6d21722d9d07
    HEAD_REF master
    PATCHES
        devendor-dirent.patch
)

set(CROSSCOMP_OPTIONS "")
if(VCPKG_CROSSCOMPILING)
    set(CROSSCOMP_OPTIONS -DHAVE_SYMBOLIZE_EXITCODE=0)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_COMPAT=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTING=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_benchmark=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_GTest=ON
        -DPRINT_UNSYMBOLIZED_STACK_TRACES=OFF
        -DWITH_GFLAGS=ON
        -DWITH_PKGCONFIG=ON
        -DWITH_SYMBOLIZE=ON
        -DWITH_TLS=ON
        ${CROSSCOMP_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()

if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        vcpkg_replace_string(
            "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libng-log.pc"
            "-lgflags"
            "-lgflags_static -lshlwapi"
        )
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        vcpkg_replace_string(
            "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libng-log.pc"
            "-lgflags"
            "-lgflags_static_debug -lshlwapi"
        )
        vcpkg_replace_string(
            "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libng-log.pc"
            " -lng-log"
            " -lng-logd"
        )
    endif()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

foreach(header IN ITEMS flags.h log_severity.h logging.h raw_logging.h vlog_is_on.h)
    vcpkg_replace_string(
        "${CURRENT_PACKAGES_DIR}/include/ng-log/${header}"
        "#if defined(NGLOG_USE_EXPORT)"
        "#if 1"
    )
endforeach()

vcpkg_replace_string(
    "${CURRENT_PACKAGES_DIR}/include/ng-log/flags.h"
    "#if defined(NGLOG_USE_GFLAGS)"
    "#if 1"
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/ng-log/export.h" "#ifdef NGLOG_STATIC_DEFINE" "#if 1")
else()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/ng-log/export.h" "#ifdef NGLOG_STATIC_DEFINE" "#if 0")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
