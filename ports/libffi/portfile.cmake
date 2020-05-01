vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libffi/libffi
    REF v3.3
    SHA512 62798fb31ba65fa2a0e1f71dd3daca30edcf745dc562c6f8e7126e54db92572cc63f5aa36d927dd08375bb6f38a2380ebe6c5735f35990681878fc78fc9dbc83
    HEAD_REF master
)

if(VCPKG_TARGET_IS_WINDOWS)
    file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
    file(COPY ${CMAKE_CURRENT_LIST_DIR}/libffiConfig.cmake.in DESTINATION ${SOURCE_PATH})

    vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        PREFER_NINJA
        OPTIONS
            -DFFI_CONFIG_FILE=${CMAKE_CURRENT_LIST_DIR}/fficonfig.h
        OPTIONS_DEBUG
            -DFFI_SKIP_HEADERS=ON
    )

    vcpkg_install_cmake()
    vcpkg_copy_pdbs()
    vcpkg_fixup_cmake_targets()

    file(READ ${CURRENT_PACKAGES_DIR}/include/ffi.h FFI_H)
    string(REPLACE "/* *know* they are going to link with the static library. */"
    "/* *know* they are going to link with the static library. */

    #define FFI_BUILDING

    " FFI_H "${FFI_H}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/include/ffi.h "${FFI_H}")

else()
    if(0)
        vcpkg_find_acquire_program(PERL)
        get_filename_component(PERL_PATH ${PERL} DIRECTORY)
        vcpkg_add_to_path(${PERL_PATH})
        message(STATUS "Applying includedir patch")
        vcpkg_execute_required_process(
          COMMAND ${PERL} -pe \'s\#^includesdir = .*\#includesdir = \\\@includedir\\\@\#\' -i include/Makefile.in
          WORKING_DIRECTORY "${SOURCE_PATH}"
          LOGNAME "perl-${TARGET_TRIPLET}-all"
        )
        message(STATUS "Applying includedir patch - done")
    endif()

    vcpkg_configure_make(
        AUTOCONFIG
        SOURCE_PATH ${SOURCE_PATH}
    )

    vcpkg_install_make()

    if(0)
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
    else()
        file(COPY ${CURRENT_PACKAGES_DIR}/lib/libffi-3.1/include DESTINATION ${CURRENT_PACKAGES_DIR}/include)
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/libffi-3.1)
    endif()

    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/info/dir)
    vcpkg_fixup_pkgconfig_targets()
endif()


file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
