set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fungos/cr
    REF 1c3f8302320dee8206cf85d6aeb9e9a9cd78b527
    SHA512 05a36404d582969d9080fc0451af1e973c5560dea414827a8ba9c90aab7073827bd500e390843e7dc884a5e9bc601a92316922be0caeaacee2b47fa35a16a80e
    HEAD_REF master
)

file(
    COPY "${SOURCE_PATH}/cr/cr.h"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
