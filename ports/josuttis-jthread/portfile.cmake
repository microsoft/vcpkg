# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO josuttis/jthread
    REF 3e1908f3bbaba6d2195bb423840c23e107c9e8b2
    SHA512 b6e4df35b364848a433eb31023a8b5b5045b2445aaf9a81406a6b3ce7cfdda08bcdb486be9201f5b1e54df38884c1763fae336fdcb9ad79f11658a92c535055d
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/source/jthread.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/source/stop_token.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/source/condition_variable_any2.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include)

file(INSTALL ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
