#include <stdio.h>
#include <string.h>

int main() {
  FILE *file;
  if ((file = fopen("/sys/kernel/debug/vgaswitcheroo/switch", "r")) == NULL) {
    return -1;
  }

  char buffer[64] = {0};
  int bytes = 0;
  while ((bytes = fscanf(file, "%64[^\n]", buffer)) == 1) {
    if (memcmp(buffer+1, ":DIS:", 5) == 0) {
      fclose(file);
      if (memcmp(buffer+7, ":DynOff:", 8) == 0) {
        return 0;
      } else if (memcmp(buffer+7, ":DynPwr:", 8) == 0) {
        printf("<span font_desc='JetBrains Mono Medium 13' color='#ffa759'></span>\n");
        return 0;
      } else {
        return -1;
      }
    }
    fseek(file, bytes, SEEK_CUR);
  }
  fclose(file);

  return -1;
}
