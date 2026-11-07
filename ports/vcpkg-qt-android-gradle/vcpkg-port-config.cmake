include_guard(GLOBAL)

include("${CMAKE_CURRENT_LIST_DIR}/vcpkg-qt-android-gradle-inputs.cmake")

set(Z_VCPKG_QT_ANDROID_GRADLE_DIR "${CMAKE_CURRENT_LIST_DIR}")

# vcpkg_qt_android_gradle_setup(SOURCE_PATH <dir>)
#
# Points GRADLE_USER_HOME to a fresh directory in the buildtree which contains
# - the Gradle distribution expected by Qt's Gradle wrapper, so the wrapper doesn't download it,
# - an init script redirecting all repositories to the offline Maven repository of this port,
# - a gradle.properties disabling the Gradle daemon,
# and points ANDROID_USER_HOME to the same directory.
# SOURCE_PATH are the sources of the Qt module being built. For qtbase they must match the
# sources the artifacts were generated from; other modules are checked for JAR projects with
# different dependencies.
function(vcpkg_qt_android_gradle_setup)
    cmake_parse_arguments(PARSE_ARGV 0 arg "" "SOURCE_PATH" "")
    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()
    if(NOT arg_SOURCE_PATH)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} requires SOURCE_PATH.")
    endif()

    include("${Z_VCPKG_QT_ANDROID_GRADLE_DIR}/gradle-artifacts.cmake")

    if(PORT STREQUAL "qtbase")
        z_vcpkg_qt_android_gradle_compare_qtbase(differences "${arg_SOURCE_PATH}")
        if(differences)
            list(JOIN differences "\n  " differences)
            z_vcpkg_qt_android_gradle_regenerate_hint(hint "<qtbase-everywhere-src-${VERSION}.tar.xz>")
            message(FATAL_ERROR
                "vcpkg-qt-android-gradle was generated for different Gradle inputs of qtbase:\n"
                "  ${differences}\n${hint}"
            )
        endif()
    else()
        set(wrapper_properties "${CURRENT_INSTALLED_DIR}/src/3rdparty/gradle/gradle/wrapper/gradle-wrapper.properties")
        if(EXISTS "${wrapper_properties}")
            file(STRINGS "${wrapper_properties}" wrapper_url REGEX "^distributionUrl=")
            string(REGEX REPLACE "^distributionUrl=" "" wrapper_url "${wrapper_url}")
            string(REPLACE "\\:" ":" wrapper_url "${wrapper_url}")
            if(NOT wrapper_url STREQUAL QT_ANDROID_GRADLE_DISTRIBUTION_URL)
                message(FATAL_ERROR
                    "The installed qtbase uses '${wrapper_url}', but vcpkg-qt-android-gradle provides "
                    "'${QT_ANDROID_GRADLE_DISTRIBUTION_URL}'. Rebuild qtbase and vcpkg-qt-android-gradle."
                )
            endif()
        endif()
        z_vcpkg_qt_android_gradle_unknown_projects(unknown "${arg_SOURCE_PATH}")
        if(unknown)
            list(JOIN unknown ", " unknown)
            message(WARNING
                "The Gradle JAR projects ${unknown} of ${PORT} declare different versions or dependencies "
                "than qtbase. If their offline Gradle build fails, add them to the generator with "
                "'--project' and regenerate ports/vcpkg-qt-android-gradle/gradle-artifacts.cmake."
            )
        endif()
    endif()

    set(gradle_home "${CURRENT_BUILDTREES_DIR}/gradle-home-${TARGET_TRIPLET}")
    file(REMOVE_RECURSE "${gradle_home}")

    # Same layout as the Gradle wrapper: wrapper/dists/<name>/<base36 md5 of the URL>/<name>.zip
    file(COPY "${Z_VCPKG_QT_ANDROID_GRADLE_DIR}/${QT_ANDROID_GRADLE_DISTRIBUTION_NAME}.zip"
        DESTINATION "${gradle_home}/wrapper/dists/${QT_ANDROID_GRADLE_DISTRIBUTION_NAME}/${QT_ANDROID_GRADLE_DISTRIBUTION_HASH}"
    )

    set(QT_ANDROID_GRADLE_REPOSITORY_DIR "${Z_VCPKG_QT_ANDROID_GRADLE_DIR}/m2")
    configure_file("${Z_VCPKG_QT_ANDROID_GRADLE_DIR}/vcpkg-offline-repository.gradle.in"
        "${gradle_home}/init.d/vcpkg-offline-repository.gradle" @ONLY
    )
    file(COPY "${Z_VCPKG_QT_ANDROID_GRADLE_DIR}/gradle.properties" DESTINATION "${gradle_home}")

    # The Android Gradle Plugin falls back to ~/.android, which doesn't exist
    # when building as a user without home directory (e.g. in CI containers).
    file(MAKE_DIRECTORY "${gradle_home}/android-user-home")

    set(ENV{GRADLE_USER_HOME} "${gradle_home}")
    set(ENV{ANDROID_USER_HOME} "${gradle_home}/android-user-home")
endfunction()
