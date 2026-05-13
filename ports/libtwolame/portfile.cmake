vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO njh/twolame
    REF 0.4.0
    SHA512 9a0d3ef430ca93b561caa7e56fe60c126135b1c36294a280fa21699402b3922a3992035f3d421f3bbe131cdc04459cc907059dfe0c2f512427f305fe3936e54d
    HEAD_REF main
    PATCHES
        patches/001-fix-tl-api-export.patch
        patches/002-disable-doc-subdir.patch
        patches/003-fix-kr-declaration.patch
)

if(VCPKG_TARGET_IS_WINDOWS)
    # Upstream has no CMakeLists.txt suitable for library-only builds.
    # Use our own minimal CMakeLists.txt.
    file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

    vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS
            -DTWOLAME_SRC_DIR="${SOURCE_PATH}"
    )
    vcpkg_cmake_build()
    vcpkg_cmake_install()
    vcpkg_copy_pdbs()
else()
    # Linux/macOS: use the standard autotools build
    if("tool" IN_LIST FEATURES)
        set(_sndfile_opt "--enable-sndfile")
    else()
        set(_sndfile_opt "--disable-sndfile")
    endif()

    vcpkg_configure_make(
        SOURCE_PATH "${SOURCE_PATH}"
        AUTOCONFIG
        OPTIONS
            ${_sndfile_opt}
    )

    vcpkg_install_make()
endif()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
