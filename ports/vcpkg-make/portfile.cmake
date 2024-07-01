set(VCPKG_POLICY_CMAKE_HELPER_PORT enabled)

vcpkg_download_distfile(
    ar_lib_wrapper
    URLS https://raw.githubusercontent.com/autotools-mirror/automake/43a53bdf4b76377b5c012b8c8e8f478fb56d1ec0/lib/ar-lib
    FILENAME ar-lib
    SHA512 6019ffebf4b7b0547aa018c7d19bc915a228825d2acdee953a36919a88c30352e620f61c27a3e6f701af2885c8eb8d4ba3a4a3c2e821c54c03dceeef8eec108f
)
vcpkg_download_distfile(
    compile_wrapper
    URLS https://raw.githubusercontent.com/autotools-mirror/automake/43a53bdf4b76377b5c012b8c8e8f478fb56d1ec0/lib/compile
    FILENAME compile
    SHA512 3ef82f486f59be4cae1f1f95a9b70d4404f0333100be84c2e7061bd466201224a2bd1c7d871d97801eb9a441809bb47e7821fca8c85c29cc43ab15e6edda7f8c
)

file(COPY 
        "${CMAKE_CURRENT_LIST_DIR}/" 
    DESTINATION 
        "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)
file(COPY 
        "${ar_lib_wrapper}"
        "${compile_wrapper}"
    DESTINATION 
        "${CURRENT_PACKAGES_DIR}/share/${PORT}/wrappers"
)

file(REMOVE 
        "${CURRENT_PACKAGES_DIR}/share/${PORT}/portfile.cmake"
        "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg.json"
)

vcpkg_install_copyright(FILE_LIST "${VCPKG_ROOT_DIR}/LICENSE.txt")

