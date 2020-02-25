include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Tessil/robin-map
    REF 908ccf9f039a0e50813544c0444ca664ca292d7c # v0.6.2
    SHA512 cad7508bf902c763dc7fd53b13bfb82933b174bf8cd1a77686b1763e72692b8f211e3a5e8ae87d7796d3a4dd121b077231bd01bd61a609c1a4c8f456a8161174
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/include/tsl DESTINATION ${CURRENT_PACKAGES_DIR}/include)

file(INSTALL
    ${SOURCE_PATH}/LICENSE
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/robin-map
    RENAME copyright
)
