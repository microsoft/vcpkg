cmake_minimum_required(VERSION 3.10)

project(sqlite3 C CXX)

option(WITH_ZLIB "Build sqlite3 with zlib support" OFF)
option(SQLITE3_SKIP_TOOLS "Disable build sqlite3 executable" OFF)

set(PKGCONFIG_LIBS_PRIVATE "")
set(PKGCONFIG_REQUIRES_PRIVATE "")

# Renamed the main sqlite3 library target to 'libsqlite3' to avoid LNK1149 error on Windows.
# Explicitly set as STATIC, which is common for Vcpkg's default triplet linkage.
add_library(libsqlite3 STATIC sqlite3.c sqlite3.rc)

target_include_directories(libsqlite3 PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}> $<INSTALL_INTERFACE:include>)

target_compile_definitions(
    libsqlite3
    PRIVATE
        $<$<CONFIG:Debug>:SQLITE_DEBUG=1>
        $<$<CONFIG:Debug>:SQLITE_ENABLE_SELECTTRACE>
        $<$<CONFIG:Debug>:SQLITE_ENABLE_WHERETRACE>
        $<$<COMPILE_LANGUAGE:RC>:RC_VERONLY>
)

if (BUILD_SHARED_LIBS)
    if (WIN32)
        target_compile_definitions(libsqlite3 PRIVATE "SQLITE_API=__declspec(dllexport)")
    else()
        target_compile_definitions(libsqlite3 PRIVATE "SQLITE_API=__attribute__((visibility(\"default\")))")
    endif()
endif()

if (NOT WIN32)
    find_package(Threads REQUIRED)
    target_link_libraries(libsqlite3 PRIVATE Threads::Threads ${CMAKE_DL_LIBS})
    string(APPEND PKGCONFIG_LIBS_PRIVATE " -pthread")
    foreach(LIB IN LISTS CMAKE_DL_LIBS)
        string(APPEND PKGCONFIG_LIBS_PRIVATE " -l${LIB}")
    endforeach()

    if(SQLITE_ENABLE_FTS5 OR SQLITE_ENABLE_MATH_FUNCTIONS)
        find_library(HAVE_LIBM m)
        if(HAVE_LIBM)
            target_link_libraries(libsqlite3 PRIVATE m)
            string(APPEND PKGCONFIG_LIBS_PRIVATE " -lm")
        endif()
    endif()
endif()

if(SQLITE_ENABLE_ICU)
    # Find ICU components uc (common) and i18n (internationalization).
    # The 'data' component often doesn't create a findable 'ICU::data' imported target
    # in some Vcpkg configurations, so we will find its library file directly.
    find_package(ICU COMPONENTS uc i18n REQUIRED)

    # Manually find the icudata library file, which is often a separate static archive.
    # VCPKG_ROOT_DIR and VCPKG_TARGET_TRIPLET are Vcpkg-specific variables.
    find_library(ICUDATA_LIBRARY NAMES icudata
                 PATHS ${VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/lib
                       ${VCPKG_ROOT_DIR}/installed/${VCPKG_TARGET_TRIPLET}/debug/lib
                 NO_DEFAULT_PATH)

    if(NOT ICUDATA_LIBRARY)
        # This error indicates a problem with the ICU installation or Vcpkg environment
        # if the data library cannot be found.
        message(FATAL_ERROR "ICU data library (libicudata) not found for linking. "
                            "It should be installed by the ICU vcpkg port.")
    endif()

    # Link the main libsqlite3 with ICU components and the explicitly found icudata library.
    target_link_libraries(libsqlite3 PRIVATE ICU::uc ICU::i18n ${ICUDATA_LIBRARY})

    # Update pkgconfig requires: Exclude "icu-data" because the ICU vcpkg port
    # typically does not provide an 'icu-data.pc' file, which would cause pkg-config validation errors.
    string(APPEND PKGCONFIG_REQUIRES_PRIVATE " icu-uc icu-i18n")
endif()

if(NOT SQLITE3_SKIP_TOOLS)
    add_executable(sqlite3-bin shell.c)

    set_target_properties(sqlite3-bin PROPERTIES
        OUTPUT_NAME sqlite3
        PDB_NAME "sqlite3${CMAKE_EXECUTABLE_SUFFIX}.pdb"
    )

    target_link_libraries(sqlite3-bin PRIVATE libsqlite3)
    if (WITH_ZLIB)
        find_package(ZLIB REQUIRED)
        target_link_libraries(sqlite3-bin PRIVATE ZLIB::ZLIB)
        target_compile_definitions(sqlite3-bin PRIVATE SQLITE_HAVE_ZLIB)
    endif()

    find_library(HAVE_LIBM m)
    if(HAVE_LIBM)
        target_link_libraries(sqlite3-bin PRIVATE m)
    endif()

    if(SQLITE_ENABLE_ICU)
        # Link ICU libraries for the executable.
        # For static builds on Linux/macOS, link order can be critical for ICU: i18n -> uc -> data.
        # For MSVC, the order is less strict due to its linker's behavior.
        target_link_libraries(sqlite3-bin PRIVATE
            ICU::i18n        # Depends on ICU::uc
            ICU::uc          # Depends on icudata
            ${ICUDATA_LIBRARY} # Explicitly found icudata library path
        )
        set_property(TARGET sqlite3-bin PROPERTY LINKER_LANGUAGE CXX)
    endif()

    install(TARGETS sqlite3-bin libsqlite3
      RUNTIME DESTINATION bin
      LIBRARY DESTINATION lib
      ARCHIVE DESTINATION lib
    )
endif()

install(
    TARGETS libsqlite3
    EXPORT unofficial-sqlite3-targets
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

install(FILES sqlite3.h sqlite3ext.h sqlite3-vcpkg-config.h DESTINATION include CONFIGURATIONS Release)
install(EXPORT unofficial-sqlite3-targets NAMESPACE unofficial::sqlite3:: FILE unofficial-sqlite3-targets.cmake DESTINATION share/unofficial-sqlite3)

configure_file(sqlite3.pc.in sqlite3.pc @ONLY)
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/sqlite3.pc" DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/pkgconfig")
