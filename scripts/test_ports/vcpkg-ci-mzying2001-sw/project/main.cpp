#include <sw/SimpleWindow.h>
int main()
{
   sw::Window wnd;
   sw::Button btn;
   wnd.SetLayout<sw::FillLayout>();
   btn.AddHandler(sw::ButtonBase_Clicked,
      [](sw::UIElement& sender, sw::RoutedEventArgs& e) {
         sw::MsgBox::Show(L"Hello, SimpleWindow!");
      });
   wnd.AddChild(btn);
   return 0;
}
