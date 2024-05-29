%{
#include "y.tab.h"
%}

%%

maki           { return MAKI; }
tempura        { return TEMPURA; }
sashimi        { return SASHIMI; }
dumpling       { return DUMPLING; }
salmon_nigiri  { return SALMON_NIGIRI; }
squid_nigiri   { return SQUID_NIGIRI; }
egg_nigiri     { return EGG_NIGIRI; }
nigiri         { return NIGIRI; }
pudding        { return PUDDING; }
wasabi         { return WASABI; }
chopsticks     { return CHOPSTICKS; }
pick           { return PICK; }
show           { return SHOW; }
pass           { return PASS; }
score          { return SCORE; }
end            { return END; }
\n             { return EOL; }
[ \t]+         ;  // Ignore whitespace
[a-zA-Z_]+     { printf("Unexpected token: %s\n", yytext); return yytext[0]; }
.              { printf("Unexpected character: %s\n", yytext); return yytext[0]; }

%%

int yywrap() {
    return 1;
}
