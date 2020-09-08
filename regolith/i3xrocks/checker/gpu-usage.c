#include <stdio.h>
#include <string.h>
#include <X11/Xresource.h>

int main() {
  int ret = -1;
  FILE *file = NULL;
  Display *display = NULL;

  if ((file = fopen("/sys/kernel/debug/vgaswitcheroo/switch", "r")) == NULL) {
    goto cleanup;
  }

  char buffer[64] = {0};
  while (fscanf(file, "%64[^\n]", buffer) == 1) {
    if (memcmp(buffer+1, ":DIS:", 5) == 0) {
      if (memcmp(buffer+7, ":DynPwr:", 8) == 0) {
        ret = 0;

        XrmInitialize();

        display = XOpenDisplay(NULL);
        if (NULL == display) {
          goto cleanup;
        }

        char *manager = XResourceManagerString(display);
        if (NULL == manager) {
          goto cleanup;
        }

        XrmDatabase db = XrmGetStringDatabase(manager);
        if (NULL == db) {
          goto cleanup;
        }

        char *type;
        XrmValue value;

        char *font = "JetBrains Mono Medium 13";
        char *color = "#FFD580";
        char *label = "";

        if (XrmGetResource(db, "i3xrocks.value.font", "i3xrocks.value.font", &type, &value)) {
          font = value.addr;
        }

        if (XrmGetResource(db, "i3xrocks.warning", "i3xrocks.warning", &type, &value)) {
          color = value.addr;
        }

        if (XrmGetResource(db, "i3xrocks.label.gpu", "i3xrocks.label.gpu", &type, &value)) {
          label = value.addr;
        }

        printf("<span font_desc='%s' color='%s'>%s</span>\n", font, color, label);
      } else if (memcmp(buffer+7, ":DynOff:", 8) == 0) {
        ret = 0;
      }

      goto cleanup;
    }
    fseek(file, 1, SEEK_CUR);
  }

cleanup:
  if (NULL != file) {
    fclose(file);
  }

  if (NULL != display) {
    XCloseDisplay(display);
  }

  return ret;
}
