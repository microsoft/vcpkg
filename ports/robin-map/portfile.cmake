include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Tessil/robin-map
    REF 3285ed7615b72020bd68ba6d30f9ec0c0c526098
    SHA512 3850a0ea06f62ba177a1746a92a3f9c999f6398d4d786dbc63dd276569e77e3d9c15e83c0cb74a1314e3c2b5ff73225675d914cf4ab3f052353b237ab9219bc8
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/include/tsl DESTINATION ${CURRENT_PACKAGES_DIR}/include)

file(INSTALL
    ${SOURCE_PATH}/LICENSE
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/robin-map
    RENAME copyright
)
