vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO JustasMasiulis/xorstr
    REF 3ef854178f3df03c94b83308000ed06760dcc8aa
    SHA512 c7599991d819a7bd253e763ecccb270d0c94642e52dda225d986bcc603bef9a5eecdb01bd87bd96c3320152c22f2d1d3312e84ac10b2020aa36a4229f230d7d8
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include/xorstr.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
