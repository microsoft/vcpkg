vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yhirose/cpp-httplib
    REF v0.5.1
    SHA512 808ad4a9b4d2a6d25eb342985a9d2407c252b6cdf85da2372b7426338c59ccaf49b2a04a4aa1cb0c97487ab8ec6ab5c098e1785edcccd94296488539af6ba1ef
    HEAD_REF master
)

file(
    COPY ${SOURCE_PATH}/httplib.h
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/cpp-httplib RENAME copyright)
