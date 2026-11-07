set(BRAZIER_LOGGER_VERSION "v0.1.1")
set(BRAZIER_LOGGER_SHA512 "728d52e8d851b42b7940a21cdbacf8876b30fbab9c3e488722da05d662630b25d6aea9a623568658ba9e117ab47f75065c3870975f312e3616aba2dafe61bc09")

set(BRAZIER_ORM_VERSION "v0.1.1")
set(BRAZIER_ORM_SHA512 "551423a68e30d2840f346e9e24367f0e6332070b4aa63a4925f1877ee1f26a7802ce386d110b3f24366900b7b71faf87e7f68ccd99a37ff33d6c27da8da8c4b2")

vcpkg_from_github(
    OUT_SOURCE_PATH CORE_SOURCE_PATH
    REPO brazier-tech/brazier
    REF "v${VERSION}"
    SHA512 ee9f07ebbeda537fbcf92a0e047bb72c5b9190b69b59e583f99b734f2fd145d1dca89013c1e2f8ff3b237345a6b1a3905524543644ddea4cf70a7b08962f22fb
    HEAD_REF master
)

if("logger" IN_LIST FEATURES)
    vcpkg_from_github(
        OUT_SOURCE_PATH LOGGER_SOURCE_PATH
        REPO brazier-tech/brazier-logger
        REF ${BRAZIER_LOGGER_VERSION}
        SHA512 ${BRAZIER_LOGGER_SHA512}
        HEAD_REF master
    )
endif()

if("orm" IN_LIST FEATURES)
    vcpkg_from_github(
        OUT_SOURCE_PATH ORM_SOURCE_PATH
        REPO brazier-tech/brazier-orm
        REF ${BRAZIER_ORM_VERSION}
        SHA512 ${BRAZIER_ORM_SHA512}
        HEAD_REF master
    )
endif()

if("logger" IN_LIST FEATURES)
    vcpkg_cmake_configure(SOURCE_PATH "${LOGGER_SOURCE_PATH}")
    vcpkg_cmake_install()
    vcpkg_cmake_config_fixup(CONFIG_PATH share/brazier-logger)
endif()

if("main" IN_LIST FEATURES)
    vcpkg_cmake_configure(
        SOURCE_PATH "${CORE_SOURCE_PATH}/brazier"
        OPTIONS
            -DBUILD_TESTS=OFF
            -DBUILD_APP=OFF
    )
    vcpkg_cmake_install()
    vcpkg_cmake_config_fixup(CONFIG_PATH share/brazier-core)
endif()

if("orm" IN_LIST FEATURES)
    vcpkg_cmake_configure(
        SOURCE_PATH "${ORM_SOURCE_PATH}/brazier-orm"
        OPTIONS
            -DBUILD_TESTS=OFF
            -DBUILD_DEMO=OFF
    )
    vcpkg_cmake_install()
    vcpkg_cmake_config_fixup(CONFIG_PATH share/brazier-orm)
endif()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE 
    "${CURRENT_PACKAGES_DIR}/debug/include" 
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/brazierConfig.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/brazier")

file(READ "${CMAKE_CURRENT_LIST_DIR}/vcpkg.json" _vcpkg_json)
string(JSON BRAZIER_VERSION GET "${_vcpkg_json}" "version")

file(READ "${CMAKE_CURRENT_LIST_DIR}/brazierConfigVersion.cmake.in" _ver_template)
string(REPLACE "@VERSION@" "${BRAZIER_VERSION}" _ver_content "${_ver_template}")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/brazier/brazierConfigVersion.cmake" "${_ver_content}")

vcpkg_install_copyright(FILE_LIST 
    "${CORE_SOURCE_PATH}/LICENSE" 
    "${CORE_SOURCE_PATH}/COPYING"
)