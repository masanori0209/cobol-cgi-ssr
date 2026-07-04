(function () {
  'use strict';

  var status = document.getElementById('js-status');
  var toggle = document.getElementById('demo-toggle');
  var main = document.querySelector('main');

  if (status) {
    status.textContent = 'Client JavaScript is active (page script loaded).';
  }

  if (window.CobolSsr) {
    window.CobolSsr.log('home.js ready');
  }

  if (toggle && main) {
    toggle.addEventListener('click', function () {
      main.classList.toggle('highlight');
    });
  }
})();
