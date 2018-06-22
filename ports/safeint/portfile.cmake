include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dcleblanc/SafeInt
    REF 3.19.2
    SHA512 a8687ce65d02d113e5b64e1de3bbd3f426c2a2fee98499c8d36eec8611bf3cc43b2afc2f10faded15abf3966f245dac3318391ed28acff0171f5a987a888c3a2
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/SafeInt.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include/)

file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/safeint RENAME copyright)
