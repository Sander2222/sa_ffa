JSConfig = []

// Thoose words are blacklisted for ffa names
JSConfig.BlacklistedWords = ['nigger', 'nigga', 'niggers', 'niger', 'hitler', 'adolf', 'dick', 'bitch', 'cunt', 'schwanz', 'pedo', 'milf', 'hitl', 'nega', 'negga', 'porn', 'porno', 'nazi', 'anal', 'shit', 'neonazi', 'fuck', 'Bastard', 'suck', 'Jerk', 'Dumbass', 'Asshole', 'Motherfucker']

JSConfig.MinLengthName = 3
JSConfig.MinLengthPassword = 3
JSConfig.MinMaxPlayer = 2
JSConfig.MaxTime = 20
 
JSConfig.Locals = {
    // Create Window
    'Name': 'Name',
    'Password': 'Password',
    'CreateFFAText': 'Create Your FFA',
    'EnterData': 'Enter here',
    'MaxPlayer': 'Max Player',
    'ChooseMode': 'Choose Mode',
    'ChooseMap': 'Choose Map',
    'CreateFFA': 'Create FFA',
    'Time': 'Timer',

    // FFA List
    'FFAListText': 'FFA List',
    'Private': 'Private',
    'Public': 'Public',
    'Mode': 'Mode',
    'Map': 'Map',
    'EnterName': 'Enter the game name',
    'NoPassword': 'Not password protected',
    'Join': 'Join',
    'Player': 'Player',
    'PasswordProtected': 'Password Protected',
    'Create': 'Create',
    'Search': 'Search',
    'NoGamesFound': 'No games found!',

    // KDA
    'kills': 'KILLS',
    'death': 'DEATHS',
    'FFAStatsText': 'FFA STATS',
    'GameTimeText': 'Time',
    'KDText': 'KD',

    // Error
    'WrongPassword': 'The password does not match',
    'NotEnoughCharactersName': 'Name must have min ' + JSConfig.MinLengthName + ' characters',
    'NotEnoughCharactersPassword': 'Password must have min ' + JSConfig.MinLengthPassword + ' characters',
    'NoNotEnoughCharactersPlayer': 'Max Players is less than ' + JSConfig.MinMaxPlayer + ' or has one letter',
    'ToMuchPlayer': 'You have specified more Max players than are allowed on the map. Max: ',
    'BlackListName': 'This name is on the blacklist',
    'BlackListPassword': 'This password is on the blacklist',
    'NoModeSelected': 'You need to select a mode',
    'NoMapSelected': 'You need to select a map',
    'TimeToHigh': 'You can set your maximum time to: ' + JSConfig.MaxTime + 'and at least 1',
    'NoTimeInput': 'You need to enter Time',
}