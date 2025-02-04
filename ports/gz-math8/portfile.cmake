set(PACKAGE_NAME math)

ignition_modular_library(
    NAME "${PACKAGE_NAME}"
    REF "${PORT}_${VERSION}"
    VERSION "${VERSION}"
    SHA512 73fd84ab4d8dea5cdd0fdc33479681cfe0125c6ad9d79ef1a53deb7c0592bc23f6d50984b111957cc0eb575b6e7f3f505b5b1810eb760ab839c16bdcebe45376
    OPTIONS
        -DSKIP_SWIG=ON
        -DSKIP_PYBIND11=ON
        -DBUILD_DOCS=OFF
)
