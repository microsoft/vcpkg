include(vcpkg_common_functions)

vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Milerius/shiva
        REF 0.7.2
        SHA512 0bd1543ba6067d303640820a17a24ec02c6ab8333f86bd3431c09f5a2ea4ca47379ec06a90e3a0658dba967504cb8a63f85c2f0cbfb51a7c59130b235948d600
        HEAD_REF master
	)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
          -DSHIVA_BUILD_TESTS=OFF -DSHIVA_USE_SFML_AS_RENDERER=ON -DSHIVA_INSTALL_PLUGINS=ON
          
)

vcpkg_install_cmake()


if (VCPKG_CMAKE_SYSTEM_NAME)
  file(GLOB PLUGINS ${SOURCE_PATH}/bin/systems/*)
else()
  file(GLOB PLUGINS ${SOURCE_PATH}/bin/systems/*.dll)
endif()
message(STATUS "PLUGINS -> ${PLUGINS}")
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/shiva-sfml)


if (VCPKG_CMAKE_SYSTEM_NAME)
  set(SUFFIX_BINARY lib)
else()
  set(SUFFIX_BINARY bin)
endif()
##! Pre removing
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/${SUFFIX_BINARY})

##! Include
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/include)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/include/shiva-sfml)

##! Release
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/${SUFFIX_BINARY})
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/${SUFFIX_BINARY}/shiva)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/${SUFFIX_BINARY}/shiva/plugins)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/${SUFFIX_BINARY}/shiva/plugins/shiva-sfml)

##! Debug
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/${SUFFIX_BINARY})
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/${SUFFIX_BINARY}/shiva)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/${SUFFIX_BINARY}/shiva/plugins)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/${SUFFIX_BINARY}/shiva/plugins/shiva-sfml)

##! Copy Plugins
file(COPY ${PLUGINS} DESTINATION ${CURRENT_PACKAGES_DIR}/${SUFFIX_BINARY}/shiva/plugins/shiva-sfml)
file(COPY ${PLUGINS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/${SUFFIX_BINARY}/shiva/plugins/shiva-sfml)

file(WRITE ${CURRENT_PACKAGES_DIR}/include/shiva-sfml/empty.h "")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/shiva-sfml/copyright "")
