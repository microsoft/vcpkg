vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ng-log/ng-log
    REF "v${VERSION}"
    SHA512 321ea867b4ef2c73d0d54ae7906942ad1341605f5a837c296170f3295e96cf87a42c4c71ce707983e09d865dd29e6cc0656fc640c2214381f9c0f0f242365e70
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
        -DPRINT_UNSYMBOLIZED_STACK_TRACES=OFF
        -DWITH_GFLAGS=ON
        -DWITH_GTEST=OFF
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
