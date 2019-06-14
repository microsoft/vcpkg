# header-only library

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nemequ/simde
    REF 6e3ba90605361069cf3422c44242c79171b87275
    SHA512 d62ff40882c2b3a17c900104b36ae77137cbb77917d409cba1c0693fdcf317a38ff3184deaaecca0ef31d88393bebf0102a8ab57a23ad5d0cee2d3e5fe799f6a
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/simde DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
configure_file(${SOURCE_PATH}/COPYING ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
