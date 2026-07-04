/**
 * cobol-webfw client bootstrap (loaded on every page).
 */
(function () {
  'use strict';

  var path = location.pathname.replace(/\/$/, '') || '/';

  document.querySelectorAll('nav.site-nav a[href]').forEach(function (anchor) {
    var href = anchor.getAttribute('href').replace(/\/$/, '') || '/';
    if (href === path) {
      anchor.classList.add('active');
    }
  });

  document.documentElement.classList.add('js-ready');

  var footer = document.getElementById('footer-rendered-at');
  if (footer) {
    footer.textContent = 'client JS active · ' + new Date().toLocaleTimeString();
    footer.classList.remove('badge-muted');
    footer.classList.add('badge-js');
  }

  window.CobolWebfw = {
    path: path,
    log: function (message) {
      if (typeof console !== 'undefined' && console.log) {
        console.log('[cobol-webfw]', message);
      }
    }
  };
})();
