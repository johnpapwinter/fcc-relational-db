#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
	if [[ $YEAR != year ]]
	then
		# SEARCH IF TEAMS ALREADY EXIST
		WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
		OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
		
		# INSERT WINNING TEAM
		if [[ -z $WINNER_ID ]]
		then
			INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
			WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
			if [[ $INSERT_WINNER_RESULT == "INSERT 0 1" ]]
			then
				echo "Inserted team $WINNER"
			fi
		fi
		
		# INSERT OPPOSING TEAM
		if [[ -z $OPPONENT_ID ]]
		then
			INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
			OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
			if [[ $INSERT_WINNER_RESULT == "INSERT 0 1" ]]
			then
				echo "Inserted team $OPPONENT"
			fi
		fi

		# INSERT GAMES
		INSERTED_GAME=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) 
					VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
		if [[ $INSERTED_GAME == "INSERT 0 1" ]]
		then
			echo "Inserted game $YEAR $ROUND"
		fi
	fi
done
