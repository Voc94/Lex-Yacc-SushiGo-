%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char *s);
int yylex();
extern FILE *yyin;

typedef struct {
    int player_score;
    int ai_score;
} GameState;

GameState game;
int is_ai_deck = 0;

void initialize_game();
void update_score(const char *player, int score, const char *combo_message);
%}

%union {
    int ival;
}

%token PLAYER DECK AI EOL
%token MAKI TEMPURA SASHIMI DUMPLING SALMON_NIGIRI SQUID_NIGIRI EGG_NIGIRI NIGIRI PUDDING WASABI CHOPSTICKS

%type <ival> ingredient ingredient_sequence combination

%%

commands:
    player_deck ai_deck
    ;

player_deck:
    PLAYER DECK EOL ingredient_sequence EOL
    ;

ai_deck:
    AI DECK EOL { is_ai_deck = 1; printf("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"); } ingredient_sequence EOL
    ;

ingredient_sequence:
    combination ingredient_sequence_tail
    ;

ingredient_sequence_tail:
    combination ingredient_sequence_tail
    | /* empty */
    ;

combination:
    four_ingredients
    | three_ingredients
    | two_ingredients
    | ingredient
    ;

ingredient:
    MAKI            { update_score(is_ai_deck ? "AI" : "Player", 3, "Maki = 3 points"); }
    | TEMPURA       { update_score(is_ai_deck ? "AI" : "Player", 2, "Tempura = 2 points"); }
    | SASHIMI       { update_score(is_ai_deck ? "AI" : "Player", 10, "Sashimi = 10 points"); }
    | DUMPLING      { update_score(is_ai_deck ? "AI" : "Player", 1, "Dumpling = 1 point"); }
    | SALMON_NIGIRI { update_score(is_ai_deck ? "AI" : "Player", 2, "Salmon Nigiri = 2 points"); }
    | SQUID_NIGIRI  { update_score(is_ai_deck ? "AI" : "Player", 3, "Squid Nigiri = 3 points"); }
    | EGG_NIGIRI    { update_score(is_ai_deck ? "AI" : "Player", 1, "Egg Nigiri = 1 point"); }
    | NIGIRI        { update_score(is_ai_deck ? "AI" : "Player", 1, "Nigiri = 1 point"); }
    | PUDDING       { update_score(is_ai_deck ? "AI" : "Player", 0, "Pudding = 0 points"); }
    | WASABI        { update_score(is_ai_deck ? "AI" : "Player", 0, "Wasabi = 0 points"); }
    | CHOPSTICKS    { update_score(is_ai_deck ? "AI" : "Player", 0, "Chopsticks = 0 points"); }
    ;
two_ingredients:
    MAKI TEMPURA { update_score(is_ai_deck ? "AI" : "Player", -2, "Bad Combo: Maki + Tempura = -2 points"); }
    | TEMPURA SASHIMI { update_score(is_ai_deck ? "AI" : "Player", -2, "Bad Combo: Tempura + Sashimi = -2 points"); }
    | SASHIMI DUMPLING { update_score(is_ai_deck ? "AI" : "Player", 3, "Good Combo: Sashimi + Dumpling = 3 points"); }
    | DUMPLING SALMON_NIGIRI { update_score(is_ai_deck ? "AI" : "Player", 3, "Good Combo: Dumpling + Salmon Nigiri = 3 points"); }
    | SALMON_NIGIRI WASABI { update_score(is_ai_deck ? "AI" : "Player", 6, "Good Combo: Salmon Nigiri + Wasabi = 6 points"); }
    | WASABI MAKI { update_score(is_ai_deck ? "AI" : "Player", -2, "Bad Combo: Wasabi + Maki = -2 points"); }
    | NIGIRI WASABI { update_score(is_ai_deck ? "AI" : "Player", 5, "Good Combo: Nigiri + Wasabi = 5 points"); }
    | PUDDING TEMPURA { update_score(is_ai_deck ? "AI" : "Player", -4, "Disgusting! Pudding + Tempura = -4 points"); }
    | CHOPSTICKS MAKI { update_score(is_ai_deck ? "AI" : "Player", 2, "Good Combo: Chopsticks + Maki = 2 points"); }
    | SQUID_NIGIRI EGG_NIGIRI { update_score(is_ai_deck ? "AI" : "Player", 4, "Good Combo: Squid Nigiri + Egg Nigiri = 4 points"); }
    | DUMPLING CHOPSTICKS { update_score(is_ai_deck ? "AI" : "Player", 2, "Good Combo: Dumpling + Chopsticks = 2 points"); }
    | MAKI NIGIRI { update_score(is_ai_deck ? "AI" : "Player", 3, "Good Combo: Maki + Nigiri = 3 points"); }
    | SALMON_NIGIRI SQUID_NIGIRI { update_score(is_ai_deck ? "AI" : "Player", 5, "Good Combo: Salmon Nigiri + Squid Nigiri = 5 points"); }
    | SASHIMI CHOPSTICKS { update_score(is_ai_deck ? "AI" : "Player", 4, "Good Combo: Sashimi + Chopsticks = 4 points"); }
    | EGG_NIGIRI DUMPLING { update_score(is_ai_deck ? "AI" : "Player", 3, "Good Combo: Egg Nigiri + Dumpling = 3 points"); }
    | PUDDING NIGIRI { update_score(is_ai_deck ? "AI" : "Player", -3, "Disgusting! Pudding + Nigiri = -3 points"); }
    | SQUID_NIGIRI CHOPSTICKS { update_score(is_ai_deck ? "AI" : "Player", 3, "Good Combo: Squid Nigiri + Chopsticks = 3 points"); }
    | SALMON_NIGIRI PUDDING { update_score(is_ai_deck ? "AI" : "Player", -4, "Bad Combo: Salmon Nigiri + Pudding = -4 points"); }
    ;

