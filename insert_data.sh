#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
$PSQL "TRUNCATE TABLE teams RESTART IDENTITY CASCADE;"
tail -n +2 ./games.csv | awk -F, '{print $3"\n"$4}' | sort | uniq > tmp_teams.txt

$PSQL "\copy teams(name) FROM 'tmp_teams.txt'"
rm tmp_teams.txt

$PSQL "TRUNCATE TABLE games RESTART IDENTITY CASCADE;"

$PSQL "CREATE TABLE IF NOT EXISTS temp_games(
  year INT,
  round VARCHAR,
  winner_name VARCHAR,
  opponent_name VARCHAR,
  winner_goals INT,
  opponent_goals INT
  );
  "
$PSQL "\copy temp_games FROM './games.csv' DELIMITER ',' CSV HEADER;"
$PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals)
  SELECT
  tmp.year,
  tmp.round,
  winner.team_id,
  opponent.team_id,
  tmp.winner_goals,
  tmp.opponent_goals
  FROM temp_games tmp
  JOIN teams winner ON tmp.winner_name = winner.name
  JOIN teams opponent ON tmp.opponent_name = opponent.name;"

  $PSQL "DROP TABLE temp_games;"
