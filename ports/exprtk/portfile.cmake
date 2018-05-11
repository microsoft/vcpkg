include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ArashPartow/exprtk
    REF 46877b604cfcc0a0e592fc7a8a874cf2a9f90cf4
    SHA512 1043b5b6aa64bc3f8d989d2aac3e3a125188b1526ab92e245ad526ab1fe37e10cb275f2b77d311b4d91bd4ea32e1d81dfcd8abf8373b723a8b664842690ee1ae
)

file(COPY ${SOURCE_PATH}/exprtk.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/copyright DESTINATION ${CURRENT_PACKAGES_DIR}/share/exprtk)
