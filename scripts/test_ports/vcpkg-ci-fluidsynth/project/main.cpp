#include <stdio.h>
#include <fluidsynth.h>

int main()
{
    fluid_settings_t* settings = new_fluid_settings();
    int ret = fluid_settings_setint(settings, "vcpkg.test", 123);
    delete_fluid_settings(settings);

    printf("Result: %d\n", ret);
    return 0;
}
