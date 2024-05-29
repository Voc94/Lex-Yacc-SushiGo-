%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define DECK_SIZE 6
#define NUM_CARDS 11

void yyerror(const char *s);
int yylex();

const char* card_names[] = {
    "maki", "tempura", "sashimi", "dumpling", "salmon_nigiri", "squid_nigiri", "egg_nigiri", "nigiri", "pudding", "wasabi", "chopsticks"
};

typedef struct {
    int player_hand[DECK_SIZE];
    int ai_hand[DECK_SIZE];
    int player_deck[DECK_SIZE * 2];
    int ai_deck[DECK_SIZE * 2];
    int player_score;
    int ai_score;
    int pudding_count_player;
    int pudding_count_ai;
    int current_turn;
    int rounds_played;
} GameState;

GameState game;

void initialize_game();
void print_hand(int player_hand[], const char* player);
void print_deck(const char* player);
void ai_pick_card();
void pick_card(int card_value);
void add_to_deck(int deck[], int card);
void show_status();
int remove_card_from_hand(int hand[], int card);
int get_card_value(const char* card_name);
void end_round();
void save_decks_to_file(const char* filename, int player_deck[], int ai_deck[]);

%}

%union {
    int ival;
}

%token <ival> PICK SHOW PASS SCORE EOL END
%token <ival> MAKI TEMPURA SASHIMI DUMPLING SALMON_NIGIRI SQUID_NIGIRI EGG_NIGIRI NIGIRI PUDDING WASABI CHOPSTICKS

%type <ival> ingredient

%%

commands:
    | commands command
    | END EOL { 
        printf("Game over. Total rounds played: %d\n", game.rounds_played);
        save_decks_to_file("decks.txt", game.player_deck, game.ai_deck);
        exit(0); 
    }
    ;

command:
    pick_command
    | show_command
    | pass_command
    | error EOL { yyerrok; printf("Invalid command. Please try again.\n"); }
    ;

pick_command:
    PICK ingredient EOL { pick_card($2); ai_pick_card(); }
    ;

show_command:
    SHOW EOL { show_status(); }
    ;

pass_command:
    PASS EOL { ai_pick_card(); end_round(); }
    ;

ingredient:
    MAKI        { $$ = 0; }
    | TEMPURA     { $$ = 1; }
    | SASHIMI     { $$ = 2; }
    | DUMPLING    { $$ = 3; }
    | SALMON_NIGIRI { $$ = 4; }
    | SQUID_NIGIRI  { $$ = 5; }
    | EGG_NIGIRI    { $$ = 6; }
    | NIGIRI        { $$ = 7; }
    | PUDDING       { $$ = 8; }
    | WASABI        { $$ = 9; }
    | CHOPSTICKS    { $$ = 10; }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main() {
    initialize_game();
    yyparse();
    return 0;
}

void initialize_game() {
    srand(time(NULL));
    game.current_turn = 0;
    game.rounds_played = 1;
    game.player_score = 0;
    game.ai_score = 0;
    game.pudding_count_player = 0;
    game.pudding_count_ai = 0;
    for (int i = 0; i < DECK_SIZE; i++) {
        game.player_hand[i] = rand() % NUM_CARDS;
        game.ai_hand[i] = rand() % NUM_CARDS;
    }
    for (int i = 0; i < DECK_SIZE * 2; i++) {
        game.player_deck[i] = -1;
        game.ai_deck[i] = -1;
    }
    printf("Game initialized. Each player has %d cards.\n", DECK_SIZE);
    printf("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n");
    printf("Starting round 1\n");
}

void print_hand(int player_hand[], const char* player) {
    printf("%s hand: ", player);
    for (int i = 0; i < DECK_SIZE; i++) {
        if (player_hand[i] != -1) {
            printf("%s ", card_names[player_hand[i]]);
        } else {
            printf(" "); // Print a blank space for empty slots
        }
    }
    printf("\n");
}

void pick_card(int card_value) {
    // Ensure the card value is valid
    if (card_value < 0 || card_value >= NUM_CARDS) {
        printf("Invalid card value: %d\n", card_value);
        return;
    }

    if (game.current_turn >= DECK_SIZE * 2) {
        printf("All cards have been picked.\n");
        return;
    }

    // Try to remove the card from the player's hand
    if (!remove_card_from_hand(game.player_hand, card_value)) {
        printf("Card not in hand. Please pick a valid card.\n");
        return;
    }

    // Add the card to the player's deck
    game.player_deck[game.current_turn] = card_value;
    game.current_turn++;
}

