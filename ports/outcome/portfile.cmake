# single header file

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ned14/outcome
    REF 525478ed519d7c3400d60110649c315d705a07ad #v2.1
    SHA512 cf05f7c09ced02fa5fe3d9ad6533358a2fb63e31b5d5be81c16c285250cd275467217b8f9364b4ff1947d8c4aa6a86e10cef310d8475dcd9f7a0a713f1a01c8e
    HEAD_REF develop
)

file(GLOB_RECURSE OUTCOME_HEADERS "${SOURCE_PATH}/single-header/*.hpp")
file(INSTALL  ${OUTCOME_HEADERS} DESTINATION ${CURRENT_PACKAGES_DIR}/include)

file(INSTALL ${SOURCE_PATH}/Licence.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)