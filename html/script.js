var CurrentMap
var MaxPlayerMap
var CurrentModus
var CurrentWindow

document.addEventListener("DOMContentLoaded", () => {
  $('.ffa-scoreboard').hide();
  $('.ffa-create').hide();
  $('.ffa-liste').hide();

  // Load Data from config
  document.getElementById("FFA-Name").placeholder = JSConfig.Locals.Name;
  document.getElementById("FFA-Password").placeholder = JSConfig.Locals.Password;
  document.getElementById("FFA-MaxPlayer").placeholder = JSConfig.Locals.MaxPlayer;
  document.getElementById("Search-Mode").placeholder = JSConfig.Locals.Mode;
  document.getElementById("Search-Map").placeholder = JSConfig.Locals.Map;
  document.getElementById("Search-Name").placeholder = JSConfig.Locals.EnterName;
  document.getElementById("CreateFFAText").innerHTML  = JSConfig.Locals.CreateFFAText;
  document.getElementById("EnterThinks").innerHTML  = JSConfig.Locals.EnterData;
  document.getElementById("btn-change-mode").innerHTML  = JSConfig.Locals.ChooseMode;
  document.getElementById("btn-change-map").innerHTML  = JSConfig.Locals.ChooseMap;
  document.getElementById("CreateFFAButton").innerHTML  = JSConfig.Locals.CreateFFA;
  document.getElementById("FFAListText").innerHTML  = JSConfig.Locals.FFAListText;
  document.getElementById("PrivateText").innerHTML  = JSConfig.Locals.Private;
  document.getElementById("PuplicText").innerHTML  = JSConfig.Locals.Puplic;

  document.getElementById("searchid").innerHTML  = JSConfig.Locals.Create;
  document.getElementById("createId").innerHTML  = JSConfig.Locals.Search;

  // KDA
  document.getElementById("kill-title").innerHTML  = JSConfig.Locals.kills;
  document.getElementById("death-title").innerHTML  = JSConfig.Locals.death;
  document.getElementById("FFAStatsText").innerHTML  = JSConfig.Locals.FFAStatsText;
  document.getElementById("GameNameText").innerHTML  = JSConfig.Locals.GameNameText;
  document.getElementById("KDText").innerHTML  = JSConfig.Locals.KDText;
})

function ClearCreateInputs() {
  document.getElementById('FFA-Name').value='';
  document.getElementById('FFA-Password').value='';
  document.getElementById('FFA-MaxPlayer').value='';
  document.getElementById('FFA-Name').value='';
  document.getElementById('FFA-Name').value='';

  // Mein Code
  // document.getElementById('btn-change-mode').innerHTML= '';
  // document.getElementById('btn-change-map').innerHTML= '';

  // CurrentMap = null
  // CurrentModus = null
}

window.addEventListener('message', async function (event) {
  var item = event.data;

  if (item.state === 'show') {
    ClearCreateInputs()
    if (item.type === "search") {
      Change_Window('list')
      $('.switcher').fadeIn()
      $('body').show()
      $('.ffa-liste').fadeIn();$('.ffa-create').hide();$('.ffa-scoreboard').hide()
    } else if (item.type === "score") {
      $('body').show()
      $('.ffa-scoreboard').fadeIn();$('.ffa-create').hide();$('.ffa-liste').hide()
    }
  } else if (item.state === 'add') {
    if (item.type === 'create') {
      if (item.status === 'modus') {
        AddMode(item.ModeNumber, item.ModeName, item.Icon, item.Title)
      } else if (item.status === 'maps') {
        AddMap(item.MapNumber, item.ModeName, item.MapMaxPlayer )
      }
    } else if (item.type === 'search') {
       if (item.maxplayers != null && item.maxplayers != undefined) {
        AddFFA(item.name, item.password, item.players, item.maxplayers, item.map, item.modus)
      }
    } else if (item.type === 'score') {
      var kills = item.kill
      var deaths = item.death
      ChangeScoreboards(kills, deaths, item.Name)
    }
  } else if (item.state === 'close') {
    $('body').hide()
    $('.switcher').fadeOut()
  }
})

var PKills = 0
var PDeaths = 0 
var PRounded = NaN

