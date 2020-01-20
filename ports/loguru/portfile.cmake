include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO emilk/loguru
    REF v2.1.0
    SHA512 3458e5381449aec53995f7d1e993bd807dd7a94c912262212ed9bfc4df9e219b4acfc97ea4cbffc55e615e34622545c706217492f88aaecb411d67869f06f0bb
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/loguru.hpp  DESTINATION ${CURRENT_PACKAGES_DIR}/include/loguru)
file(INSTALL ${SOURCE_PATH}/loguru.cpp  DESTINATION ${CURRENT_PACKAGES_DIR}/include/loguru)
file(COPY ${CURRENT_PORT_DIR}/copyright DESTINATION ${CURRENT_PACKAGES_DIR}/share/loguru)