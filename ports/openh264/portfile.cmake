vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cisco/openh264
    REF v${VERSION}
    SHA512 caa52cbc73e9b6096c5ba4066d85d34ea63e81573c36d06ccd3f54ba34d95b133b5c507fc6e1ba81552673de01bed50c35de4b90428b4da9942ade442bd47a13
    PATCHES
        001-add-bsds-to-meson.patch
)

set(cxx_link_libraries "")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    block(PROPAGATE cxx_link_libraries)
        vcpkg_list(APPEND VCPKG_CMAKE_CONFIGURE_OPTIONS "-DVCPKG_DEFAULT_VARS_TO_CHECK=CMAKE_C_IMPLICIT_LINK_LIBRARIES;CMAKE_CXX_IMPLICIT_LINK_LIBRARIES")
        vcpkg_cmake_get_vars(cmake_vars_file)
        include("${cmake_vars_file}")
        list(REMOVE_ITEM VCPKG_DETECTED_CMAKE_CXX_IMPLICIT_LINK_LIBRARIES ${VCPKG_DETECTED_CMAKE_C_IMPLICIT_LINK_LIBRARIES})
        list(TRANSFORM VCPKG_DETECTED_CMAKE_CXX_IMPLICIT_LINK_LIBRARIES REPLACE "^([^/].*)" "-l\\1")
        string(JOIN " " cxx_link_libraries ${VCPKG_DETECTED_CMAKE_CXX_IMPLICIT_LINK_LIBRARIES})
    endblock()
endif()

vcpkg_list(SET additional_binaries)
if((VCPKG_TARGET_ARCHITECTURE STREQUAL "x86" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "x64"))
    vcpkg_find_acquire_program(NASM)
    vcpkg_list(APPEND additional_binaries "nasm = ['${NASM}']")
elseif(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_find_acquire_program(GASPREPROCESSOR)
    list(JOIN GASPREPROCESSOR "','" gaspreprocessor)
    vcpkg_list(APPEND additional_binaries "gas-preprocessor.pl = ['${gaspreprocessor}']")
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dtests=disabled
    ADDITIONAL_BINARIES
        ${additional_binaries}
)
vcpkg_install_meson()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

if(cxx_link_libraries)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/openh264.pc"
        "(Libs:[^\r\n]*)"
        "\\1 ${cxx_link_libraries}"
        REGEX
    )
    if(NOT VCPKG_BUILD_TYPE)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/openh264.pc"
            "(Libs:[^\r\n]*)"
            "\\1 ${cxx_link_libraries}"
            REGEX
        )
    endif()
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
