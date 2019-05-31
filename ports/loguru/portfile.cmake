include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO emilk/loguru
    REF v2.0.0
    SHA512 d6358f843689d10a44dc7bf590305cbfb89727e26d971ca4fe439e5468cdb7bcee2aa858368250e9654fb5ecebf63bca9742451881dae78068fecb18f279d988
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/loguru.hpp  DESTINATION ${CURRENT_PACKAGES_DIR}/include/loguru)
file(COPY ${CURRENT_PORT_DIR}/copyright DESTINATION ${CURRENT_PACKAGES_DIR}/share/loguru)