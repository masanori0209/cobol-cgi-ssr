(function () {
  'use strict';

  var rows = document.querySelectorAll('.posts-table tbody tr');
  var meta = document.getElementById('posts-meta');
  var count = rows.length;

  if (meta) {
    meta.textContent = count + ' post(s) from indexed file · click a row to select';
  }

  if (window.CobolWebfw) {
    window.CobolWebfw.log('posts.js: ' + count + ' row(s) in DOM');
  }

  if (rows.length > 0) {
    rows[0].classList.add('row-selected');
  }

  rows.forEach(function (row) {
    row.addEventListener('click', function (event) {
      if (event.target.closest('a')) {
        return;
      }
      rows.forEach(function (other) {
        if (other !== row) {
          other.classList.remove('row-selected');
        }
      });
      row.classList.toggle('row-selected');
    });
  });
})();
