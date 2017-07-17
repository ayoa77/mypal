angular.module('blnkk.filters', [])
	.filter('htmlToPlaintext', function() {
    return function(text) {
      return String(text).replace(/<[^>]+>/gm, '');
    }
  })
	.filter('t', function() {
    return function(text, params) {
      return I18n.t(String(text), params);
    }
  });