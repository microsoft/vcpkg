vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pganalyze/libpg_query
    REF "${VERSION}"
    SHA512 d17652fae797b658457501dd9b5dff9c5805f001b600e3231c1c00c17c08404817aa4436a6096731cf362552470dce00470753ae622615e62f5330f32478548d
    HEAD_REF master
    PATCHES
        0001-use-system-deps.patch
)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

    vcpkg_build_nmake(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_NAME "Makefile.msvc"
        CL_LANGUAGE C
        TARGET build
    )

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/pg_query.lib"
            DESTINATION "${CURRENT_PACKAGES_DIR}/lib"
        )
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/pg_query.lib"
            DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib"
        )
    endif()
else()
    file(COPY "${CMAKE_CURRENT_LIST_DIR}/configure" DESTINATION "${SOURCE_PATH}")

    vcpkg_make_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        COPY_SOURCE
    )

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        set(lib_suffix "${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}")
        set(make_target "build")
    else()
        set(lib_suffix "${VCPKG_TARGET_SHARED_LIBRARY_SUFFIX}")
        set(make_target "build_shared")
    endif()

    vcpkg_make_install(
        TARGETS "${make_target}"
        OPTIONS "CFLAGS_OPT_LEVEL="
    )

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/libpg_query${lib_suffix}"
            DESTINATION "${CURRENT_PACKAGES_DIR}/lib"
        )
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/libpg_query${lib_suffix}"
            DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib"
        )
    endif()
endif()

file(INSTALL "${SOURCE_PATH}/pg_query.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(INSTALL "${SOURCE_PATH}/postgres_deparse.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(INSTALL "${SOURCE_PATH}/protobuf/pg_query.pb-c.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/protobuf")
file(INSTALL "${SOURCE_PATH}/protobuf/pg_query.proto" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/unofficial-libpg-query-config.cmake"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}"
    RENAME "unofficial-${PORT}-config.cmake"
)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
