#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/GSL
    REF b74b286d5e333561b0f1ef1abd18de2606624455
    SHA512 5d2d9812fab638228eb8802df21d271bd94321f6174f1fa15a3d3a60dc742cdce1ee0701f2096625cca13df934b0d2511f9b4fcc0913780de234ac76403f2482
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/ms-gsl RENAME copyright)