void ai_pick_card() {
    if (game.current_turn >= DECK_SIZE * 2) return; // No more cards to pick

    int card_index = rand() % DECK_SIZE;
    while (game.ai_hand[card_index] == -1) {
        card_index = rand() % DECK_SIZE;
    }
    game.ai_deck[game.current_turn] = game.ai_hand[card_index];
    printf("AI picked %s.\n", card_names[game.ai_hand[card_index]]);
    game.ai_hand[card_index] = -1;
    game.current_turn++;

    for (int i = 0; i < DECK_SIZE; i++) {
        int temp = game.player_hand[i];
        game.player_hand[i] = game.ai_hand[i];
        game.ai_hand[i] = temp;
    }
    // Check if the round is complete after AI picks
    printf("Ending round %d\n", game.rounds_played);
    printf("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n");
    
    int player_hand_empty = 1;
    int ai_hand_empty = 1;
    for (int i = 0; i < DECK_SIZE; i++) {
        if (game.player_hand[i] != -1) player_hand_empty = 0;
        if (game.ai_hand[i] != -1) ai_hand_empty = 0;
    }

    if (player_hand_empty && ai_hand_empty) {
        printf("Game over. Total rounds played: %d\n", game.rounds_played);
        save_decks_to_file("decks.txt", game.player_deck, game.ai_deck);
        exit(0);
    }
    printf("Starting round %d\n", ++game.rounds_played);
}

void end_round() {
    int player_hand_empty = 1;
    int ai_hand_empty = 1;
    for (int i = 0; i < DECK_SIZE; i++) {
        if (game.player_hand[i] != -1) player_hand_empty = 0;
        if (game.ai_hand[i] != -1) ai_hand_empty = 0;
    }

    if (player_hand_empty && ai_hand_empty) {
        printf("Game over. Total rounds played: %d\n", game.rounds_played);
        save_decks_to_file("decks.txt", game.player_deck, game.ai_deck);
        exit(0);
    }

    // Swap hands between player and AI
    for (int i = 0; i < DECK_SIZE; i++) {
        int temp = game.player_hand[i];
        game.player_hand[i] = game.ai_hand[i];
        game.ai_hand[i] = temp;
    }

    printf("Starting round %d\n", ++game.rounds_played);
}

void print_deck(const char* player) {
    printf("%s deck: ", player);
    if (strcmp(player, "Player") == 0) {
        for (int i = 0; i < DECK_SIZE * 2; i++) {
            if (game.player_deck[i] != -1) {
                printf("%s ", card_names[game.player_deck[i]]);
            }
        }
    } else {
        for (int i = 0; i < DECK_SIZE * 2; i++) {
            if (game.ai_deck[i] != -1) {
                printf("%s ", card_names[game.ai_deck[i]]);
            }
        }
    }
    printf("\n");
}

int remove_card_from_hand(int hand[], int card) {
    for (int i = 0; i < DECK_SIZE; i++) {
        if (hand[i] == card) {
            hand[i] = -1;
            return 1; // Card found and removed
        }
    }
    return 0; // Card not found
}

void show_status() {
    print_hand(game.player_hand, "Player");
    print_hand(game.ai_hand, "AI");
    print_deck("Player");
    print_deck("AI");
}

void save_decks_to_file(const char* filename, int player_deck[], int ai_deck[]) {
    FILE *file = fopen(filename, "w");
    if (file == NULL) {
        printf("Error opening file %s for writing\n", filename);
        return;
    }
    fprintf(file, "Player Deck:\n");
    for (int i = 0; i < DECK_SIZE * 2; i++) {
        if (player_deck[i] != -1) {
            fprintf(file, "%s ", card_names[player_deck[i]]);
        }
    }
    fprintf(file,"\n");
    fprintf(file, "AI Deck:\n");
    for (int i = 0; i < DECK_SIZE * 2; i++) {
        if (ai_deck[i] != -1) {
            fprintf(file, "%s ", card_names[ai_deck[i]]);
        }
    }
    fprintf(file, "\n");
    fclose(file);
}
