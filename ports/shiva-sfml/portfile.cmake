include(vcpkg_common_functions)

vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Milerius/shiva
        REF 0.7
        SHA512 08591ce23ef717330c2fdc0518c383bebeda1a5eed93011b44280a409154729add70a0e913c2dae0d8332f4d6aee931ab8ba9957097435eadcff38e692e348ec
        HEAD_REF master
	)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
          -DSHIVA_BUILD_TESTS=OFF -DSHIVA_USE_SFML_AS_RENDERER=ON -DSHIVA_INSTALL_PLUGINS=ON
          
)

vcpkg_install_cmake()

file(GLOB PLUGINS ${SOURCE_PATH}/bin/systems/*)
message(STATUS "PLUGINS -> ${PLUGINS}")
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/shiva-sfml)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/include)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/lib)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/include/shiva-sfml)
file(COPY ${PLUGINS} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(WRITE ${CURRENT_PACKAGES_DIR}/include/shiva-sfml/empty.h "")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/shiva-sfml/copyright "")
