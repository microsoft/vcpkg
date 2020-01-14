vcpkg_fail_port_install(ON_TARGET "Linux" "UWP")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ebiggers/libdeflate
    REF v1.5
    SHA512 8e86e87733bb1b2b2d4dda6ce0be96b57a125776c1f81804d5fc6f51516dd52796d9bb800ca4044c637963136ae390cfaf5cd804e9ae8b5d93d36853d0e807f6
    HEAD_REF master
    PATCHES
        makefile.patch
)

if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_install_nmake(
        SOURCE_PATH ${SOURCE_PATH}
        PROJECT_NAME Makefile.msc
    )

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

        file(COPY ${CURRENT_PACKAGES_DIR}/debug/bin/gzip.exe DESTINATION ${CURRENT_PACKAGES_DIR}/debug/tools/${PORT})
        file(COPY ${CURRENT_PACKAGES_DIR}/debug/bin/gunzip.exe DESTINATION ${CURRENT_PACKAGES_DIR}/debug/tools/${PORT})

        file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/gzip.exe)
        file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/gunzip.exe)

        if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
            file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/lib/libdeflatestatic.lib)
        elseif (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
            file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/lib/libdeflate.lib)
            file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/libdeflatestatic.lib ${CURRENT_PACKAGES_DIR}/debug/lib/libdeflate.lib)
            file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/libdeflate.dll)
            file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
        endif()
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        file(COPY ${CURRENT_PACKAGES_DIR}/bin/gzip.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})
        file(COPY ${CURRENT_PACKAGES_DIR}/bin/gunzip.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT})

        file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/gzip.exe)
        file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/gunzip.exe)

        if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
            file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/libdeflatestatic.lib)
        elseif (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
            file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/libdeflate.lib)
            file(RENAME ${CURRENT_PACKAGES_DIR}/lib/libdeflatestatic.lib ${CURRENT_PACKAGES_DIR}/lib/libdeflate.lib)
            file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/libdeflate.dll)
            file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
        endif()
    endif()
else()
    vcpkg_configure_make(
        SOURCE_PATH ${SOURCE_PATH}
        SKIP_CONFIGURE
    )

    vcpkg_install_make(
        MAKE_INSTALL_OPTIONS_DEBUG
            "PREFIX=${CURRENT_PACKAGES_DIR}/debug"
            "BINDIR=${CURRENT_PACKAGES_DIR}/debug/tools/${PORT}"
        MAKE_INSTALL_OPTIONS_RELEASE
            "PREFIX=${CURRENT_PACKAGES_DIR}"
            "BINDIR=${CURRENT_PACKAGES_DIR}/tools/${PORT}"
    )

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
    endif()
endif()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
