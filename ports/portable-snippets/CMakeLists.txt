cmake_minimum_required(VERSION 3.14)

project(portable-snippets LANGUAGES C)

include(GNUInstallDirs)

option(PSNIP_INSTALL_HEADERS "Install header files" ON)

# https://stackoverflow.com/questions/7787823/cmake-how-to-get-the-name-of-all-subdirectories-of-a-directory
function (list_subdir output_variable path)
    file(GLOB sub_entries RELATIVE ${path} ${path}/*)

    set(dirlist "")

    foreach (entry ${sub_entries})
        if (IS_DIRECTORY ${path}/${entry})
            list(APPEND dirlist ${entry})
        endif ()
    endforeach ()

    set(${output_variable} ${dirlist} PARENT_SCOPE)
endfunction ()

function (check_if_header_only output_variable files)
    set(is_header_only 1)

    foreach (entry ${files})
        get_filename_component(file_ext ${entry} EXT)
        if (file_ext STREQUAL .c)
            set(is_header_only 0)
        endif ()
    endforeach ()

    set(${output_variable} ${is_header_only} PARENT_SCOPE)
endfunction ()

list_subdir(subdirs ${CMAKE_CURRENT_LIST_DIR})
list(REMOVE_ITEM subdirs tests)

set(namespace unofficial::portable-snippets)

foreach (subdir ${subdirs})
    set(module ${subdir})
    set(module_path "${CMAKE_CURRENT_LIST_DIR}/${subdir}")

    file(GLOB entries
        LIST_DIRECTORIES false
        ${module_path}/*.h
        ${module_path}/*.c
    )

    check_if_header_only(header_only "${entries}")

    if (header_only)
        add_library(${module} INTERFACE)

        target_include_directories(
            ${module}
            INTERFACE
                $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
        )
    else ()
        add_library(${module} STATIC ${entries})

        set_target_properties(
            ${module}
            PROPERTIES
                PREFIX ""
                OUTPUT_NAME "psnip-${module}"
        )

        target_include_directories(
            ${module}
            PUBLIC
                $<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}>
                $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
        )

        list(FILTER entries EXCLUDE REGEX "\.c$")
    endif ()

    add_library(${namespace}::${module} ALIAS ${module})

    if (PSNIP_INSTALL_HEADERS)
        install(FILES ${entries} DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${subdir})
    endif ()

    install(TARGETS ${module} EXPORT unofficial-portable-snippets-config)
endforeach ()

install(
    EXPORT unofficial-portable-snippets-config
    NAMESPACE ${namespace}::
    DESTINATION share/unofficial-portable-snippets
    PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ
)
