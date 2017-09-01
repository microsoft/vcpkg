include(vcpkg_common_functions)
find_program(GIT git)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/cppwinrt-spring_2017_creators_update_for_vs_15.3)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/Microsoft/cppwinrt/archive/spring_2017_creators_update_for_vs_15.3.tar.gz"
    FILENAME "cppwinrt-spring_2017_creators_update_for_vs_15.3.tar.gz"
    SHA512 6b8646270f69e3ebec13ed5fb46ed92236659d05
)
vcpkg_extract_source_archive(${ARCHIVE})

# Put the licence file where vcpkg expects it
file(COPY ${SOURCE_PATH}/license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/cppwinrt/license.txt)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/cppwinrt/license.txt ${CURRENT_PACKAGES_DIR}/share/cppwinrt/copyright)

# Copy the cppwinrt header files
file(GLOB HEADER_FILES ${SOURCE_PATH}/10.0.14393.0/winrt/*)
file(COPY ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/winrt)
