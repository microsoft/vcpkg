vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO JustasMasiulis/xorstr
    REF 42464c4fc1c32cb0d15f3656b30bfb38d9b65fc7
    SHA512 e8d6ed2ed64bbd11ca304b6c8a6c2dd14544cedc8b8f7364ef8c34af374ebee76bfddd97258b7ff024f6d9929800158d1b3897d64c2b74d8c6f6f105d2844a1c
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/include/xorstr.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include)

configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