three_ingredients:
    SASHIMI TEMPURA DUMPLING { update_score(is_ai_deck ? "AI" : "Player", 5, "Big Combo: Sashimi + Tempura + Dumpling = 5 points"); }
    | SALMON_NIGIRI WASABI EGG_NIGIRI { update_score(is_ai_deck ? "AI" : "Player", 9, "Big Combo: Salmon Nigiri + Wasabi + Egg Nigiri = 9 points"); }
    | NIGIRI SASHIMI TEMPURA { update_score(is_ai_deck ? "AI" : "Player", 7, "Big Combo: Nigiri + Sashimi + Tempura = 7 points"); }
    | PUDDING CHOPSTICKS MAKI { update_score(is_ai_deck ? "AI" : "Player", 4, "Good Combo: Pudding + Chopsticks + Maki = 4 points"); }
    | TEMPURA DUMPLING WASABI { update_score(is_ai_deck ? "AI" : "Player", -5, "Disgusting! Tempura + Dumpling + Wasabi = -5 points"); }
    | MAKI SALMON_NIGIRI SQUID_NIGIRI { update_score(is_ai_deck ? "AI" : "Player", 6, "Big Combo: Maki + Salmon Nigiri + Squid Nigiri = 6 points"); }
    | EGG_NIGIRI CHOPSTICKS DUMPLING { update_score(is_ai_deck ? "AI" : "Player", 5, "Good Combo: Egg Nigiri + Chopsticks + Dumpling = 5 points"); }
    | PUDDING NIGIRI WASABI { update_score(is_ai_deck ? "AI" : "Player", -3, "Disgusting! Pudding + Nigiri + Wasabi = -3 points"); }
    | DUMPLING NIGIRI SASHIMI { update_score(is_ai_deck ? "AI" : "Player", 6, "Big Combo: Dumpling + Nigiri + Sashimi = 6 points"); }
    | SQUID_NIGIRI TEMPURA MAKI { update_score(is_ai_deck ? "AI" : "Player", 5, "Big Combo: Squid Nigiri + Tempura + Maki = 5 points"); }
    | CHOPSTICKS SALMON_NIGIRI NIGIRI { update_score(is_ai_deck ? "AI" : "Player", 7, "Good Combo: Chopsticks + Salmon Nigiri + Nigiri = 7 points"); }
    | SASHIMI SQUID_NIGIRI EGG_NIGIRI { update_score(is_ai_deck ? "AI" : "Player", 8, "Big Combo: Sashimi + Squid Nigiri + Egg Nigiri = 8 points"); }
    | MAKI PUDDING SASHIMI { update_score(is_ai_deck ? "AI" : "Player", -5, "Bad Combo: Maki + Pudding + Sashimi = -5 points"); }
    | TEMPURA SALMON_NIGIRI NIGIRI { update_score(is_ai_deck ? "AI" : "Player", 7, "Big Combo: Tempura + Salmon Nigiri + Nigiri = 7 points"); }
    | EGG_NIGIRI PUDDING CHOPSTICKS { update_score(is_ai_deck ? "AI" : "Player", -3, "Disgusting! Egg Nigiri + Pudding + Chopsticks = -3 points"); }
    ;

