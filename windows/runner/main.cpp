#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include "flutter_window.h"
#include "utils.h"

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.

  // https://github.com/biyidev/biyi/commit/66ad34c21c221460c0bd7c47a743259f5e15a38d
  HWND hWnd = ::FindWindow(L"FLUTTER_RUNNER_WIN32_WINDOW", L"Clash For Flutter");
  if (hWnd != NULL) {
    ::ShowWindow(hWnd, SW_NORMAL);
    ::SetForegroundWindow(hWnd);
    return EXIT_FAILURE;
  }

  // https://github.com/flutter/flutter/issues/47891#issuecomment-708850435
  // https://github.com/flutter/flutter/issues/47891#issuecomment-869729956
  // https://github.com/dart-lang/sdk/issues/39945#issuecomment-870428151
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  } else {
    AllocConsole();
    ShowWindow(GetConsoleWindow(), SW_HIDE);
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(950, 600);
  if (!window.CreateAndShow(L"Clash For Flutter", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(false);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
