#include <libremidi/libremidi.hpp>
#include <libremidi/backends.hpp>
#include <iostream>

int main()
{
    std::cout << "Default midi2 API: " << libremidi::get_api_display_name(libremidi::midi2::default_api()) << std::endl;
    libremidi::midi_any::for_all_backends([](auto& backend) {
        std::cout << "- " << backend.display_name << std::endl;
    });
    return 0;
}
