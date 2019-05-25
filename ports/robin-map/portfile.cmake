include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Tessil/robin-map
    REF 3285ed7615b72020bd68ba6d30f9ec0c0c526098
    SHA512 4da89ddedb8e9d153c40c20eca7b2532acac02e3c3de1dfcecbfb59cd9ae27db18b339ec9a6ff09194d38913a14aec5cabf4e9949ebbfdb3c1178420f3f080fa
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/tsl DESTINATION ${CURRENT_PACKAGES_DIR}/include)

file(INSTALL
    ${SOURCE_PATH}/LICENSE
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/robin-map
    RENAME copyright
)
