#header-only library
include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Forceflow/libmorton
    REF 797ea736dca49553a56089f143ee6d1effdd318e
    SHA512 ee9632f5c873462842d18014d4fd2d461e9fe767659e7426a7dec90fcc06cb974fb064229db5622c38ad0af9509004edea87e0f1d57ad09d8d1d236a5b9579a0
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libmorton)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libmorton/LICENSE ${CURRENT_PACKAGES_DIR}/share/libmorton/copyright)

file(GLOB HEADER_FILES ${SOURCE_PATH}/libmorton/include/*.h)
file(COPY ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/libmorton)
