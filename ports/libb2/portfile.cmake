vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BLAKE2/libb2
    REF 2c5142f12a2cd52f3ee0a43e50a3a76f75badf85
    SHA512 cf29cf9391ae37a978eb6618de6f856f3defa622b8f56c2d5a519ab34fd5e4d91f3bb868601a44e9c9164a2992e80dde188ccc4d1605dffbdf93687336226f8d
    HEAD_REF master
)

# The `libb2` true version is from `B2_LIBRARY_VERSION` defined in `configure.ac`, which `libtool` use `-version-info $(B2_LIBRARY_VERSION)` to set libb2's version(It generated [libb2.1.dylib, libb2.dylib])
set(B2_LIBRARY_VERSION 1:4:0)
string(REGEX MATCH "^[0-9]*" B2_LIBRARY_VERSION_MAJOR "${B2_LIBRARY_VERSION}")

set(OPTIONS)
if(CMAKE_HOST_WIN32)
    set(OPTIONS --disable-native) # requires cpuid
endif()

vcpkg_configure_make(
    AUTOCONFIG
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        ax_cv_check_cflags___O3=no # see https://github.com/microsoft/vcpkg/pull/17912#issuecomment-840514179
        ${OPTIONS}
)

vcpkg_install_make()

# Fix #31719: change rpath setting after install
if(VCPKG_TARGET_IS_OSX AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(INSTALL_NAME_DIR "@rpath")

    find_program(
        INSTALL_NAME_TOOL
        install_name_tool
        DOC "Absolute path of install_name_tool"
        REQUIRED
    )

    foreach(LIB_NAME IN ITEMS libb2)
        # debug
        vcpkg_execute_build_process(
            COMMAND "${INSTALL_NAME_TOOL}" -id "${INSTALL_NAME_DIR}/${LIB_NAME}.${B2_LIBRARY_VERSION_MAJOR}.dylib"
            "${LIB_NAME}.${B2_LIBRARY_VERSION_MAJOR}.dylib"
            WORKING_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/lib"
            LOGNAME "make-install-fix-rpath-dbg"
        )

        vcpkg_execute_build_process(
            COMMAND "${INSTALL_NAME_TOOL}" -add_rpath "@loader_path"
            "${LIB_NAME}.${B2_LIBRARY_VERSION_MAJOR}.dylib"
            WORKING_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/lib"
            LOGNAME "make-install-fix-rpath-dbg"
        )

        # release
        vcpkg_execute_build_process(
            COMMAND "${INSTALL_NAME_TOOL}" -id "${INSTALL_NAME_DIR}/${LIB_NAME}.${B2_LIBRARY_VERSION_MAJOR}.dylib"
            "${LIB_NAME}.${B2_LIBRARY_VERSION_MAJOR}.dylib"
            WORKING_DIRECTORY "${CURRENT_PACKAGES_DIR}/lib"
            LOGNAME "make-install-fix-rpath-rel"
        )

        vcpkg_execute_build_process(
            COMMAND "${INSTALL_NAME_TOOL}" -add_rpath "@loader_path"
            "${LIB_NAME}.${B2_LIBRARY_VERSION_MAJOR}.dylib"
            WORKING_DIRECTORY "${CURRENT_PACKAGES_DIR}/lib"
            LOGNAME "make-install-fix-rpath-rel"
        )
    endforeach()

endif()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
