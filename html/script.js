var CurrentMap
var MaxPlayerMap
var CurrentModus

window.addEventListener('message', async function (event) {
  var item = event.data;

  if (item.state === 'show') {
    if (item.type === "create") {
      
      $('body').show()
      $('.ffa-create').fadeIn();$('.ffa-liste').hide();$('.ffa-scoreboard').hide()

    } else if (item.type === "join") {

    } else if (item.type === "search") {

      $('body').show()
      $('.ffa-liste').fadeIn();$('.ffa-create').hide();$('.ffa-scoreboard').hide()

    } else if (item.type === "leave") {

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
      } else if (item.status === 'maps2') {

      }

    } else if (item.type === 'search') {

      // $(".ffa-items").html("");
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

  }
})

var PKills = 0
var PDeaths = 0 
var PRounded = NaN

async function ChangeScoreboards(kills, deaths, Name) {
  var rounded = Math.round(((kills / deaths) + Number.EPSILON) * 100) / 100;
  document.getElementById("skull-kill").style.animation = "";
  document.getElementById("ffa-ingame-players").innerText = Name;

  if ( (!isNaN(PRounded) ||  !isNaN(rounded))) {
    if (PRounded != rounded) {
      if (isNaN(rounded) || rounded === Infinity) {
        document.getElementById("ffa-ingame-kd").innerText = "0";
        // document.getElementById("add-kd").classList.add("action");
        await wait(0.5);
        // document.getElementById("add-kd").classList.remove("action");
      } else {
        document.getElementById("ffa-ingame-kd").innerText = rounded;
        // document.getElementById("add-kd").classList.add("action");
        await wait(0.5);
        // document.getElementById("add-kd").classList.remove("action");
      }
    PRounded = rounded
    }
  }

  if (PKills != kills) {
    // await triggerskull()
    document.getElementById("kills").innerText = kills;
    // document.getElementById("kill-title").classList.toggle("shine");
    await wait(1)
    // document.getElementById("kill-title").classList.toggle("shine");
    PKills = kills
  }

  if (PDeaths != deaths) {
    document.getElementById("deaths").innerText = deaths;
    // document.getElementById("death-title").classList.toggle("shine");
    await wait(1)
    // document.getElementById("death-title").classList.toggle("shine");
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
`) 
}

function AddFFA(Name, Password, Players, MaxPlayers, Map, Mode) {

  console.log("Existiert nicht");
    if(Password == 0 || Password == 1|| Password == '' || Password == ' ') {
      $(".liste").append(`
        <div class="ffa ${Name} NOPASSWORD">
          <div class="ffa-map ${Map}">
            <img src="images/${Map}.png">
            <div class="name">${Name}</div>
            <div class="players">${Players}/${MaxPlayers} Spieler</div>
          </div>
          <div class="Mode">Mode: <h1 class="Mode-Name">${Mode}</h1></div>
          <span>Passwort geschützt</span>
          <div class="ffa-password">
            <i class="fa-solid fa-lock"></i>
            <input type="text" placeholder="Password" id="${Password}">
          </div>
          <div class="join" onclick="JoinGame('${Name}','${Password}')">Beitreten</div>
        </div>
      `);
    }
    else {
      $(".liste").append(`
        <div class="ffa ${Name}-${Password}">
          <div class="ffa-map ${Map}">
            <img src="images/${Map}.png">
            <div class="name">${Name}</div>
            <div class="players">${Players}/${MaxPlayers} Spieler</div>
          </div>
          <div class="Mode">Mode: <h1 class="Mode-Name">${Mode}</h1></div>
          <span>Passwort geschützt</span>
          <div class="ffa-password">
            <i class="fa-solid fa-lock"></i>
            <input type="text" placeholder="Password" id="${Password}">
          </div>
          <div class="join" onclick="JoinGame('${Name}','${Password}')">Beitreten</div>
        </div>
      `);

    }
}

function JoinSearchedMatch(Name) {
  $.post('https://sa_ffa/JoinSearchedMatch', JSON.stringify({ Game: Name }));

  $(".ffa-items").html("");
  Close()
}

document.onkeyup = function (data) {
  if (data.which == 27) {
    Close()
  }
};

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

let blacklisted_words = ["nigger", "nigga", "niggers", "niger", "hitler", "adolf", "penis", "hurensohn", "nutte", "schwanz", "pedo", "milf", "hitl", "nega", "negga", "porn", "porno", "nazi", "anal", "shit", "neonazi", "huan", "huansohn", "hure"]

function create_ffa() {
  let input_name = document.getElementById("FFA-Name");
  let input_password = document.getElementById("FFA-Password");
  let input_maxplayers = document.getElementById("FFA-MaxPlayer");
  // "ffa_isroom_privat" |check if room is privat/public
  // "current_map" | get the name of current map
  log(input_maxplayers.value)

  if(input_name.value.length < 3) { // if input kleiner als 3 dann also (0,1,2)
    notify("FFA", "Name muss min 3 Zeichen haben", "error");
  }
  else if( document.getElementById('pw-on-off').checked && input_password.value.length <= 2) {
    notify("FFA", "Das Passwort muss mindestens 2 Zeichen lang sein", "error");
  }
  else if(input_maxplayers.value <= 1 || input_maxplayers.value.match(/[^0-9]/)) { // if input = 0 or 1 and input has letters
    notify("FFA", "Max Players ist kleiner als 2 oder hat einen Buchstaben", "error");
  }
  else if (input_maxplayers.value >= MaxPlayerMap) {
    notify("FFA", "Du hast mehr Max-Spieler angegeben als auf der Map erlaubt sind. Max:" + MaxPlayerMap + "", "error");
  }
  else if (blacklisted_words.some(v => input_name.value.toLowerCase().includes(v)) || hasSpecialChars(input_name.value)) {
    notify("FFA", "Der Name ist nicht gestattet!", "error");
  }
  else if (blacklisted_words.some(v => input_password.value.toLowerCase().includes(v)) || hasSpecialChars(input_password.value)) {
    notify("FFA", "Passwort ist nicht gestattet!", "error");
  }
  /* else if(input_name.value < 0 & input_password.value < 0 & input_maxplayers.value < 0) {
    console.log("Angaben nicht richtig");
  } */
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
  //display()
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

{/* <a onclick="$('.ffa-create').fadeIn();$('.ffa-liste').hide();$('.ffa-scoreboard').hide()">FFA Erstellen</a>
<a onclick="$('.ffa-liste').fadeIn();$('.ffa-create').hide();$('.ffa-scoreboard').hide()">FFA Suchen</a>
<a onclick="$('.ffa-scoreboard').fadeIn();$('.ffa-create').hide();$('.ffa-liste').hide()">FFA Scoreboard</a>

 */}

let mode = "Gambio";
let FFaSearch_Visuability = "Privat";

function SearchFFA(keys) {
  let FFAList = document.querySelector(".liste");
  let FFAs = FFAList.querySelectorAll(".ffa");

  FFAs.forEach((e) => {
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
  let FFAList = document.querySelector(".liste");
  let FFAs = FFAList.querySelectorAll(".ffa");
  FFAs.forEach((e) => {

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

function SearchMode(keys) {
  let FFAList = document.querySelector(".liste");
  let FFAs = FFAList.querySelectorAll(".ffa");

  FFAs.forEach((e) => {
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

/* Diese Funktion wird ausgeführt um den Modus bei der Liste zu nehmen und es in die [mode] Varible zu Speichern */
function change_mode(type, Name, Number) {
  log(type)
  log(Number)
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
  console.log("New MODUS: " + mode);
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
  console.log("New MAP: " + map);
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

function ChangeFFAVisual(type) {
  document.querySelector(".Privat").classList.remove("active");
  document.querySelector(".Öffentlich").classList.remove("active");
  document.querySelector(`.${type}`).classList.add("active");
  FFaSearch_Visuability = type;

  let FFAList = document.querySelector(".liste");
  let FFAs = FFAList.querySelectorAll(".ffa");

  console.log(FFaSearch_Visuability);

  if(type === 'Öffentlich') {
    FFAs.forEach((e) => {
      if(e.classList.contains("NOPASSWORD")) {
        console.log("Hat kein Passwort");
        FFAList.prepend(e);
        e.classList.remove('hidden');
      }
      else {
        console.log("Hat Passwort");
        e.classList.add("hidden")
      }
    })
  }
  else {
    FFAs.forEach((e) => {
      if(!e.classList.contains("NOPASSWORD")) {
        console.log("Hat kein Passwort");
        FFAList.prepend(e);
        e.classList.remove('hidden');
      }
      else {
        console.log("Hat Passwort");
        e.classList.add("hidden")
      }
    })

  }
}

function JoinGame(Name,Password) {
  let TheGameListItem = document.querySelector(`.${Name}-${Password}`);

  console.log(TheGameListItem.getElementsByTagName("input").value);
}

/* 
async function message(killer, target){
  await wait(0.5)
  let id = Math.random().toString(36).slice(2);
  
  $('.kill-feed').append(`
    <div class="new-kill" id="${id}">
      <span id="killer">${killer}</span>
      <span id="target">${target}</span>
    </div>
  
  `)
  $(`#${id}`).fadeIn();
  
  setTimeout( async ()=>{
    const toRemove = document.getElementById(id);
    await wait(0.2);
    document.getElementById(id).style.animation = "delete 1s forwards";
    await wait(1);
    toRemove.remove();
  }, 5000);
}
 */


async function wait(time) {
  return new Promise((resolve) => setTimeout(resolve, time * 1000));
}

function log(msg) {
  console.log(msg)
}