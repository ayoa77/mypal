// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require angular
//= require angular-animate
//= require angular-cookies
//= require angular-ui-router
//= require angular-bootstrap
//= require angular-persona/angular-persona
//= require ng-tags-input
//= require angular-rails-templates
//= require moment
//= require moment/locale/zh-cn
//= require moment/locale/zh-tw
//= require angular-moment
//= require angular-sanitize
//= require angular-xeditable
//= require jusas-angularjs-slider
//= require showdown/dist/showdown
//= require ngInfiniteScroll
//= require websocket_rails/main
//= require notify.js/notify.js
//= require visibilityjs
//= require angular-google-analytics
//= require angular-notify
//= require angularjs-file-upload
//= require ngImgCrop
//= require readmore
//= require i18n/translations
//= require_tree .
//= require_tree ../templates

String.prototype.humanize = function () {
  if (this.length > 0) {
    return (this.charAt(0).toUpperCase() + this.slice(1)).replace(/_/g," ");
  } else {
    return this;
  }
}

String.prototype.truncate = function(length) {
  return this.length > length ? this.substring(0, length - 3) + '...' : this
};