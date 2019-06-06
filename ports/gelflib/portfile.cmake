include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rastignacc/gelflib
    REF ea7e76b99c11c569a768ee95182b2a0a547cfbc6
    SHA512 dd83351ce441dc50a5a1b79508b95267ce02a6e6fefab277a5b5be9451854c15891b27b9e81fb63b232e7b4eabc32c488b36d7b751d46c9d48058b6e26ee3b94
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/gelflib RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(COPY ${SOURCE_PATH}/src/GELFConfig.hpp DESTINATION ${CURRENT_INSTALLED_DIR}/include)