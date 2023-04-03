#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\n~~ Random Number Guessing Game ~~\n"

SECRET_NUMBER=$(echo $(( RANDOM % 1000 + 1 )))

echo Enter your username:
read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

if [[ -z $USER_ID ]]
then
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")

  if [[ $INSERT_USER_RESULT == "INSERT 0 1" ]]
  then
    echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
  fi

  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
else
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games GROUP BY user_id HAVING user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games GROUP BY user_id HAVING user_id=$USER_ID")
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo -e "\nGuess the secret number between 1 and 1000:"
read GUESS
GUESS_COUNT=1

while [[ $GUESS -ne $SECRET_NUMBER ]]
do
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo -e "\nThat is not an integer, guess again:"
  else
    if [[ $GUESS > $SECRET_NUMBER ]]
    then
      echo -e "\nIt's lower than that, guess again:"
    else
      echo -e "\nIt's higher than that, guess again:"
    fi
  fi

  read GUESS
  GUESS_COUNT=$(( $GUESS_COUNT + 1 ))

done

echo -e "\nYou guessed it in $GUESS_COUNT tries. The secret number was $GUESS. Nice job!"
INSERT_GAME=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, $GUESS_COUNT)")
