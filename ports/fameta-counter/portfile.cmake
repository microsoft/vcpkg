vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO falemagn/fameta-counter
    REF 35f4421524b61eaa658c23e9c3667dc914df72fa
    SHA512 624baa2646a4141a1b326910f567d8a4799b72ee4cf569497940a877be2f035a19cf9a709f3bb64be7055175bd72c698d3f82df5bd47996eacbe6bbc2f4a42cd
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include/fameta/counter.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include/fameta-counter")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
