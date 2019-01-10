include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ArashPartow/strtk
    REF b88797408e614ff5a127df12cc520bf41769ada6
    SHA512 3bb5bfc5f12f46180bc7751b865c5ef9120b3c8764ccc86ca2b4b344d6b9d1744e7bd45e9a9202fe4349f8ce75fbb0c37e807cb1e072f5aef28e790ec94646ca
)

file(COPY ${SOURCE_PATH}/strtk.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/copyright DESTINATION ${CURRENT_PACKAGES_DIR}/share/strtk)
