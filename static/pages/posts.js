(function () {
  'use strict';

  var rows = document.querySelectorAll('.posts-table tbody tr');
  var count = rows.length;

  if (window.CobolSsr) {
    window.CobolSsr.log('posts.js: ' + count + ' row(s) in DOM');
  }

  rows.forEach(function (row) {
    row.addEventListener('click', function (event) {
      if (event.target.closest('a')) {
        return;
      }
      row.classList.toggle('row-selected');
    });
  });
})();
