%{
#include "y.tab.h"
%}

%%

Player          { return PLAYER; }
Deck:           { return DECK; }
AI              { return AI; }
maki            { return MAKI; }
tempura         { return TEMPURA; }
sashimi         { return SASHIMI; }
dumpling        { return DUMPLING; }
salmon_nigiri   { return SALMON_NIGIRI; }
squid_nigiri    { return SQUID_NIGIRI; }
egg_nigiri      { return EGG_NIGIRI; }
nigiri          { return NIGIRI; }
pudding         { return PUDDING; }
wasabi          { return WASABI; }
chopsticks      { return CHOPSTICKS; }
\n              { return EOL; }
[ \t]+          ;  // Ignore whitespace
.               { printf("Unexpected character: %s\n", yytext); return yytext[0]; }

%%

int yywrap() {
    return 1;
}
