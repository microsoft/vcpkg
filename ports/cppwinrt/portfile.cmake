include(vcpkg_common_functions)
find_program(GIT git)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/cppwinrt-february_2017_refresh)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/Microsoft/cppwinrt/archive/february_2017_refresh.tar.gz"
    FILENAME "cppwinrt-february_2017_refresh.tar.gz"
    SHA512 0e2ed94d65ae4c7297ae4d82d64a43fa59fac7b35fbe42ea939f135f0f6eb867f57fac70b6a9cc9a78912de75aa4482d48007f83a3781b147d237ae637fdaa0e
)
vcpkg_extract_source_archive(${ARCHIVE})

# Put the licence file where vcpkg expects it
file(COPY ${SOURCE_PATH}/license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/cppwinrt/license.txt)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/cppwinrt/license.txt ${CURRENT_PACKAGES_DIR}/share/cppwinrt/copyright)

# Copy the cppwinrt header files
file(GLOB HEADER_FILES ${SOURCE_PATH}/10.0.14393.0/winrt/*)
file(COPY ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/winrt)
