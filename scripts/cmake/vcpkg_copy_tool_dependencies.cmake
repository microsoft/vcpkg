function(z_vcpkg_copy_tool_dependencies_search tool_dir path_to_search)
    if(DEFINED Z_VCPKG_COPY_TOOL_DEPENDENCIES_COUNT)
        set(count ${Z_VCPKG_COPY_TOOL_DEPENDENCIES_COUNT})
    else()
        set(count 0)
    endif()
    file(GLOB tools "${tool_dir}/*.exe" "${tool_dir}/*.dll" "${tool_dir}/*.pyd")
    foreach(tool IN LISTS tools)
        vcpkg_execute_required_process(
            COMMAND "${Z_VCPKG_POWERSHELL_CORE}" -noprofile -executionpolicy Bypass -nologo
                -file "${SCRIPTS}/buildsystems/msbuild/applocal.ps1"
                -targetBinary "${tool}"
                -installedDir "${path_to_search}"
                -verbose
            WORKING_DIRECTORY "${VCPKG_ROOT_DIR}"
            LOGNAME copy-tool-dependencies-${count}
        )
        math(EXPR count "${count} + 1")
    endforeach()
    set(Z_VCPKG_COPY_TOOL_DEPENDENCIES_COUNT ${count} CACHE INTERNAL "")
endfunction()

function(z_vcpkg_resolve_pe_dependencies)
    cmake_parse_arguments(PARSE_ARGV 0 arg ""
        "BINARY;OBJDUMP;TOOL_DIR;OUT_NEW_BINARIES"
        "SEARCH_PATHS;INOUT_SEARCHED"
    )

    # 使用 objdump 提取 PE 依赖
    execute_process(
        COMMAND "${arg_OBJDUMP}" -p "${arg_BINARY}"
        OUTPUT_VARIABLE objdump_output
        ERROR_QUIET
        RESULT_VARIABLE objdump_result
    )

    if(NOT objdump_result EQUAL 0)
        # objdump 失败，可能不是 PE 文件，跳过
        return()
    endif()

    # 解析输出，查找 "DLL Name: xxx.dll" 行
    # 格式因 objdump 版本而异：
    #   MinGW objdump:      "\tDLL Name: kernel32.dll"
    #   LLVM objdump:       "    DLL Name: kernel32.dll"
    string(REGEX MATCHALL "DLL Name: ([^\r\n]+)" dll_matches "${objdump_output}")

    set(new_binaries "")
    foreach(match IN LISTS dll_matches)
        # 提取 DLL 名称
        string(REGEX REPLACE ".*DLL Name: (.+)" "\\1" dll_name "${match}")
        string(STRIP "${dll_name}" dll_name)

        # 跳过已处理的 DLL
        if(dll_name IN_LIST arg_INOUT_SEARCHED)
            continue()
        endif()
        list(APPEND arg_INOUT_SEARCHED "${dll_name}")

        # 在搜索路径中查找 DLL
        set(dll_found FALSE)
        foreach(search_path IN LISTS arg_SEARCH_PATHS)
            set(dll_path "${search_path}/${dll_name}")
            if(EXISTS "${dll_path}")
                # 找到 DLL，复制到工具目录
                message(VERBOSE "Copying tool dependency: ${dll_name}")
                file(COPY "${dll_path}" DESTINATION "${arg_TOOL_DIR}")
                list(APPEND new_binaries "${arg_TOOL_DIR}/${dll_name}")
                set(dll_found TRUE)
                break()
            endif()
        endforeach()

        if(NOT dll_found)
            # DLL 未找到 - 可能是系统 DLL（如 kernel32.dll），跳过
            message(VERBOSE "Skipping system DLL: ${dll_name}")
        endif()
    endforeach()

    # 返回新发现的二进制文件和更新的已搜索列表
    set(${arg_OUT_NEW_BINARIES} "${new_binaries}" PARENT_SCOPE)
    set(${arg_INOUT_SEARCHED} "${arg_INOUT_SEARCHED}" PARENT_SCOPE)
endfunction()