async function ChangeScoreboards(kills, deaths, Name) {
  var rounded = Math.round(((kills / deaths) + Number.EPSILON) * 100) / 100;
  document.getElementById("skull-kill").style.animation = "";
  if (typeof Name !== "undefined") {
    if(Name.length > 6) {
      document.getElementById("ffa-ingame-players").innerText = Name[0] + Name[1] + Name[2] + Name[3] + Name[4] + Name[5] + Name[6] + Name[7] + "..";
    } else {
      document.getElementById("ffa-ingame-players").innerText = Name;
    }
  }

  if ( (!isNaN(PRounded) ||  !isNaN(rounded))) {
    if (PRounded != rounded) {
      if (isNaN(rounded) || rounded === Infinity) {
        document.getElementById("ffa-ingame-kd").innerText = "0";
        await wait(0.5);
      } else {
        document.getElementById("ffa-ingame-kd").innerText = rounded;
        await wait(0.5);
      }
    PRounded = rounded
    }
  }

  if (PKills != kills) {
    document.getElementById("kills").innerText = kills;
    await wait(1)
    PKills = kills
  }

  if (PDeaths != deaths) {
    document.getElementById("deaths").innerText = deaths;
    await wait(1)
    PDeaths = deaths
  }
}

function AddMode(Number, Name, Icon, Title) {
  $('.mode-menu').append(`
  <div class="modus ${Title}" onclick="change_mode('${Title}', '${Name}', ${Number})">
  <i class="${Icon}"></i>
  <span>${Name}</span>
</div>`
)
}

function setmode(mode, name) {
  ffa_mode = mode;
  ffa_mode_name = name;
  
  document.getElementById("ffa-mode").innerText = "Mode: " + name;
}

function AddMap(Number, Name, MaxPlayer) {
  $('.map-menu').append(`
  <div class="map ${Name}" onclick="change_map('${Name}', ${Number}, ${MaxPlayer})">
      <img src="images/${Name}.png">
      <span>${Name}</span>
  </div>
`)}

function AddFFA(Name, Password, Players, MaxPlayers, Map, Mode) {

    if(Password == 0 || Password == 1|| Password == '' || Password == ' ') {
      $(".liste-öffentlich").append(`
        <div class="ffa ${Name} NOPASSWORD">
          <div class="ffa-map ${Map}">
            <img src="images/${Map}.png">
            <div class="name">${Name}</div>
            <div class="players">${Players}/${MaxPlayers} ${JSConfig.Locals.Player}</div>
          </div>
          <div class="Mode">${JSConfig.Locals.Mode}: <h1 class="Mode-Name">${Mode}</h1></div>
          <span id="dingsbums2">${JSConfig.Locals.NoPassword}</span>
          <div class="join" onclick="JoinGame('${Name}','${Password}')">${JSConfig.Locals.Join}</div>
        </div>
      `);
    }
    else {
      $(".liste-privat").append(`
        <div class="ffa ${Name}-${Password}">
          <div class="ffa-map ${Map}">
            <img src="images/${Map}.png">
            <div class="name">${Name}</div>
            <div class="players">${Players}/${MaxPlayers} ${JSConfig.Locals.Player}</div>
          </div>
          <div class="Mode">${JSConfig.Locals.Mode}: <h1 class="Mode-Name">${Mode}</h1></div>
          <span id="dingsbums1">${JSConfig.Locals.PasswordProtected}</span>
          <div class="ffa-password">
            <i class="fa-solid fa-lock"></i>
            <input type="text" placeholder="Password" id="${Password}">
          </div>
          <div class="join" onclick="JoinGame('${Name}','${Password}')">${JSConfig.Locals.Join}</div>
        </div>
      `);

    }
}

function JoinSearchedMatch(Name) {
  $.post('https://sa_ffa/JoinSearchedMatch', JSON.stringify({ Game: Name }));

  $(".ffa-items").html("");
  Close()
}

function Close() {
  ClearMapsModus();
  $.post('https://sa_ffa/exit', JSON.stringify({}));
}

function hasSpecialChars(str) {
  const specialCharsSet = new Set('^[!@#%/^&*()_+\-=\[\]{};:"|,.<>\/?]*$');
  for (let letter of str) {
    if (specialCharsSet.has(letter)) {
      return true;
    }
  }
  return false;
}

