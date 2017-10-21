include(vcpkg_common_functions)
find_program(GIT git)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/cppwinrt-spring_2017_creators_update_for_vs_15.3)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/Microsoft/cppwinrt/archive/spring_2017_creators_update_for_vs_15.3.tar.gz"
    FILENAME "cppwinrt-spring_2017_creators_update_for_vs_15.3.tar.gz"
    SHA512  779586122552e49a79aff08f4476905e00c3b4ad3dbc502240e9a7cc59ec0e4ab6304149a66505923ab84d2b334059de9e18c84a5b0ed6bde106d19119ef911f
)
vcpkg_extract_source_archive(${ARCHIVE})

# Put the licence file where vcpkg expects it
file(COPY ${SOURCE_PATH}/license DESTINATION ${CURRENT_PACKAGES_DIR}/share/cppwinrt/license.txt)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/cppwinrt/license.txt ${CURRENT_PACKAGES_DIR}/share/cppwinrt/copyright)

# Copy the cppwinrt header files
file(GLOB HEADER_FILES ${SOURCE_PATH}/10.0.15063.0/winrt/*)
file(COPY ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/winrt)
