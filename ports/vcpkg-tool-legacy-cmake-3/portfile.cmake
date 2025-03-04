set(VCPKG_POLICY_CMAKE_HELPER_PORT enabled)

file(INSTALL
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg-port-config.cmake"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)

vcpkg_download_distfile(ARCHIVE_PATH
    URLS "https://gitlab.kitware.com/cmake/cmake/-/raw/v${VERSION}/Copyright.txt?ref_type=tags&inline=false"
    SHA512 20133e162759f39a7a614bd9278b616aa9af75673b1dc12a84156252b71be217acda98506d6e32f43f24438f8a1e9dd80d47e916a8ff2afd82ff99db68e978dc
    FILENAME "${PORT}-${VERSION}-Copyright.txt"
)

vcpkg_install_copyright(FILE_LIST "${ARCHIVE_PATH}")