function create_ffa() {
  let input_name = document.getElementById("FFA-Name");
  let input_password = document.getElementById("FFA-Password");
  let input_maxplayers = document.getElementById("FFA-MaxPlayer");
  // "ffa_isroom_privat" |check if room is privat/public
  // "current_map" | get the name of current map

  if(input_name.value.length < JSConfig.MinLengthName) { // if input kleiner als 3 dann also (0,1,2)
    notify("FFA", JSConfig.Locals.NotEnoughCharactersName, "error");
  }
  else if( document.getElementById('pw-on-off').checked && input_password.value.length < JSConfig.MinLengthPassword) {
    notify("FFA", JSConfig.Locals.NotEnoughCharactersPassword, "error");
  }
  else if(input_maxplayers.value < JSConfig.MinMaxPlayer || input_maxplayers.value.match(/[^0-9]/)) { // if input = 0 or 1 and input has letters
    notify("FFA", JSConfig.Locals.NoNotEnoughCharactersPlayer, "error");
  }
  else if (input_maxplayers.value >= MaxPlayerMap) {
    notify("FFA", JSConfig.Locals.ToMuchPlayer + MaxPlayerMap, "error");
  }
  else if (JSConfig.BlacklistedWords.some(v => input_name.value.toLowerCase().includes(v)) || hasSpecialChars(input_name.value)) {
    notify("FFA", JSConfig.Locals.BlackListName, "error");
  }
  else if (JSConfig.BlacklistedWords.some(v => input_password.value.toLowerCase().includes(v)) || hasSpecialChars(input_password.value)) {
    notify("FFA", JSConfig.Locals.BlackListPassword, "error");
  }
  else if (!CurrentModus) {
    notify("FFA", JSConfig.Locals.NoModeSelected, "error");
  } else if (!CurrentMap) {
    notify("FFA", JSConfig.Locals.NoMapSelected, "error");
  }
  else {

    var checked = 0

    if (document.getElementById('pw-on-off').checked) {
      checked = 1
    } else {
      checked = 0
    }

    ClearMapsModus()
    $.post('https://sa_ffa/CreateGame', JSON.stringify({
    Name: input_name.value,
    Password: input_password.value,
    MaxPlayer: input_maxplayers.value,
    Mode: CurrentModus,
    Private: checked,
    Map: CurrentMap
    }));
  }
}

async function notify(title, message, type) {
  let id = Math.random().toString(36).slice(2);
  
  $(".notify-area").append(`
  <div class="notify ${type}" id="notify-${id}">
  <audio src="assets/sounds/notify_in.mp3" id="notify-soundin-${id}"></audio>
  <audio src="assets/sounds/notify_out.mp3" id="notify-soundout-${id}"></audio>
  <h1 class="${type}">${title}</h1>
  <h2>${message}</h2>
  </div>
  `);
  
  setTimeout(async () => {
    const toRemove = document.getElementById(`notify-${id}`);

    toRemove.style.animation = "backOutLeft 1s forwards";
    $(`#${id}`).fadeOut();
    await wait(1);
    toRemove.remove();
  }, 5000);
}

function ClearMapsModus() {
  $(".liste").empty();
  $('.map-menu').empty();
  $('.mode-menu').empty();
}

let mode = "Gambio";
let FFaSearch_Visuability = "Privat";

function SearchFFA(keys) {
  var FFAList;

  if(FFaSearch_Visuability === 'Öffentlich') {
    FFAList = document.querySelector(".liste-öffentlich");
  }
  else {
    FFAList = document.querySelector(".liste-privat");
  }

  let ffas = FFAList.querySelectorAll(".ffa");

  ffas.forEach((e) => {
    if (
      e
        .querySelector(".ffa-map")
        .querySelector(".name")
        .innerText.toLowerCase()
        .includes(keys.toLowerCase())
    ) {
      e.classList.remove("hidden");
      FFAList.prepend(e);
    } else {
      e.classList.add("hidden");
    }
  });
}

function SearchMap(keys) {
  var FFAList;

  if(FFaSearch_Visuability === 'Öffentlich') {
    FFAList = document.querySelector(".liste-öffentlich");
  }
  else {
    FFAList = document.querySelector(".liste-privat");
  }

  let ffas = FFAList.querySelectorAll(".ffa");

  ffas.forEach((e) => {

    if(e.querySelector(".ffa-map").classList.forEach((elem) => {
      if(elem.toLowerCase().includes(keys.toLowerCase())) {
        e.classList.remove("hidden");
        FFAList.prepend(e);
      }
      else {
        e.classList.add("hidden");
      }
    }));
  });
}


