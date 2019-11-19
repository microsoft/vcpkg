include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yhirose/cpp-httplib
    REF v0.2.5
    SHA512 2b898acb0534517386d14ffa8c2d4640e27cdbbb7ed627a29c289a3012348950bbe1c64711315e8d8654688ab447735d73b9c03be39caaf10e783f612f65e31a
    HEAD_REF master
)

file(
    COPY ${SOURCE_PATH}/httplib.h
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)

# Handle copyright
configure_file(
    ${SOURCE_PATH}/LICENSE
    ${CURRENT_PACKAGES_DIR}/share/cpp-httplib/copyright
    COPYONLY
)