function(z_vcpkg_copy_tool_dependencies_cross_compile)
    cmake_parse_arguments(PARSE_ARGV 0 arg "" "TOOL_DIR" "SEARCH_PATHS")

    # 查找 objdump 工具（MinGW 或 LLVM 版本）
    find_program(Z_VCPKG_OBJDUMP
        NAMES
            x86_64-w64-mingw32-objdump  # MinGW on Linux/macOS
            i686-w64-mingw32-objdump    # MinGW 32-bit
            aarch64-w64-mingw32-objdump # MinGW ARM64
            llvm-objdump                # LLVM universal
            objdump                     # Native (might support PE)
        DOC "Tool to analyze PE dependencies"
    )

    if(NOT Z_VCPKG_OBJDUMP)
        message(WARNING
            "objdump not found. Tool dependencies cannot be copied for cross-compilation.\n"
            "Install MinGW toolchain or LLVM to enable this feature.\n"
            "  - Ubuntu/Debian: apt-get install mingw-w64-tools\n"
            "  - macOS: brew install mingw-w64 or brew install llvm"
        )
        return()
    endif()

    # 初始化已搜索的 DLL 列表（防止无限循环）
    set(searched_dlls "")

    # 查找所有需要处理的二进制文件
    file(GLOB initial_binaries
        "${arg_TOOL_DIR}/*.exe"
        "${arg_TOOL_DIR}/*.dll"
        "${arg_TOOL_DIR}/*.pyd"
    )

    set(binaries_to_scan "${initial_binaries}")

    # 递归处理依赖
    while(binaries_to_scan)
        set(new_binaries "")
        foreach(binary IN LISTS binaries_to_scan)
            z_vcpkg_resolve_pe_dependencies(
                BINARY "${binary}"
                OBJDUMP "${Z_VCPKG_OBJDUMP}"
                TOOL_DIR "${arg_TOOL_DIR}"
                SEARCH_PATHS ${arg_SEARCH_PATHS}
                OUT_NEW_BINARIES new_deps
                INOUT_SEARCHED searched_dlls
            )
            list(APPEND new_binaries ${new_deps})
        endforeach()
        set(binaries_to_scan "${new_binaries}")
    endwhile()
endfunction()

function(vcpkg_copy_tool_dependencies tool_dir)
    if(ARGC GREATER 1)
        message(WARNING "${CMAKE_CURRENT_FUNCTION} was passed extra arguments: ${ARGN}")
    endif()

    # 只处理 Windows 目标的工具（因为它们是 PE 格式，有 DLL 依赖）
    if(NOT VCPKG_TARGET_IS_WINDOWS)
        return()
    endif()

    if(VCPKG_HOST_IS_WINDOWS)
        # 路径 A：Windows 主机 - 使用 PowerShell + applocal.ps1（现有逻辑）
        find_program(Z_VCPKG_POWERSHELL_CORE pwsh)
        if (NOT Z_VCPKG_POWERSHELL_CORE)
            message(FATAL_ERROR "Could not find PowerShell Core; please open an issue to report this.")
        endif()
        cmake_path(RELATIVE_PATH tool_dir
            BASE_DIRECTORY "${CURRENT_PACKAGES_DIR}"
            OUTPUT_VARIABLE relative_tool_dir
        )
        if(relative_tool_dir MATCHES "^debug/|/debug/")
            z_vcpkg_copy_tool_dependencies_search("${tool_dir}" "${CURRENT_PACKAGES_DIR}/debug/bin")
            z_vcpkg_copy_tool_dependencies_search("${tool_dir}" "${CURRENT_INSTALLED_DIR}/debug/bin")
        else()
            z_vcpkg_copy_tool_dependencies_search("${tool_dir}" "${CURRENT_PACKAGES_DIR}/bin")
            z_vcpkg_copy_tool_dependencies_search("${tool_dir}" "${CURRENT_INSTALLED_DIR}/bin")
        endif()
    else()
        # 路径 B：非 Windows 主机交叉编译到 Windows - 使用 objdump（新增逻辑）
        # 只在动态链接时需要复制 DLL
        if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
            cmake_path(RELATIVE_PATH tool_dir
                BASE_DIRECTORY "${CURRENT_PACKAGES_DIR}"
                OUTPUT_VARIABLE relative_tool_dir
            )
            if(relative_tool_dir MATCHES "^debug/|/debug/")
                set(search_paths "${CURRENT_PACKAGES_DIR}/debug/bin" "${CURRENT_INSTALLED_DIR}/debug/bin")
            else()
                set(search_paths "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_INSTALLED_DIR}/bin")
            endif()
            z_vcpkg_copy_tool_dependencies_cross_compile(
                TOOL_DIR "${tool_dir}"
                SEARCH_PATHS ${search_paths}
            )
        endif()
    endif()
endfunction()
