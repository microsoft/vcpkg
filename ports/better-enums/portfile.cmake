vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aantron/better-enums
    REF 0.11.3
    SHA512 624baa2646a4141a1b326910f567d8a4799b72ee4cf569497940a877be2f035a19cf9a709f3bb64be7055175bd72c698d3f82df5bd47996eacbe6bbc2f4a42cd
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/enum.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/better-enums")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")