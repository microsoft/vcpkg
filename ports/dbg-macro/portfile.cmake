# single header file library

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sharkdp/dbg-macro
    REF 4409d8428baf700873bcfee42e63bbca6700b97e
    SHA512 f9f936707631bee112566a24c92cbf171e54362099df689253ab38d0489400f65c284df81749376f18cb3ebcefea3cc18844554016798c2542ec73dc2afcc931
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/dbg.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
