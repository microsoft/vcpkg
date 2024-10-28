set(PACKAGE_NAME math)

ignition_modular_library(
    NAME "${PACKAGE_NAME}"
    REF "${PORT}_${VERSION}"
    VERSION "${VERSION}"
    SHA512 6d6e7c298f927110060882457f4ea379292f013b577f83a3a6f1fd68fc9cd7ea0bbef82cc0b9279373ab7af6e66f6ea2d8995669fa7d6d1fff13f8b8c857a6ed
    OPTIONS
        -DSKIP_SWIG=ON
        -DSKIP_PYBIND11=ON
        -DBUILD_DOCS=OFF
)
