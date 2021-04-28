#include "\z\lambs\addons\main\script_component.hpp"

#define PYN 108
// PX(1) is 10 Pixels in a 1920x1080 Resolution on the X Axis
#define PX(X) ((X)/PYN*safeZoneH/(4/3))
// PY(1) is 10 Pixels in a 1920x1080 Resolution on the Y Axis
#define PY(Y) ((Y)/PYN*safeZoneH)

#define CONST_WIDTH 90
#define CONST_HEIGHT 5
#define CONST_SPACE_HEIGHT 0.5
#define CONST_ELEMENTDIVIDER 2

#define COLOR_A profileNamespace getVariable ["gui_bcg_rgb_a", 0.8]
#define COLOR_R profileNamespace getVariable ["gui_bcg_rgb_r", 0.13]
#define COLOR_G profileNamespace getVariable ["gui_bcg_rgb_g", 0.54]
#define COLOR_B profileNamespace getVariable ["gui_bcg_rgb_b", 0.21]
#define COLOR_RGB(A) [COLOR_R, COLOR_G, COLOR_B, A]
#define COLOR_RGBA COLOR_RGB(COLOR_A)

#define TEXT_A profileNamespace getVariable ["gui_titletext_rgb_a", 1]
#define TEXT_R profileNamespace getVariable ["gui_titletext_rgb_r", 1]
#define TEXT_G profileNamespace getVariable ["gui_titletext_rgb_g", 1]
#define TEXT_B profileNamespace getVariable ["gui_titletext_rgb_b", 1]
#define TEXT_RGB(A) [TEXT_R, TEXT_G, TEXT_B, A]
#define TEXT_RGBA TEXT_RGB(TEXT_A)

#define BACKGROUND_A profileNamespace getVariable ["igui_bcg_rgb_a", 0.4]
#define BACKGROUND_R profileNamespace getVariable ["igui_bcg_rgb_r", 0.2]
#define BACKGROUND_G profileNamespace getVariable ["igui_bcg_rgb_g", 0.2]
#define BACKGROUND_B profileNamespace getVariable ["igui_bcg_rgb_b", 0.2]
#define BACKGROUND_RGB(A) [BACKGROUND_R, BACKGROUND_G, BACKGROUND_B, A]
#define BACKGROUND_RGBA BACKGROUND_RGB(BACKGROUND_A)
