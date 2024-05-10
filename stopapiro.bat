
SET DEF=apiro1

if NOT [%1] == [] (
   SET DEF=%1
)

echo shutting down %DEF%

docker compose -p %DEF% down

