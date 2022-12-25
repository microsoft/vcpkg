set(SCRIPT_PATH "${CURRENT_INSTALLED_DIR}/share/qtbase")
include("${SCRIPT_PATH}/qt_install_submodule.cmake")

set(${PORT}_PATCHES)
set(TOOL_NAMES)

#  -flite ............... Enable Flite support [auto] (Unix only)
#  -flite-alsa .......... Enable Flite with ALSA support [auto] (Unix only)
#  -speechd ............. Enable speech dispatcher support [auto] (Unix only)

qt_install_submodule(PATCHES    ${${PORT}_PATCHES}
                     TOOL_NAMES ${TOOL_NAMES}
                     CONFIGURE_OPTIONS_MAYBE_UNUSED
                         QT_BUILD_EXAMPLES
                         QT_USE_DEFAULT_CMAKE_OPTIMIZATION_FLAGS
                    )


# qt_find_package(Flite PROVIDED_TARGETS Flite::Flite MODULE_NAME texttospeech QMAKE_LIB flite)
# qt_find_package(ALSA PROVIDED_TARGETS ALSA::ALSA MODULE_NAME texttospeech QMAKE_LIB flite_alsa)
# qt_find_package(SpeechDispatcher PROVIDED_TARGETS SpeechDispatcher::SpeechDispatcher MODULE_NAME texttospeech QMAKE_LIB speechd)


# #### Tests



# #### Features

# if (Flite_FOUND AND NOT TARGET Qt::Multimedia)
    # message(WARNING
            # "Flite was found, but Qt::Multimedia is not configured.\n"
            # "The Flite engine will be disabled.")
# endif()

# qt_feature("flite" PRIVATE
    # LABEL "Flite"
    # CONDITION Flite_FOUND AND TARGET Qt::Multimedia
# )
# qt_feature("flite_alsa" PRIVATE
    # LABEL "Flite with ALSA"
    # CONDITION Flite_FOUND AND ALSA_FOUND AND TARGET Qt::Multimedia
# )
# qt_feature("speechd" PUBLIC
    # LABEL "Speech Dispatcher"
    # AUTODETECT UNIX
    # CONDITION SpeechDispatcher_FOUND
# )
# qt_configure_add_summary_section(NAME "Qt TextToSpeech")
# qt_configure_add_summary_entry(ARGS "flite")
# qt_configure_add_summary_entry(ARGS "flite_alsa")
# qt_configure_add_summary_entry(ARGS "speechd")
# qt_configure_end_summary_section() # end of "Qt TextToSpeech" section
