set(PACKAGE_NAME math)

ignition_modular_library(
    NAME "${PACKAGE_NAME}"
    REF "${PORT}_${VERSION}"
    VERSION "${VERSION}"
    SHA512 84617eeb6840b0bad8f94c38e8af11bf010c2e3166042541d0d79c44f60a70ee6fde395b2a1b801abedb36aa024f7fb14bbb993eb7be2949c72d8756ba4b3196
    OPTIONS
        -DSKIP_SWIG=ON
        -DSKIP_PYBIND11=ON
        -DBUILD_DOCS=OFF
)
