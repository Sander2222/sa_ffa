# sa_ffa

## if you want to add a prebuild games then this is the Template

```lua
    {
        Name = -- This is the name the is shown to the players (string)
        Mode = -- This need to be the name from a mode in config.Modus (string) (upper and lower case is ignored)
        Map = -- This need to be the name from a map in config.map (string) (upper and lower case is ignored)
        MaxPlayer = -- this is the max player that can join a mode (integer)
    }
```

## if you want to add a mode then this is the Template

```lua
    {
        Name = -- This is the Name from the Mode (string),
        Icon = -- This need to be an icon name from this list (https://fontawesome.com/icons/) but you can let this emtpy if you dont want an icon (string),
        Weapons = {
            'weapon_sniperrifle', -- This is a list (array) from the weapons that are in this mode, you get the list from here: https://wiki.rage.mp/index.php?title=Weapons
            'weapon_heavysniper'
        }
    },
```

## if you want to add a map then this is the Template

```lua
    {
        Name = -- This is the Name from the Map (string), 
        MaxPlayer = -- This is the max player that can enter the Map (interger), 
        MapCenter = -- This is the Map Center where the distance get checked from (vector3),  
        MaxRadius = -- This is the max distance that the player can leave the area from ths MapCenter (integer), 
        Teleports = {
            vector3(1629.33, 2496.81, 44.56), -- This is a list (array) where all spawnpoints from the map are listed (vector3)
            vector3(1622.69, 2561.02, 44.56)
        }
    },
```
Important!!
to add the img for tha map the picture need to be an png and need to has the same name then the Name parameter. Add the picture in html/images/test.png


## Here are some exports


### Export to open FFA Search UI clientside (no result)
```lua
    exports['sa_ffa']:FFAUISearch()
```

### Export to check if the player is in a FFA Game clientside(result boolean)
```lua
    exports['sa_ffa']:IsPlayerInFFA()
```

### Export to check if the player is in a FFA Game clientside(result boolean)
```lua
    exports['sa_ffa']:LeaveFFA()
```

## If you have more questions just ask in the discord