include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ArashPartow/strtk
    REF 1e2960fd55918532dd96aed6a4b9cc6ee8f2e3c5
    SHA512 89b3d40dbdf66a21a38005f3d878e039f2e59c378aac13077ce183b495e903aeebd5f99ce4fbb892cf69503e5e7bf560498e65769f2f67d722262c0cf22fe74e
)

file(COPY ${SOURCE_PATH}/strtk.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/copyright DESTINATION ${CURRENT_PACKAGES_DIR}/share/strtk)
