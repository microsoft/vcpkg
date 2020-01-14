cmake_minimum_required(VERSION 3.0)
project(hwloc
    LANGUAGES C
    VERSION 1.11.7)

configure_file(contrib/windows/hwloc_config.h include/hwloc/autogen/config.h COPYONLY)
configure_file(contrib/windows/static-components.h include/static-components.h COPYONLY)
configure_file(contrib/windows/private_config.h include/private/autogen/config.h COPYONLY)

file(READ ${CMAKE_CURRENT_BINARY_DIR}/include/private/autogen/config.h PRIVATE_CONFIG_H)
string(REPLACE "#define HAVE_DECL_SNPRINTF 0" "#define HAVE_DECL_SNPRINTF 1" PRIVATE_CONFIG_H "${PRIVATE_CONFIG_H}")
string(REPLACE "#define HAVE_DECL_STRTOULL 0" "#define HAVE_DECL_STRTOULL 1" PRIVATE_CONFIG_H "${PRIVATE_CONFIG_H}")
if(CMAKE_SIZEOF_VOID_P EQUAL 4)
    string(REPLACE "/* #undef HWLOC_X86_32_ARCH */" "#define HWLOC_X86_32_ARCH 1"    PRIVATE_CONFIG_H "${PRIVATE_CONFIG_H}")
    string(REPLACE "#define HWLOC_X86_64_ARCH 1"    "/* #undef HWLOC_X86_64_ARCH */" PRIVATE_CONFIG_H "${PRIVATE_CONFIG_H}")
    string(REPLACE "#define SIZEOF_VOID_P 8"        "#define SIZEOF_VOID_P 4"        PRIVATE_CONFIG_H "${PRIVATE_CONFIG_H}")
endif()
file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/include/private/autogen/config.h "${PRIVATE_CONFIG_H}")

add_library(libhwloc
    src/base64.c
    src/bind.c
    src/bitmap.c
    src/components.c
    src/distances.c
    src/diff.c
    src/misc.c
    src/pci-common.c
    src/topology-custom.c
    src/topology-noos.c
    src/topology-synthetic.c
    src/topology-windows.c
    src/topology-x86.c
    src/topology-xml-nolibxml.c
    src/topology-xml.c
    src/topology.c
    src/traversal.c
    src/dolib.c)

set_target_properties(libhwloc PROPERTIES DEFINE_SYMBOL _USRDLL)

add_executable(hwloc-info
    utils/hwloc/hwloc-info.c)

target_link_libraries(hwloc-info PRIVATE libhwloc)

foreach(Target IN ITEMS libhwloc hwloc-info)
    target_include_directories(${Target} PRIVATE ./include ./src ${CMAKE_CURRENT_BINARY_DIR}/include)
    target_compile_definitions(${Target} PRIVATE _CRT_SECURE_NO_WARNINGS)
endforeach(Target)

install(TARGETS libhwloc
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib)

install(TARGETS hwloc-info
    RUNTIME DESTINATION tools/hwloc)
if(BUILD_SHARED_LIBS)
    install(TARGETS libhwloc
        RUNTIME DESTINATION tools/hwloc)
endif(BUILD_SHARED_LIBS)


if(NOT HWLOC_SKIP_INCLUDES)
    install(FILES include/hwloc.h DESTINATION include)
    install(DIRECTORY include/hwloc DESTINATION include FILES_MATCHING PATTERN "*.h")
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/include/hwloc/autogen/config.h DESTINATION include/hwloc/autogen)
endif()
