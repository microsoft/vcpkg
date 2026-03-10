#include <dbus-cxx.h>
int main()
{
   auto connection = DBus::Connection::create(DBus::BusType::SESSION);
   return 0;
}
