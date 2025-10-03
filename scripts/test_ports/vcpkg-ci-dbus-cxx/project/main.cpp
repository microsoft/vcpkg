#include <dbus-cxx.h>
#include <dbus-cxx-glib.h>
#include <dbus-cxx-uv.h>
#include <memory>
int main()
{
   auto connection = DBus::Connection::create(DBus::BusType::SESSION);
   std::shared_ptr<DBus::Dispatcher> GLibDisp = DBus::GLib::GLibDispatcher::create();
   std::shared_ptr<DBus::Dispatcher> UvDisp = DBus::Uv::UvDispatcher::create();
   return 0;
}

