// ==UserScript==
// @name     yt-block
// @version  1.0
// @match    https://www.youtube.com/*
// ==/UserScript==

(function() {
    'use strict';

    function hideAd(element) {
        element.style.display = 'none';
    }

    function hideAds() {
        var adElements = document.querySelectorAll('.ytd-display-ad-renderer, .ytp-ad-module, .video-ads, .ytp-ads');

        for (var i = 0; i < adElements.length; i++) {
            hideAd(adElements[i]);
        }
    }

    window.addEventListener('load', hideAds);
    window.addEventListener('spfdone', hideAds);
})();
