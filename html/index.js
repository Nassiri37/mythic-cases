$(function () {
  $("#container").hide();
  let items = {};              
  let rollMs = 9500;           
  let rolling = false;        

  function display(show) {
    if (show) $("#container").fadeIn(650);
    else $("#container").fadeOut(1000);
  }

 
  function randInt(min, max) {
    return Math.floor(Math.random() * (max - min)) + min;
  }

 
  function toArrayOrClean(objOrArr) {
    if (Array.isArray(objOrArr)) {
      return objOrArr.filter(e => e && typeof e.image === "string" && e.image.length > 0);
    }
    const arr = [];
    Object.keys(objOrArr || {})
      .sort((a, b) => Number(a) - Number(b))
      .forEach(k => {
        const v = objOrArr[k];
        if (v && typeof v.image === "string" && v.image.length > 0) arr.push(v);
      });
    return arr;
  }

  function goRoll(skinimg) {
    rolling = true;
    $("#cancel-button").show(); 

    $(".raffle-roller-container").css({
      transition: `all ${rollMs / 1000}s cubic-bezier(.08,.6,0,1)`
    });
    $("#CardNumber78").css({ "background-image": "url(" + skinimg + ")" });

    setTimeout(function () {
      rolling = false;
      $("#cancel-button").hide(); 
      $("#CardNumber78").addClass("winning-item");
      $.post(`https://${GetParentResourceName()}/close`, JSON.stringify({ finished: true }));
    }, rollMs + 100);

    $(".raffle-roller-container").css("margin-left", "-6770px");
  }

  function generate(selectedCase, selectedIndexZeroBased) {
    const pool = items[selectedCase] || [];
    if (!pool.length) {
      display(false);
      return;
    }

    const winner = Math.max(0, Math.min(pool.length - 1, selectedIndexZeroBased));

    $(".raffle-roller-container")
      .css({ transition: "none", "margin-left": "0px" })
      .html("");

    for (let i = 0; i < 101; i++) {
      const r = randInt(0, pool.length);
      const img = pool[r].image;
      const el = `<div id="CardNumber${i}" class="item class_red_item" style="background-image:url(${img});"></div>`;
      $(el).appendTo(".raffle-roller-container");
    }

    setTimeout(function () {
      goRoll(pool[winner].image);
    }, 500);
  }

  window.addEventListener("message", function (event) {
    const msg = event.data;

    if (msg.type === "load") {
      const incoming = msg.rewards || {};
      const normalized = {};
      Object.keys(incoming).forEach(caseName => {
        normalized[caseName] = toArrayOrClean(incoming[caseName]);
      });
      items = normalized;

    } else if (msg.type === "ui") {
      if (typeof msg.durationMs === "number" && msg.durationMs > 0) {
        rollMs = msg.durationMs;
      }
      if (msg.status) {
        generate(msg.case, (msg.selected || 1) - 1);
        display(true);
      } else {
        display(false);
        $("#cancel-button").hide();
        rolling = false;
      }
    }
  });


  document.onkeyup = function (data) {
    if (data.which == 27 && rolling) {
      rolling = false;
      $("#cancel-button").hide();
      $.post(`https://${GetParentResourceName()}/close`, JSON.stringify({ immediate: true }));
    }
  };


  $("#cancel-button").on("click", function () {
    if (rolling) {
      rolling = false;
      $("#cancel-button").hide();
      $.post(`https://${GetParentResourceName()}/close`, JSON.stringify({ immediate: true }));
    }
  });
  $("#cancel-button").hide();
});
