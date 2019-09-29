include(vcpkg_common_functions)
# the working 9.0 alpha release has fixes to their nmake script that are needed, 8.6.9 has issues with configuration
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tcltk/tcl
    REF fb28af5fa6c4ffcd2d176c5617e5640acbfb8114
    SHA512 f58a0039eb6d48dc711675e5052e18c6a90e377afe02922ab3ba0cbd6655c85d01ae2d954698c6563d45672f700c97cddf1d165ca8bb6064e5aaf8c31c76856f)

if(VCPKG_TARGET_IS_WINDOWS)
    find_program(NMAKE nmake REQUIRED)

    if(VCPKG_TARGET_ARCHITECTURE MATCHES "x64")
        set(MACHINE_STR AMD64)
    else()
        set(MACHINE_STR IX86)
    endif()

    if(VCPKG_LIBRARY_LINKAGE MATCHES "static")
        set(STATIC_OPT ",static")
    endif()

    message(STATUS "Building ${TARGET_TRIPLET}-release")
    vcpkg_execute_required_process(
        COMMAND ${NMAKE} -f makefile.vc release OPTS=${STATIC_OPT} MACHINE=${MACHINE_STR}
        WORKING_DIRECTORY ${SOURCE_PATH}/win
        LOGNAME build-${TARGET_TRIPLET}-release
    )
    message(STATUS "Building ${TARGET_TRIPLET}-release done")
    message(STATUS "Building ${TARGET_TRIPLET}-debug")

    vcpkg_execute_required_process(
        COMMAND ${NMAKE} -f makefile.vc release OPTS=symbols${STATIC_OPT} MACHINE=${MACHINE_STR}
        WORKING_DIRECTORY ${SOURCE_PATH}/win
        LOGNAME build-${TARGET_TRIPLET}-debug
    )
    message(STATUS "Building ${TARGET_TRIPLET}-debug done")

    message(STATUS "Installing ${TARGET_TRIPLET}-debug")
    vcpkg_execute_required_process(
        COMMAND ${NMAKE} -f makefile.vc install INSTALLDIR=${CURRENT_PACKAGES_DIR}\\debug OPTS=symbols${STATIC_OPT} SCRIPT_INSTALL_DIR=${CURRENT_PACKAGES_DIR}\\tools\\tcl\\debug\\lib\\tcl9.0
        WORKING_DIRECTORY ${SOURCE_PATH}/win
        LOGNAME install-${TARGET_TRIPLET}-debug
    )

    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
    if(VCPKG_LIBRARY_LINKAGE MATCHES "dynamic")
        file(COPY ${CURRENT_PACKAGES_DIR}/debug/lib/dde1.4 DESTINATION ${CURRENT_PACKAGES_DIR}/tools/tcl/debug/lib)
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/dde1.4)
        file(COPY ${CURRENT_PACKAGES_DIR}/debug/lib/reg1.3 DESTINATION ${CURRENT_PACKAGES_DIR}/tools/tcl/debug/lib)
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/reg1.3)
        file(COPY ${CURRENT_PACKAGES_DIR}/debug/bin/tcl90g.dll DESTINATION ${CURRENT_PACKAGES_DIR}/tools/tcl/debug)
        file(COPY ${CURRENT_PACKAGES_DIR}/debug/bin/tclsh90g.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools/tcl/debug/bin)
        file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/tclsh90g.exe)
    else()
        file(COPY ${CURRENT_PACKAGES_DIR}/debug/bin/tclsh90sg.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools/tcl/debug/bin)
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
    endif()

    message(STATUS "Installing ${TARGET_TRIPLET}-debug done")

    message(STATUS "Installing ${TARGET_TRIPLET}-release")
    vcpkg_execute_required_process(
        COMMAND ${NMAKE} -f makefile.vc install INSTALLDIR=${CURRENT_PACKAGES_DIR} OPTS=${STATIC_OPT} SCRIPT_INSTALL_DIR=${CURRENT_PACKAGES_DIR}\\tools\\tcl\\lib\\tcl9.0
        WORKING_DIRECTORY ${SOURCE_PATH}/win
        LOGNAME install-${TARGET_TRIPLET}-release
    )

    if(VCPKG_LIBRARY_LINKAGE MATCHES "dynamic")
        file(COPY ${CURRENT_PACKAGES_DIR}/lib/dde1.4 DESTINATION ${CURRENT_PACKAGES_DIR}/tools/tcl/lib)
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/dde1.4)
        file(COPY ${CURRENT_PACKAGES_DIR}/lib/reg1.3 DESTINATION ${CURRENT_PACKAGES_DIR}/tools/tcl/lib)
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/reg1.3)
        file(COPY ${CURRENT_PACKAGES_DIR}/bin/tclsh90.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools/tcl/bin)
    else()
        file(COPY ${CURRENT_PACKAGES_DIR}/bin/tclsh90s.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools/tcl/bin)
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
    endif()
    vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/tcl/bin)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/tclsh90.exe)
    message(STATUS "Installing ${TARGET_TRIPLET}-release done")

    file(INSTALL ${SOURCE_PATH}/license.terms DESTINATION ${CURRENT_PACKAGES_DIR}/share/tcl RENAME copyright)
else()
    message(ERROR "Unsupported Operating System ${VCPKG_CMAKE_SYSTEM_NAME}")
endif()