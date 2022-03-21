vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO imfl/color-console
    REF 745f57141e6322e20cdda59a74ab1e00d107ade1
    SHA512 d4d919eb211f2981daf6b9af93262fc8ac89bac0db755ba30b31d6aa1b981e5383fb23ef95d1ff004606d138fee630fd790c72e92440b684306c6780750bd9fd
    HEAD_REF master
)

# Install source file
file(INSTALL ${SOURCE_PATH}/include/color.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include RENAME colorconsole.hpp)

# Install license
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

# Install usage
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})