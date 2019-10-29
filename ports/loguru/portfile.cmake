include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO emilk/loguru
    REF 9c2fea0d4530657f23259be4132f8101c98b579e # v2.1.0
    SHA512 49eebf8648f9d29273af76dca0a4e49155daa3664e98979df005e64eb0fa9f4eeb4228245327d469772c51076571acbe39a644eba531444d8676d9709a7e3914
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/loguru.hpp  DESTINATION ${CURRENT_PACKAGES_DIR}/include/loguru)
file(COPY ${CURRENT_PORT_DIR}/copyright DESTINATION ${CURRENT_PACKAGES_DIR}/share/loguru)