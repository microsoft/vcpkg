
function(ignition_modular_build_library NAME MAJOR_VERSION SOURCE_PATH CMAKE_PACKAGE_NAME DEFAULT_CMAKE_PACKAGE_NAME IML_DISABLE_PKGCONFIG_INSTALL)
    vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        PREFER_NINJA
        DISABLE_PARALLEL_CONFIGURE
        OPTIONS -DBUILD_TESTING=OFF
    )

    vcpkg_install_cmake(ADD_BIN_TO_PATH)

    # If necessary, move the CMake config files
    if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/cmake")
        # Some ignition libraries install library subcomponents, that are effectively additional cmake packages
        # with name ${CMAKE_PACKAGE_NAME}-${COMPONENT_NAME}, so it is needed to call vcpkg_fixup_cmake_targets for them as well
        file(GLOB COMPONENTS_CMAKE_PACKAGE_NAMES
             LIST_DIRECTORIES TRUE
             RELATIVE "${CURRENT_PACKAGES_DIR}/lib/cmake/"
             "${CURRENT_PACKAGES_DIR}/lib/cmake/*")

        foreach(COMPONENT_CMAKE_PACKAGE_NAME IN LISTS COMPONENTS_CMAKE_PACKAGE_NAMES)
            vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/${COMPONENT_CMAKE_PACKAGE_NAME}"
                                      TARGET_PATH "share/${COMPONENT_CMAKE_PACKAGE_NAME}"
                                      DO_NOT_DELETE_PARENT_CONFIG_PATH)
        endforeach()

        file(GLOB_RECURSE CMAKE_RELEASE_FILES
                          "${CURRENT_PACKAGES_DIR}/lib/cmake/${CMAKE_PACKAGE_NAME}/*")

        file(COPY ${CMAKE_RELEASE_FILES} DESTINATION
                  "${CURRENT_PACKAGES_DIR}/share/${CMAKE_PACKAGE_NAME}/")
    endif()

    # Remove unused files files
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/cmake
                        ${CURRENT_PACKAGES_DIR}/debug/include
                        ${CURRENT_PACKAGES_DIR}/debug/lib/cmake
                        ${CURRENT_PACKAGES_DIR}/debug/share)

    # Make pkg-config files relocatable
    if(NOT IML_DISABLE_PKGCONFIG_INSTALL)
        if(VCPKG_TARGET_IS_LINUX)
            set(SYSTEM_LIBRARIES SYSTEM_LIBRARIES pthread)
        endif()
        vcpkg_fixup_pkgconfig(${SYSTEM_LIBRARIES})
    else()
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/pkgconfig
                            ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig)
    endif()

    # Find the relevant license file and install it
    if(EXISTS "${SOURCE_PATH}/LICENSE")
        set(LICENSE_PATH "${SOURCE_PATH}/LICENSE")
    elseif(EXISTS "${SOURCE_PATH}/README.md")
        set(LICENSE_PATH "${SOURCE_PATH}/README.md")
    endif()
    file(INSTALL ${LICENSE_PATH} DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
endfunction()

## # ignition_modular_library
##
## Download and build a library from the Ignition Robotics project ( https://ignitionrobotics.org/ ).
##
## ## Usage:
## ```cmake
## ignition_modular_library(NAME <name>
##                          VERSION <version>
##                          SHA512 <sha512>
##                          [REF <ref>]
##                          [HEAD_REF <head_ref>]
##                          [PATCHES <patches>]
##                          [CMAKE_PACKAGE_NAME <cmake_package_name>]
##                          [DISABLE_PKGCONFIG_INSTALL])
## ```
##
## ## Parameters:
## ### NAME
## The name of the specific ignition library, i.e. `cmake` for `ignition-cmake0`, `math` for `ignition-math4`.
##
## ### VERSION
## The complete version number.
##
## ### SHA512
## The SHA512 hash that should match the downloaded  archive. This is forwarded to the `vcpkg_from_github` command.
##
## ### REF
## Reference to the tag of the desired release. This is forwarded to the `vcpkg_from_github` command.
## If not specified, defaults to `ignition-${NAME}${MAJOR_VERSION}_${VERSION}`.
##
## ### HEAD_REF
## Reference (tag) to the desired release. This is forwarded to the `vcpkg_from_github` command.
## If not specified, defaults to `ign-${NAME}${MAJOR_VERSION}`.
##
## ### PATCHES
## A list of patches to be applied to the extracted sources.
## This is forwarded to the `vcpkg_from_github` command.
##
## ### CMAKE_PACKAGE_NAME
## The name of the CMake package for the port.
## If not specified, defaults to `ignition-${NAME}${MAJOR_VERSION}`.
##
## ### DISABLE_PKGCONFIG_INSTALL
## If present, disable installation of .pc pkg-config configuration files.
##
##
## ## Examples:
##
## * [ignition-cmake0](https://github.com/Microsoft/vcpkg/blob/master/ports/ignition-cmake0/portfile.cmake)
## * [ignition-math4](https://github.com/Microsoft/vcpkg/blob/master/ports/ignition-math4/portfile.cmake)
## * [ignition-fuel-tools1](https://github.com/Microsoft/vcpkg/blob/master/ports/ignition-fuel-tools1/portfile.cmake)
function(ignition_modular_library)
    set(options DISABLE_PKGCONFIG_INSTALL)
    set(oneValueArgs NAME VERSION SHA512 REF HEAD_REF CMAKE_PACKAGE_NAME)
	set(multiValueArgs PATCHES)
    cmake_parse_arguments(IML "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    string(REPLACE "." ";" IML_VERSION_LIST ${IML_VERSION})
    list(GET IML_VERSION_LIST 0 IML_MAJOR_VERSION)

    # If the REF option is omitted, use the canonical one
    if(NOT DEFINED IML_REF)
        set(IML_REF "ignition-${IML_NAME}${IML_MAJOR_VERSION}_${IML_VERSION}")
    endif()

    # If the HEAD_REF option is omitted, use the canonical one
    if(NOT DEFINED IML_HEAD_REF)
        set(IML_HEAD_REF "ign-${IML_NAME}${IML_MAJOR_VERSION}")
    endif()

    # If the CMAKE_PACKAGE_NAME option is omitted, use the canonical one
    set(DEFAULT_CMAKE_PACKAGE_NAME "ignition-${IML_NAME}${IML_MAJOR_VERSION}")
    if(NOT DEFINED IML_CMAKE_PACKAGE_NAME)
        set(IML_CMAKE_PACKAGE_NAME ${DEFAULT_CMAKE_PACKAGE_NAME})
    endif()

    # Download library from github, to support also the --head option
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO ignitionrobotics/ign-${IML_NAME}
        REF ${IML_REF}
        SHA512 ${IML_SHA512}
        HEAD_REF ${IML_HEAD_REF}
        PATCHES ${IML_PATCHES}
    )

    # Build library
    ignition_modular_build_library(${IML_NAME} ${IML_MAJOR_VERSION} ${SOURCE_PATH} ${IML_CMAKE_PACKAGE_NAME} ${DEFAULT_CMAKE_PACKAGE_NAME} ${IML_DISABLE_PKGCONFIG_INSTALL})
endfunction()