four_ingredients:
    MAKI TEMPURA SASHIMI DUMPLING { update_score(is_ai_deck ? "AI" : "Player", 10, "Extreme Combo: Maki + Tempura + Sashimi + Dumpling = 10 points"); }
    | WASABI SALMON_NIGIRI SQUID_NIGIRI EGG_NIGIRI { update_score(is_ai_deck ? "AI" : "Player", 12, "Extreme Combo: Wasabi + Salmon Nigiri + Squid Nigiri + Egg Nigiri = 12 points"); }
    | NIGIRI WASABI SALMON_NIGIRI TEMPURA { update_score(is_ai_deck ? "AI" : "Player", 15, "Extreme Combo: Nigiri + Wasabi + Salmon Nigiri + Tempura = 15 points"); }
    | PUDDING TEMPURA SASHIMI WASABI { update_score(is_ai_deck ? "AI" : "Player", -10, "Disgusting! Pudding + Tempura + Sashimi + Wasabi = -10 points"); }
    | MAKI CHOPSTICKS DUMPLING NIGIRI { update_score(is_ai_deck ? "AI" : "Player", 8, "Extreme Combo: Maki + Chopsticks + Dumpling + Nigiri = 8 points"); }
    | SQUID_NIGIRI EGG_NIGIRI NIGIRI PUDDING { update_score(is_ai_deck ? "AI" : "Player", 10, "Extreme Combo: Squid Nigiri + Egg Nigiri + Nigiri + Pudding = 10 points"); }
    | TEMPURA MAKI DUMPLING EGG_NIGIRI { update_score(is_ai_deck ? "AI" : "Player", 10, "Extreme Combo: Tempura + Maki + Dumpling + Egg Nigiri = 10 points"); }
    | SALMON_NIGIRI SASHIMI SQUID_NIGIRI WASABI { update_score(is_ai_deck ? "AI" : "Player", 12, "Extreme Combo: Salmon Nigiri + Sashimi + Squid Nigiri + Wasabi = 12 points"); }
    | DUMPLING NIGIRI MAKI CHOPSTICKS { update_score(is_ai_deck ? "AI" : "Player", 9, "Extreme Combo: Dumpling + Nigiri + Maki + Chopsticks = 9 points"); }
    | SASHIMI PUDDING TEMPURA SALMON_NIGIRI { update_score(is_ai_deck ? "AI" : "Player", -8, "Disgusting! Sashimi + Pudding + Tempura + Salmon Nigiri = -8 points"); }
    | EGG_NIGIRI SQUID_NIGIRI TEMPURA PUDDING { update_score(is_ai_deck ? "AI" : "Player", -8, "Disgusting! Egg Nigiri + Squid Nigiri + Tempura + Pudding = -8 points"); }
    | MAKI CHOPSTICKS SALMON_NIGIRI SASHIMI { update_score(is_ai_deck ? "AI" : "Player", 10, "Extreme Combo: Maki + Chopsticks + Salmon Nigiri + Sashimi = 10 points"); }
    | PUDDING NIGIRI WASABI SQUID_NIGIRI { update_score(is_ai_deck ? "AI" : "Player", -10, "Disgusting! Pudding + Nigiri + Wasabi + Squid Nigiri = -10 points"); }
    ;
%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main() {
    initialize_game();
    yyparse();

    printf("Player final score: %d\n", game.player_score);
    printf("AI final score: %d\n", game.ai_score);

    return 0;
}

void initialize_game() {
    game.player_score = 0;
    game.ai_score = 0;
    printf("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n");
}

void update_score(const char *player, int score, const char *combo_message) {
    if (strcmp(player, "AI") == 0) {
        game.ai_score += score;
    } else {
        game.player_score += score;
    }
    printf("%s %s\n", player, combo_message);
}
