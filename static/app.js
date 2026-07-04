/**
 * cobol-cgi-ssr client bootstrap (loaded on every page).
 */
(function () {
  'use strict';

  var path = location.pathname.replace(/\/$/, '') || '/';

  document.querySelectorAll('nav a[href]').forEach(function (anchor) {
    var href = anchor.getAttribute('href').replace(/\/$/, '') || '/';
    if (href === path) {
      anchor.classList.add('active');
    }
  });

  document.documentElement.classList.add('js-ready');

  window.CobolSsr = {
    path: path,
    log: function (message) {
      if (typeof console !== 'undefined' && console.log) {
        console.log('[cobol-ssr]', message);
      }
    }
  };
})();
