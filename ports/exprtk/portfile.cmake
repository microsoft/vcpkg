include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ArashPartow/exprtk
    REF 7ccb123e9e79bc3df30a66c0bffe921d195702d7
    SHA512 75b6adaa254060053f56e3978be3e10847c9dae22f675eae728cb0c7fd9a5e6fee8c8278764826e0e0be3bcb2cfd2288e091d0f965ac2e331403683f15764b92
)

file(COPY ${SOURCE_PATH}/exprtk.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/copyright DESTINATION ${CURRENT_PACKAGES_DIR}/share/exprtk)
