if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cycfi/elements
    REF e2c891bb37b506e3281b902fc0fcc75a5577e476
    SHA512 3f54c3dcf3fab17eca6a6105f0e77a28a1b77d6354dac12c373c7da84d280abdc8d5bcbe9c42bbc3e38284acbfeb57392ef2538ef7118dd5c34cae29a4e88855
    HEAD_REF master
    PATCHES
        asio-headers.patch
        win-find-libraries.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH INFRA_SOURCE_PATH
    REPO cycfi/infra
    REF 6bc1cc62e3d0a31f92506a577beca3b400b54544
    SHA512 ceb5acb36210b4fcf4ef3931e718ae1cb09941cc61caab1d20d09003bae2b20fda092e4b1af1bb58444de75f73c04d0651eb5126a87dab7ce14a1b914bccec27
    HEAD_REF master
)
if(NOT EXISTS "${SOURCE_PATH}/lib/infra/CMakeLists.txt")
    file(REMOVE_RECURSE "${SOURCE_PATH}/lib/infra")
    file(RENAME "${INFRA_SOURCE_PATH}" "${SOURCE_PATH}/lib/infra")
endif()


if(VCPKG_TARGET_IS_WINDOWS)
    set(ELEMENTS_HOST_UI_LIBRARY "win32")
elseif(VCPKG_TARGET_IS_OSX)
    set(ELEMENTS_HOST_UI_LIBRARY "cocoa")
else()
    set(ELEMENTS_HOST_UI_LIBRARY "gtk")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DELEMENTS_BUILD_EXAMPLES=OFF
        -DELEMENTS_HOST_UI_LIBRARY=${ELEMENTS_HOST_UI_LIBRARY}
)

vcpkg_cmake_build()

file(INSTALL "${SOURCE_PATH}/lib/include/elements.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(INSTALL "${SOURCE_PATH}/lib/include/elements" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(INSTALL "${SOURCE_PATH}/lib/infra/include/infra" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    file(GLOB ELEMENTS_LIBS "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/lib/*elements*")
    file(INSTALL ${ELEMENTS_LIBS} DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
endif()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(GLOB ELEMENTS_LIBS "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/lib/*elements*")
    file(INSTALL ${ELEMENTS_LIBS} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/README.md")
