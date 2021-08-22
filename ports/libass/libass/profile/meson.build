profile_src = files('profile.c')

libass_profile = executable('libass_profile', profile_src,
                            install: true,
                            include_directories: incs,
                            dependencies: deps,
                            link_with: libass)
