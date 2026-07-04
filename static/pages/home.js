(function () {
  'use strict';

  var status = document.getElementById('js-status');
  var pathLabel = document.getElementById('path-label');
  var toggle = document.getElementById('demo-toggle');
  var main = document.querySelector('main.page-main');

  if (status) {
    status.textContent = 'page script loaded';
    status.classList.remove('js-hint');
  }

  if (pathLabel && window.CobolWebfw) {
    pathLabel.textContent = window.CobolWebfw.path;
  }

  if (window.CobolWebfw) {
    window.CobolWebfw.log('home.js ready');
  }

  if (toggle && main) {
    toggle.addEventListener('click', function () {
      main.classList.toggle('highlight');
      toggle.textContent = main.classList.contains('highlight')
        ? 'Remove highlight'
        : 'Highlight main panel';
    });
  }
})();
