#include <stdio.h>
#include <string.h>

static char is_child (const char * a, const char * b) {
   return a[0] && ! strncmp (a, b, strlen (a) - 1) && b[strlen (a) - 1] == '/';
}

static void print_childs (int * childs) {
   if (! * childs)
      return;
   if (* childs == 1)
      printf ("   [1 child]\n");
   else
      printf ("   [%d children]\n", * childs);
   * childs = 0;
}

int main (void) {
   char last[1000], cur[1000];
   last[0] = 0;
   int childs = 0;
   while (fgets (cur, sizeof cur, stdin)) {
      if (is_child (last, cur))
         childs ++;
      else {
         print_childs (& childs);
         fputs (cur, stdout);
         strcpy (last, cur);
      }
   }
   print_childs (& childs);
}
