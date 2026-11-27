include_guard(GLOBAL)

# Detects whether gradle-artifacts.cmake is still valid for a Qt version.
# Used by vcpkg_qt_android_gradle_setup() and by qtbase in QT_UPDATE_VERSION mode.
# Keep the project discovery and the input files in sync with generate-artifacts.py.

set(Z_VCPKG_QT_ANDROID_GRADLE_PORT_DIR "${CMAKE_CURRENT_LIST_DIR}")

# Gradle JAR projects as detected by qt_internal_add_jar(), without app templates.
function(z_vcpkg_qt_android_gradle_projects out_var source_dir)
    file(GLOB_RECURSE gradle_files LIST_DIRECTORIES false RELATIVE "${source_dir}" "${source_dir}/src/*.gradle")
    set(projects "")
    foreach(file IN LISTS gradle_files)
        get_filename_component(name "${file}" NAME)
        get_filename_component(project "${file}" DIRECTORY)
        if(name STREQUAL "settings.gradle"
            AND EXISTS "${source_dir}/${project}/build.gradle"
            AND EXISTS "${source_dir}/${project}/gradle/libs.versions.toml"
            AND NOT "/${project}/" MATCHES "/templates/")
            list(APPEND projects "${project}")
        endif()
    endforeach()
    list(SORT projects)
    set(${out_var} "${projects}" PARENT_SCOPE)
endfunction()

# Files of qtbase which determine the Gradle distribution and the downloaded artifacts,
# as "<path>|<sha512>" like QT_ANDROID_GRADLE_INPUTS.
function(z_vcpkg_qt_android_gradle_inputs out_var qtbase_dir)
    set(files
        "src/3rdparty/gradle/gradle/wrapper/gradle-wrapper.properties"
        "cmake/android/qt-android-init.gradle"
    )
    z_vcpkg_qt_android_gradle_projects(projects "${qtbase_dir}")
    foreach(project IN LISTS projects)
        foreach(name IN ITEMS build.gradle settings.gradle gradle.properties gradle/libs.versions.toml)
            if(EXISTS "${qtbase_dir}/${project}/${name}")
                list(APPEND files "${project}/${name}")
            endif()
        endforeach()
    endforeach()
    set(inputs "")
    foreach(file IN LISTS files)
        if(EXISTS "${qtbase_dir}/${file}")
            file(SHA512 "${qtbase_dir}/${file}" hash)
            list(APPEND inputs "${file}|${hash}")
        endif()
    endforeach()
    list(SORT inputs)
    set(${out_var} "${inputs}" PARENT_SCOPE)
endfunction()

# Differences between the qtbase sources and the inputs gradle-artifacts.cmake was generated from.
# An empty result means the artifacts are up to date.
function(z_vcpkg_qt_android_gradle_compare_qtbase out_var qtbase_dir)
    include("${Z_VCPKG_QT_ANDROID_GRADLE_PORT_DIR}/gradle-artifacts.cmake")
    z_vcpkg_qt_android_gradle_inputs(current "${qtbase_dir}")
    set(recorded "${QT_ANDROID_GRADLE_INPUTS}")
    list(SORT recorded)

    set(differences "")
    foreach(input IN LISTS current)
        string(REGEX REPLACE "\\|.*" "" path "${input}")
        if(NOT input IN_LIST recorded)
            if("${recorded}" MATCHES "(^|;)${path}\\|")
                list(APPEND differences "changed: ${path}")
            else()
                list(APPEND differences "new: ${path}")
            endif()
        endif()
    endforeach()
    foreach(input IN LISTS recorded)
        string(REGEX REPLACE "\\|.*" "" path "${input}")
        if(NOT "${current}" MATCHES "(^|;)${path}\\|")
            list(APPEND differences "removed: ${path}")
        endif()
    endforeach()
    set(${out_var} "${differences}" PARENT_SCOPE)
endfunction()

# JAR projects of another Qt module whose libs.versions.toml differs from all qtbase ones,
# i.e. which may need artifacts that were not resolved by generate-artifacts.py.
function(z_vcpkg_qt_android_gradle_unknown_projects out_var source_dir)
    include("${Z_VCPKG_QT_ANDROID_GRADLE_PORT_DIR}/gradle-artifacts.cmake")
    z_vcpkg_qt_android_gradle_projects(projects "${source_dir}")
    set(unknown "")
    foreach(project IN LISTS projects)
        file(SHA512 "${source_dir}/${project}/gradle/libs.versions.toml" hash)
        if(NOT "${QT_ANDROID_GRADLE_INPUTS}" MATCHES "/gradle/libs\\.versions\\.toml\\|${hash}")
            list(APPEND unknown "${project}")
        endif()
    endforeach()
    set(${out_var} "${unknown}" PARENT_SCOPE)
endfunction()

function(z_vcpkg_qt_android_gradle_regenerate_hint out_var qtbase_archive)
    string(CONCAT hint
        "Regenerate ports/vcpkg-qt-android-gradle/gradle-artifacts.cmake on a system with Docker "
        "(e.g. WSL) and bump the version of vcpkg-qt-android-gradle:\n"
        "  bash ports/vcpkg-qt-android-gradle/generate-in-docker.sh \"${qtbase_archive}\""
    )
    set(${out_var} "${hint}" PARENT_SCOPE)
endfunction()
