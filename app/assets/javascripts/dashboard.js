//= require application
//= require refresh
//= require twitter
//= require versionCheck
//= require projectCheck
//= require sonic

$(function() {
  VersionCheck.init();
  ProjectCheck.init();
  var projectsCount = $("body").projectsCount();
  $('.building-indicator').setSpinner(projectsCount);
});

$.fn.projectsCount = function(){
  return parseInt($(this).data("tiles-count"));
};

$.fn.setSpinner = function(projectsCount){
  var $this = $(this);

  if (projectsCount == 15) {
    // $this.spin(radius:8, length:9, width:3, lines:12, top:2, left:16});
    $this.spin({diameter: 60, lineWidth: 1.5, innerRadius: 10});
  }
  else if (projectsCount == 24) {
    $this.spin({radius:6, length:7, width:2, lines:12, top:4, left:6});
  }
  else if (projectsCount == 63) {
    $this.spin({radius:4, length:4, width:1, lines:12, top:3, left:12});
  }
  else {
    $this.spin({radius:4, length:6, width:1, lines:12, top:1, left:10});
  }
};

$.fn.spin = function(opts) {
  this.each(function() {
    var $this = $(this);
    var diameter = opts.diameter;
    var c = Math.floor(diameter/3);
    var lineWidth = opts.lineWidth;

    $this.find(".spinner").remove();

    if (opts !== false) {
      var loader =
        {

        width: diameter, //75,//* diameter
        height: diameter, //75,//*

        stepsPerFrame: 1,
        trailLength: 1,
        pointDistance: .05,

        //strokeColor: '#FF2E82',
        strokeColor: '#FF',
        fps: 20,

        setup: function() {
          this._.lineWidth = lineWidth; //2;//*
        },
        step: function(point, index) {

          var cx = c;//this.padding + Math.floor(diameter/3), //25,//*
          cy = c;//this.padding + Math.floor(diameter/3), //25,//*
          _ = this._,
          angle = (Math.PI/180) * (point.progress * 360),
          innerRadius = opts.innerRadius;//*12

          _.beginPath();
          _.moveTo(point.x, point.y);
          _.lineTo(
            (Math.cos(angle) * innerRadius) + cx,
            (Math.sin(angle) * innerRadius) + cy
          );
          _.closePath();
          _.stroke();

        },
        path: [
          ['arc', c, c, c * .8, 0, 360]//*
        ]
      };

      var d, a;


      d = document.createElement('div');
      d.className = 'spinner';

      a = new Sonic(loader);

      d.appendChild(a.canvas);
      this.appendChild(d);

      a.canvas.style.marginTop = (diameter - a.fullHeight) / 2 + 'px';//*
      a.canvas.style.marginLeft = (diameter - a.fullWidth) / 2 + 'px';//*

      a.play();
    }
  });
}
