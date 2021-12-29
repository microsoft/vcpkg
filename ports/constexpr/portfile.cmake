#header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO elbeno/constexpr
    REF a98b1db39c909e0130d21d3910d4faf97035a625
    SHA512 8802ee43b510ea1f0c00949eecd84eb2bf3ac721802e6bc6755db9e6e2742d8b97fef427eca7d4d9a282c60a18ca10401386022eac995bd22624f45e3fc2c370
    HEAD_REF master
)

# Put the licence file where vcpkg expects it
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/constexpr/LICENSE)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/constexpr/LICENSE ${CURRENT_PACKAGES_DIR}/share/constexpr/copyright)

# Copy the constexpr header files
file(GLOB HEADER_FILES ${SOURCE_PATH}/src/include/*.h)
file(COPY ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include)
