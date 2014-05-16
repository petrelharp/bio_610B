function adjustsvgs() {
    var objects = document.getElementsByTagName('object');
    for (var i=0;i<objects.length;i++) { 
        if (objects[i].contentDocument) {
            var svgs = objects[i].contentDocument.getElementsByTagName('svg');
            for (var j=0;j<svgs.length;j++) {
                svg = svgs[j]
                var width = svg.getAttribute('width');
                var height = svg.getAttribute('height');
                svg.removeAttribute('width');
                svg.removeAttribute('height');
                svg.setAttribute('viewBox', '0 0 ' + width + ' ' + height);
            }
        }
    }
}
window.onload = adjustsvgs
