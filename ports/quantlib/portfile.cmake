vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lballabio/QuantLib
    REF "v${VERSION}"
    SHA512 42a504d0bdce89709a8f3ebcf9b79433ca1629a0281c75e7c948808ede012166b89fbfa0a50345c330e106a2239e5e4cc5dfcf9912ace8a90aeb8be3ed6bcfff
    HEAD_REF master
)

if (VCPKG_TARGET_IS_WINDOWS)
    # This can (and should) be removed if QuantLib ever supports dynamically linking on Windows
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DQL_BUILD_EXAMPLES=OFF
        -DQL_BUILD_TEST_SUITE=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME QuantLib CONFIG_PATH lib/cmake/QuantLib)
vcpkg_fixup_pkgconfig()
if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    foreach(config IN ITEMS "" "/debug")
        set(pkgconfig_file "${CURRENT_PACKAGES_DIR}${config}/lib/pkgconfig/quantlib.pc")
        if(EXISTS "${pkgconfig_file}")
            file(GLOB quantlib_libraries "${CURRENT_PACKAGES_DIR}${config}/lib/QuantLib*.lib")
            list(GET quantlib_libraries 0 quantlib_library)
            get_filename_component(quantlib_library_name "${quantlib_library}" NAME_WE)
            vcpkg_replace_string("${pkgconfig_file}" "-lQuantLib" "-l${quantlib_library_name}")
        endif()
    endforeach()
endif()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Remove the "bin" directories if we are building static libraries
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

# Install custom usage
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" @ONLY)

vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/LICENSE.TXT"
    "${SOURCE_PATH}/ql/math/optimization/lmdif.cpp"
    "${SOURCE_PATH}/ql/math/randomnumbers/mt19937uniformrng.cpp"
)
