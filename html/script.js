window.addEventListener('message', function (event) {
  var item = event.data;

  if (item.state === 'show') {
    if (item.type === "create") {
      display()
      change_window(0)
      displaySlides(currentIndex);
      $('body').show()
    } else if (item.type === "join") {

    } else if (item.type === "search") {

      display()
      change_window(1)
      displaySlides(currentIndex);
      $('body').show()

    } else if (item.type === "leave") {

    }
  } else if (item.state === 'add') {
    if (item.type === 'search') {
      AddGameSearch(item.maxplayers, item.players, item.modus, item.map, item.name)
    }
  } else if (item.state === 'close') {
    $('body').hide()
  }
})


function AddGameSearch(MaxPlayer, Player, Modus, Map, Name) {

  $('#ffa-items').append(`
  <div class="ffa">
  <p>` + Map + `</p>
  <hr class="center-diamond">
  <img src="images/Würfelpark.webp">

  <div class="ffa-infos">
      <h1>Players:</h1>
      <span>` + Player + `/` + MaxPlayer + `</span>
      <h2>Mode:</h2>
      <span>` + Modus + `</span>
  </div>
  
  <button onclick="JoinSearchedMatch('` + Name + `')">BEITRETEN</button>
</div>
  `)
}

function JoinSearchedMatch(Name) {
  console.log("ssuo")
  $.post('https://sa_ffa/JoinSearchedMatch', JSON.stringify({ Game: Name }));
}


document.onkeyup = function(data) {
  if (data.which == 27) {
      console.log("lol")
      $.post('https://sa_ffa/exit', JSON.stringify({}));
      return
  }
};

































var currentIndex = 1;
var current_map = null;

let ffa_pics = [
  { name: "images/Würfelpark.webp", label: "Würfelpark" },
  { name: "images/Trailerpark.webp", label: "Trailerpark" },
  { name: "images/Schrottplatz.webp", label: "Schrottplatz" },
  { name: "images/Prison.png", label: "Gefängnis" }
]

$(document).ready(async function () {
  document.querySelectorAll(".ffa").forEach((element) => {
    element.getElementsByTagName("img").onclick = function (e) {
      e.style = "left: 5%;";
    };
  });
  $('body').hide()
});

var windows = ["ffa-create", "ffa-liste", "ingame", "ffa-info-card"]

function display() {
  for (screens of windows)
    if (screens !== "ffa-menu") {
      $(`.${screens}`).hide();
    }
}

function change_window(window) {
  /*   for(var i=0; i<windows.length; i++) {
    console.log(i);
  } */
  for (let i = 0; i < windows.length; i++) {
    if (i === window) {
      $(`.${windows[window]}`).fadeIn();
    }
    else {
      $(`.${window[i]}`).hide();
    }
  }
}

/* 
for(screen of windows) {
  console.log(screen);
} */


function setSlides(num) {
  displaySlides(currentIndex += num)
}
function displaySlides(num) {
  var x;
  var slides = document.getElementsByClassName("preview");
  if (num > slides.length) { currentIndex = 1 }
  if (num < 1) { currentIndex = slides.length }
  for (x = 0; x < slides.length; x++) {
    slides[x].style.display = "none";
  }

  document.getElementById("nav-selected").innerText = slides[currentIndex - 1].getAttribute("data");
  current_map = slides[currentIndex - 1].getAttribute("data");
  slides[currentIndex - 1].style.display = "block";
}

async function change_stats(name, wert) {
  if (name === "kills") {
    document.getElementById("kills").innerText = wert;
    document.getElementById("add-kills").classList.add("action");
    await wait(0.5);
    document.getElementById("add-kills").classList.remove("action");
  } else if (name === "death") {
    document.getElementById("deaths").innerText = wert;
    document.getElementById("add-death").classList.add("action");
    await wait(0.5);
    document.getElementById("add-death").classList.remove("action");
  } else if (name === "kd") {
    document.getElementById("kd").innerText = wert;
    document.getElementById("add-kd").classList.add("action");
    await wait(0.5);
    document.getElementById("add-kd").classList.remove("action");
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

  $(".kill-feed").append(`
    <div class="new-kill" id="${id}">
      <span id="killer">${killer}</span>
      <span id="target">${target}</span>
    </div>
  
  `);
  $(`#${id}`).fadeIn();

  setTimeout(async () => {
    const toRemove = document.getElementById(id);
    await wait(0.2);
    document.getElementById(id).style.animation = "delete 1s forwards";
    await wait(1);
    toRemove.remove();
  }, 5000);
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
