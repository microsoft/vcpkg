#include <dbus-cxx.h>
#include <dbus-cxx-glib.h>
#include <dbus-cxx-uv.h>
#include <memory>
int main()
{
   auto connection = DBus::Connection::create(DBus::BusType::SESSION);
   std::shared_ptr<DBus::Dispatcher> disp = DBus::GLib::GLibDispatcher::create();
   std::shared_ptr<DBus::Dispatcher> disp = DBus::Uv::UvDispatcher::create();
   return 0;
}
