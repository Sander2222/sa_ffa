var windows = ["ffa-create", "ffa-liste", "ffa-ui", "ffa-info-card", "ffa-join", "ffa-search"]


window.addEventListener('message', async function (event) {
  var item = event.data;

  if (item.state === 'show') {
    if (item.type === "create") {
      
      display()
      change_window("ffa-create")
      $('body').show()

    } else if (item.type === "join") {

    } else if (item.type === "search") {

      display()
      change_window(1)

      $('body').show()

    } else if (item.type === "leave") {

    } else if (item.type === "score") {

      display()
      change_window("ffa-ui")

      $('body').show()

    }
  } else if (item.state === 'add') {
    if (item.type === 'create') {

      AddMode(item.ModeNumber, item.ModeName)
    } else if (item.type === 'search') {

      $(".ffa-items").html("");
      if (item.maxplayers != null && item.maxplayers != undefined) {
        AddGameSearch(item.maxplayers, item.players, item.modus, item.map, item.name)
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
  document.getElementById("ffa-ingame-name").innerText = Name;

  if ( (!isNaN(PRounded) ||  !isNaN(rounded))) {
    if (PRounded != rounded) {
      if (isNaN(rounded) || rounded === Infinity) {
        document.getElementById("ffa-ingame-kd").innerText = "0";
        document.getElementById("add-kd").classList.add("action");
        await wait(0.5);
        document.getElementById("add-kd").classList.remove("action");
      } else {
        document.getElementById("ffa-ingame-kd").innerText = rounded;
        document.getElementById("add-kd").classList.add("action");
        await wait(0.5);
        document.getElementById("add-kd").classList.remove("action");
      }
    PRounded = rounded
    }
  }

  if (PKills != kills) {
    await triggerskull()
    document.getElementById("kills").innerText = kills;
    document.getElementById("kill-title").classList.toggle("shine");
    await wait(1)
    document.getElementById("kill-title").classList.toggle("shine");
    PKills = kills
  }

  if (PDeaths != deaths) {
    document.getElementById("deaths").innerText = deaths;
    document.getElementById("death-title").classList.toggle("shine");
    await wait(1)
    document.getElementById("death-title").classList.toggle("shine");
    PDeaths = deaths
  }
}

function AddMode(ModeNumber, ModeName) {
  $('.slide').append(`

  <li><a id="${ModeNumber}" onclick="setmode(${ModeNumber}, '${ModeName}')">${ModeName}</a></li>

`)
}

function AddGameSearch(MaxPlayer, Player, Modus, Map, Name) {

  $('.ffa-items').append(`
  <div class="ffa">
  <p>${Map}</p>
  <hr class="center-diamond">
  <img src="images/${Map}.webp">

  <div class="ffa-infos">
      <h1>Players:</h1>
      <span>${Player}/${MaxPlayer}</span>
      <h2>Mode:</h2>
      <span>${Modus}</span>
  </div>
  
  <button onclick="JoinSearchedMatch('${Name}')">BEITRETEN</button>
</div>
  `)
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
  $.post('https://sa_ffa/exit', JSON.stringify({}));
}






function create_ffa() {
  let input_name = document.getElementById("ffa-create-name");
  let input_password = document.getElementById("ffa-create-password");
  let input_maxplayers = document.getElementById("ffa-create-maxplayers");
  // "ffa_isroom_privat" |check if room is privat/public
  // "current_map" | get the name of current map

  if(input_name.value.length < 3) { // if input kleiner als 3 dann also (0,1,2)
    notify("FFA", "Name muss min 3 Zeichen haben", "error");
  }
  else if(input_password.value.length <= 2) {
    notify("FFA", "Das Passwort muss mindestens 2 Zeichen lang sein", "error");
  }
  else if(input_maxplayers.value <= 1 || input_maxplayers.value.match(/[^0-9]/)) { // if input = 0 or 1 and input has letters
    notify("FFA", "Max Players ist kleiner als 2 oder hat einen Buchstaben", "error");
  }
  else if (blacklisted_words.some(v => input_name.value.toLowerCase().includes(v)) || hasSpecialChars(input_name.value)) {
    notify("FFA", "Der Name ist nicht gestattet!", "error");
  }
  else if (blacklisted_words.some(v => input_password.value.toLowerCase().includes(v)) || hasSpecialChars(input_password.value)) {
    notify("FFA", "Passwort ist nicht gestattet!", "error");
  }
  else if(ffa_mode === "") {
    notify("FFA", "Keinen Modus ausgewählt!", "error")
  }
  else if(ffa_mode_name === "" || ffa_mode === "" || ffa_mode_name === null || ffa_mode === null) {
    notify("FFA", "Modus nicht gewählt!", "error")
  }
  /* else if(input_name.value < 0 & input_password.value < 0 & input_maxplayers.value < 0) {
    console.log("Angaben nicht richtig");
  } */
  else {
    $.post('https://sa_ffa/CreateGame', JSON.stringify({
    Name: input_name.value,
    Password: input_password.value,
    MaxPlayer: input_maxplayers.value,
    Private: ffa_isroom_privat,
    Mode: ffa_mode,
    Map: current_map
    }));
  }
  //display()
}

































var currentIndex = 1;
var current_map = null;
var ffa_mode = null;
var ffa_mode_name = "";
var ffa_isroom_privat = false;
let current_index = 1;

const ffa_create_name = document.getElementById("ffa-create-name");
const ffa_create_password = document.getElementById("ffa-create-password");
const ffa_create_maxplayers = document.getElementById("ffa-create-maxplayers");

const ffa_join_name = document.getElementById("ffa-join-name");
const ffa_join_password = document.getElementById("ffa-join-password");

const ffa_infos_players = document.getElementById("ffa-infos-players");
const ffa_infos_mode = document.getElementById("ffa-infos-mode");

const ffa_ingame_players = document.getElementById("ffa-ingame-players");
const ffa_ingame_kd = document.getElementById("ffa-ingame-kd");
const ffa_player_kills = document.getElementById("kills");
const ffa_player_deaths = document.getElementById("deaths");


$(document).ready(async function () {
  // display()
  // change_window("ffa-liste")
    $('body').hide()
  
  //showinput()
  
  //notify("FFA", "Du hast eine Killstreak von 10 Kills", "success")
  //notify("FFA", "Du hast eine Killstreak von 10 Kills", "success")
  
  //loader(1)
  //$('.ffa-create *').hide()
  
  document.getElementById("inpLock").onclick = function() {
    ffa_isroom_privat = document.getElementById("inpLock").checked;
    if(document.getElementById("inpLock").checked === true) {
      document.getElementById("room-type").innerText = "Room: Privat";
      document.getElementById("room-type").style.color = "#f00";
      document.getElementById("room-type").style.textShadow = "0 0 5px #f00";
    }
    else {
      document.getElementById("room-type").innerText = "Room: Public";
      document.getElementById("room-type").style.color = "#0f0";
      document.getElementById("room-type").style.textShadow = "0 0 5px #0f0";
    }
  }
});

async function showinput() {
  const input_cancelbtn = document.getElementById("cancel-btn");
  const input_confirmbtn = document.getElementById("confirm-btn");
  const input_content = document.getElementById("ffa-search-name");
  
  $(`#input_mainwindow`).fadeIn();
  
  input_confirmbtn.addEventListener("click", function() {
    if(input_content.value === "") {
      notify("FFA", "Eingabe ungültig", "error")
    }
    else {
      $(`#input-window`).fadeOut();
      join_searched_room()
    }
  })
  input_cancelbtn.addEventListener("click", function() {
    $(`#input-window`).fadeOut();
  })
  
  //await document.getElementById("cancel-btn").onclick()
  
}

function join_searched_room(id) {
  let room_id = id;
  
  notify("FFA", "Raum wird betreten")
}

function loader(time) {
  $(".loader").fadeIn();
  $(".ffa-menu").hide();
  $(".ffa-menu::before").show();
  setTimeout(() => {
    $(".loader").fadeOut();
    $(".ffa-menu").fadeIn();
  }, time * 1000)
}

function setmode(mode, name) {
  ffa_mode = mode;
  ffa_mode_name = name;
  
  document.getElementById("ffa-mode").innerText = "Mode: " + name;
  console.log("FFA MODE: " + ffa_mode_name)
}


function display() {
  for(screens of windows)
  if(screens !== "ffa-menu") {
    $(`.${screens}`).hide();
  }
}

function change_window(window) {
  for (wind of windows) {
    if(window === wind) {
      $(`.${window}`).fadeIn();
    }
    else {
      $(`.${wind}`).hide();
    }
  }
  if(window === "ffa-search") {
    for(var a=0;a<10;a++) {
      add_game(`Arena-${Math.random().toString(36).slice(8)}`, "2", "10", "Rage", "Schrottplatz")
    }
  }
  if(window === "ffa-create") {
    document.getElementById("inpLock").checked = true;
    document.getElementById("room-type").innerText = "Room: Privat";
    document.getElementById("room-type").style.color = "#f00";
    document.getElementById("room-type").style.textShadow = "0 0 5px #f00";
    change_ffa_map(0)
  }
}

let ffa_pics = [
  {name: "assets/images/ffa-orte/Würfelpark.webp", label: "Würfelpark", index: 1},
  {name: "assets/images/ffa-orte/Trailerpark.webp", label: "Trailerpark", index: 2},
  {name: "assets/images/ffa-orte/Schrottplatz.webp", label: "Schrottplatz", index: 3},
  {name: "assets/images/ffa-orte/Prison.png", label: "Gefängnis", index: 4}
]

async function change_ffa_map(direction) {
  const element = document.getElementById("ffa-maps");
  
  current_index = current_index += direction;

  for(picture of ffa_pics) {
    if(current_index > 4) {
      current_index = 1;
    }
    else if(current_index < 1) {
      current_index = 4;
    }

    if(picture.index === current_index) {
      element.src = picture.name
      document.getElementById("nav-selected").innerText = picture.label;
      current_map = picture.label
    }
  }

  console.log(current_map);
}

async function slideup() {
  const element = document.getElementById("container");
  element.classList.remove("slideup");
  await wait(0.2)
  element.classList.toggle("slideup");

}

async function slidedown() {
  const element = document.getElementById("container");
  element.classList.remove("slidedown");
  await wait(0.2)
  element.classList.toggle("slidedown");
}

async function triggerskull() {
  const skull = document.getElementById("skull-kill");
}

let blacklisted_words = ["nigger", "nigga", "niggers", "niger", "hitler", "adolf", "penis", "hurensohn", "nutte", "schwanz", "pedo", "milf", "hitl", "nega", "negga", "porn", "porno", "nazi", "anal", "shit", "neonazi", "huan", "huansohn", "hure"]
var characters = /^[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]*$/;

function hasSpecialChars(str) {
  const specialCharsSet = new Set('^[!@#%/^&*()_+\-=\[\]{};:"|,.<>\/?]*$');
  for (let letter of str) {
    if (specialCharsSet.has(letter)) {
      return true;
    }
  }
  return false;
}

function checkifstringhasblacklistedwords() {
  if (blacklisted_words.some(v => input_name.value.toLowerCase().includes(v))) {
    //Wenn ein blacklisted wort drinnen ist dann
  }
}

function gettime() {
  let today = new Date();
  let hours = today.getHours();
  let minutes = today.getMinutes();
  let seconds = today.getSeconds();
  let day = today.getDay() + 2;
  let month = today.getMonth() + 1;
  let year = today.getFullYear();

  if (minutes <= 9) {
    minutes = `0${minutes}`;
  }

  let current_date = `${day}.${month}.${year}`;
  let current_time = `${hours}:${minutes}`;

  document.getElementById("time").innerText = current_time;
  document.getElementById("date").innerText = current_date;
}

async function kill(killer, target) {
  await wait(0.5);
  let id = Math.random().toString(36).slice(2);

  $(".ffa-killfeed").append(`
    <div class="kill" style="display: none;" id="${id}">
      <h1>${killer}</h1>
      <p>killed</p>
      <h2>${target}</h2>
    </div>
  
  `);
  $(`#${id}`).fadeIn(200);

  setTimeout(async () => {
    const toRemove = document.getElementById(id);
    $(`#${id}`).fadeOut();
    await wait(1);
    toRemove.remove();
  }, 5000);
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
  let notify_soundin = document.getElementById(`notify-soundin-${id}`);
  let notify_soundout = document.getElementById(`notify-soundout-${id}`);
  notify_soundin.volume = 0.05;
  notify_soundout.volume = 0.01;
  notify_soundin.play();
  
  setTimeout(async () => {
    notify_soundin.pause();
    notify_soundout.play();
    const toRemove = document.getElementById(`notify-${id}`);

    toRemove.style.animation = "backOutLeft 1s forwards";
    $(`#${id}`).fadeOut();
    await wait(1);
    toRemove.remove();
  }, 5000);
}

function search_games() {
  
}


async function add_game(roomname, players, maxplayers, mode, map) {
  
  $(".founded-ffas").append(`
    <div class="ffa-found" id="${roomname}">
      <p id="ffa-found-searchname">${roomname}</p>
      <hr class="center-diamond" style="width: 50%; top: 18%;">

      <div class="middle-boxes">
        <img src="assets/images/ffa-orte/${map}.webp">

        <div class="ffa-infos">
            <h1>Players:</h1>
            <span id="ffa-infos-players">${players}/${maxplayers}</span>
            <h2>Mode:</h2>
            <span id="ffa-infos-mode">${mode}</span>
        </div>
      </div>

      <button onclick="join_game(${roomname})">BEITRETEN</button>
    </div>
  
  `);

}

function join_game(game) {
  // post an client
}

function formatNumber(num) {
  return num.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1.");
}

function test(_callback) {
  _callback();
}

async function wait(time) {
  return new Promise((resolve) => setTimeout(resolve, time * 1000));
}
