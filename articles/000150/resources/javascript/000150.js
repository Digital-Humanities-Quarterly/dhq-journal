function replaceText(elem, newText) {
    oldText=elem.firstChild.data;
    elem.firstChild.data=newText;
    elem.className="courier";
}

function hideContent(d) {
    if(d.length < 1) { return; }
    document.getElementById(d).style.display = "none";
}

function showContent(d) {
    if(d.length < 1) { return; }
    document.getElementById(d).style.display = "inline-block";
}