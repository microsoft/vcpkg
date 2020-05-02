include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ArashPartow/exprtk
    REF 15b77a667b06d5bd82db01e0f4c773dd7cce9a97
    SHA512 14fdc2420ab8cb0c1552d91251822f873fe7485a2fbf49376261638c6b0a4d2b24ceeeff0692d2cc8e8b78efb13ab886d65f0bebe1efc2348a95c6dc19c98f73
)

file(COPY ${SOURCE_PATH}/exprtk.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/copyright DESTINATION ${CURRENT_PACKAGES_DIR}/share/exprtk)
