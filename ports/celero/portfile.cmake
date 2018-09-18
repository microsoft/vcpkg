include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DigitalInBlue/Celero
    REF v2.3.0
    SHA512 bc145f9823b1e4bc03f13da9b9af986d6cc151b1edfc01384c4e90bcf0488f867ec2bdc39733f263c7ddda526645dd11a7c6051c73eb8657bc4442b448732242
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" CELERO_COMPILE_DYNAMIC_LIBRARIES)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS
        -DCELERO_ENABLE_EXPERIMENTS=OFF
        -DCELERO_ENABLE_TESTS=OFF
        -DCELERO_RUN_EXAMPLE_ON_BUILD=OFF
        -DCELERO_COMPILE_DYNAMIC_LIBRARIES=${CELERO_COMPILE_DYNAMIC_LIBRARIES}
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH share)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

file(RENAME ${CURRENT_PACKAGES_DIR}/share/celero/celero-target.cmake ${CURRENT_PACKAGES_DIR}/share/celero/celero-config.cmake)

file(INSTALL ${SOURCE_PATH}/license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/celero RENAME copyright)
