include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO martinmoene/byte-lite
    REF v0.2.0
    SHA512 eefc730a39453dfc367a4478a84d4825cd85721d3c332a57321d0a5c3040a4d45921603ff24220f968dd21df61acea856ae30db8bae6c1e835a1755fb03c84b7
)

file(INSTALL ${SOURCE_PATH}/include/nonstd/byte.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include/nonstd)
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/byte-lite RENAME copyright)
