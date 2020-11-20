# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zserge/jsmn
    REF fdcef3ebf886fa210d14956d3c068a653e76a24e
    SHA512 ec3a6b106b868238aa626e5b4477ace4414f385a35c695a583598975202b73a2a446143eb5f0ea73b0a84113c610ea36e64341fccecd1d1ddd9080e06f599575
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/jsmn.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