/* Diese Funktion wird ausgeführt um den Modus bei der Liste zu nehmen und es in die [mode] Varible zu Speichern */
function change_mode(type, Name, Number) {
  let Modelist = document.querySelector(".mode-menu");
  let Modes = Modelist.querySelectorAll(".modus");
  let Current_Mode = document.querySelector(`.${type}`);
  CurrentModus = Number;
  
  $('#btn-change-mode').css("color", "rgba(255,255,255,1)");
  document.getElementById("btn-change-mode").innerText = Name;
  
  Modes.forEach((e) => {
    e.classList.remove("active");
  });
  Current_Mode.classList.add("active");
  mode = Name;
  $('.mode-menu').hide('slow');
  already_mode = false
}

/* Diese Funktion wird ausgeführt um die Map bei der Liste zu nehmen und es in die [map] Varible zu Speichern */
function change_map(type, Number, MaxPlayer) {
  let Modelist = document.querySelector(".map-menu");
  let Modes = Modelist.querySelectorAll(".map");
  let Current_Map = document.querySelector(`.${type}`);
  CurrentMap = Number
  MaxPlayerMap = MaxPlayer
  
  $('#btn-change-map').css("color", "rgba(255,255,255,1)");
  document.getElementById("btn-change-map").innerText = type;
  
  Modes.forEach((e) => {
    e.classList.remove("active");
  });
  Current_Map.classList.add("active");
  map = type;

  $('.map-menu').hide('slow');
  already_map = false
}

/* Diese Funktion ist nur für den Map Slide zu öffnen */
let already_map = false;
function open_maps() {
  if (!already_map) {
    already_map = true;
    $(".map-menu").fadeIn();
  } else {
    already_map = false;
    $(".map-menu").fadeOut();
  }
}

/* Diese Funktion ist nur für den Mode Slide zu öffnen */
let already_mode = false;
function open_modes() {
  if (!already_mode) {
    already_mode = true;
    $(".mode-menu").fadeIn();
  } else {
    already_mode = false;
    $(".mode-menu").fadeOut();
  }
}

function SearchMode(keys) {
  var FFAList;

  if(FFaSearch_Visuability === 'Öffentlich') {
    FFAList = document.querySelector(".liste-öffentlich");
  }
  else {
    FFAList = document.querySelector(".liste-privat");
  }

  let ffas = FFAList.querySelectorAll(".ffa");

  ffas.forEach((e) => {
    if (
      e
        .querySelector(".Mode-Name")
        .innerText.toLowerCase()
        .includes(keys.toLowerCase())
    ) {
      e.classList.remove("hidden");
      FFAList.prepend(e);
    } else {
      e.classList.add("hidden");
    }
  });
}

function ChangeFFAVisual(type) {
  document.querySelector(".Privat").classList.remove("active");
  document.querySelector(".Öffentlich").classList.remove("active");
  document.querySelector(`.${type}`).classList.add("active");
  FFaSearch_Visuability = type;
  
  let FFAList = document.querySelector(`.liste-${type.toLowerCase()}`);
  let FFAs = FFAList.querySelectorAll(".ffa");
  
  if(type === 'Öffentlich') {
    $('.liste-privat').fadeOut();
    $('.liste-öffentlich').fadeIn();
    FFAs.forEach((e) => {
      if(e.classList.contains("NOPASSWORD")) {
        FFAList.prepend(e);
        e.classList.remove('hidden');
      }
      else {
        e.classList.add("hidden")
      }
    })
  }
  else {
    $('.liste-privat').fadeIn();
    $('.liste-öffentlich').fadeOut();
    FFAList.style.display = "block";
    FFAs.forEach((e) => {
      if(!e.classList.contains("NOPASSWORD")) {
        FFAList.prepend(e);
        e.classList.remove('hidden');
      }
      else {
        e.classList.add("hidden")
      }
    })

  }
}

function JoinGame(Name, Password) {
  var UserPassword = document.getElementById(Password).value
  if (Password == UserPassword) {
    JoinSearchedMatch(Name)
  } else {
    notify("FFA Join", JSConfig.Locals.WrongPassword, "error")
  }
}

async function wait(time) {
  return new Promise((resolve) => setTimeout(resolve, time * 1000));
}

function log(msg) {
  console.log(msg)
}

function Change_Window(window) {
  document.querySelector(".switcher-list").classList.remove("active");
  document.querySelector(".switcher-create").classList.remove("active");
  document.querySelector(`.switcher-${window}`).classList.add("active");

  switch(window) {
    case 'list':
      $('.ffa-create').fadeOut();
      $('.ffa-liste').fadeIn();
      break;
    case 'create':
      $('.ffa-liste').fadeOut();
      $('.ffa-create').fadeIn();
      break;
  }

  CurrentWindow = window;
}