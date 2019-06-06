include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ArashPartow/strtk
    REF c6168dda1deed942b2fbfde9d80f53049fa79f20
    SHA512 7595f412838e86d4b7cf0ca3da4dc8aebe40011fb29058e1ee42e23923fbbadeb9a2d0fceac3362b2d0a228ff86c111457f9204b533edb8e0379f3022976906e
)

file(COPY ${SOURCE_PATH}/strtk.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/copyright DESTINATION ${CURRENT_PACKAGES_DIR}/share/strtk)
