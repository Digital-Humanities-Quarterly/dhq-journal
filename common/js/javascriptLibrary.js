//Add taporware tool
function gototaporware(obj) {
    if (obj.value == 'listword') {
        window.open('http://taporware.mcmaster.ca/~taporware/htmlTools/listword.shtml?' + document.location.href);
    } else if (obj.value == 'findtext') {
        window.open('http://taporware.mcmaster.ca/~taporware/htmlTools/findtext.shtml?' + document.location.href);
    } else if (obj.value == 'colloc') {
        window.open('http://taporware.mcmaster.ca/~taporware/htmlTools/collocation.shtml?' + document.location.href);
    }
}

//Expand/Collapse Visible/Invisible DIVs for multi-language abstracts
function expandAbstract(ID) {
    document.getElementById(ID).style.display = 'block';
    document.getElementById('abstractExpander' + ID).innerHTML =
    '<a href="javascript:collapseAbstract(\'' + ID + '\')" title="Hide Abstract" class="expandCollapse"><span class="monospace">[-]</span></a>';
}
function collapseAbstract(ID) {
    document.getElementById(ID).style.display = 'none';
    lang = ID.slice(-2);
    document.getElementById('abstractExpander' + ID).innerHTML =
    '<a href="javascript:expandAbstract(\'' + ID + '\')" title="Expand" class="expandCollapse"><span class="monospace">[' + lang + ']</span></a>';
}

//Are these needed?
function expandEnglish(ID) {
    document.getElementById('EnglishAbstract' + ID).style.display = 'block';
    document.getElementById('EnglishExpander' + ID).innerHTML =
    '<a href="javascript:collapseEnglish(' + ID + ')" title="Collapse" class="expandCollapse">[-]</a>';
}
function collapseEnglish(ID) {
    document.getElementById('EnglishAbstract' + ID).style.display = 'none';
    document.getElementById('EnglishExpander' + ID).innerHTML =
    '<a href="javascript:expandEnglish(' + ID + ')" title="Expand" class="expandCollapse">[+]</a>';
}
function expandFrench(ID) {
    document.getElementById('FrenchAbstract' + ID).style.display = 'block';
    document.getElementById('FrenchExpander' + ID).innerHTML =
    '<a href="javascript:collapseFrench(' + ID + ')" title="Collapse" class="expandCollapse">[-]</a>';
}
function collapseFrench(ID) {
    document.getElementById('FrenchAbstract' + ID).style.display = 'none';
    document.getElementById('FrenchExpander' + ID).innerHTML =
    '<a href="javascript:expandFrench(' + ID + ')" title="Expand" class="expandCollapse">[+]</a>';
}

//Expand/Collapse Visible/Invisible DIVs for bios
function expandBio(ID) {
    document.getElementById('Bio' + ID).style.display = 'block';
    document.getElementById('BioExpander' + ID).innerHTML =
    '<a href="javascript:collapseBio(' + ID + ')" title="Hide Bio" class="expandCollapse">[-]</a>';
}
function collapseBio(ID) {
    document.getElementById('Bio' + ID).style.display = 'none';
    document.getElementById('BioExpander' + ID).innerHTML =
    '<a href="javascript:expandBio(' + ID + ')" title="View Bio" class="expandCollapse">[+]</a>';
}

//Replace _at_ with @, _dot_ with .
function deobfuscate(source) {
    // change _at_
    for (var i = 0; i < source.length; i++) {
        if (source.substring(i, i + 4) == '_at_') {
            source = source.substring(0, i) + '@' + source.substring(i + 4, source.length);
        }
    }
    // change _dot_
    for (var i = 0; i < source.length; i++) {
        if (source.substring(i, i + 5) == '_dot_') {
            source = source.substring(0, i) + '.' + source.substring(i + 5, source.length);
        }
    }
    return source;
}

//Replace && with +AND+, replace || with +OR+
function cleanSearch(query) {
    // change &&
    for (var i = 0; i < query.length; i++) {
        if (query.substring(i, i + 4) == ' && ') {
            query = query.substring(0, i) + '+AND+' + query.substring(i + 4, query.length);
        }
    }
    // change ||
    for (var i = 0; i < query.length; i++) {
        if (query.substring(i, i + 4) == ' || ') {
            query = query.substring(0, i) + '+OR+' + query.substring(i + 4, query.length);
        }
    }
    var newQuery = '/dhq/findIt?queryString=' + query + '+AND+idno%40type%3ADHQarticle-id';
    return newQuery;
}

//Create a more human-readable lastModified
function initArray() {
    this.length = initArray.arguments.length;
    for (var i = 0; i < this.length; i++) {
        this[i + 1] = initArray.arguments[i];
    }
}


//Remove all content in text elements with lang attributes not equal to
//  the one passed by parameter. Default at page load is 'en'.
function showLang() {
    if (localStorage.getItem('pagelang') == undefined) {
        localStorage.setItem('pagelang', 'en');
    }
    lang = localStorage.getItem('pagelang');
    
    var elems = document.querySelectorAll('.lang');
    var titles = document.getElementsByClassName('articleTitle');
    var notes = document.getElementsByClassName('noteRef');
    //Create a list of languages used
    var langs = [];
    for (j=0; j < titles.length; j++) {
        var clist = titles[j].classList;
        for (k=0; k < clist.length; k++) {
            if (clist[k].length == 2) {
                langs.push(clist[k]);
            }
        }
    }
    
    //If on this page there are none of the default lang, set defalut lang to 'en'
    if (!(lang in langs)) {
        localStorage.setItem('pagelang', 'en');
    }

    //Append list of alternate languages to title
    for (j=0; j < titles.length; j++) {
        var clist = titles[j].classList;
        
        for (k=0; k < langs.length; k++) {
            if (!clist.contains(langs[k])) {
                //var lnk = '<a href="" onclick="showlang(\'' + langs[k] + '\')" href="javascript:void(0);">' + langs[k] + '</a>';
                var lnk = "<a href=\"\" onclick=\"localStorage.setItem('pagelang', '" + langs[k] + "');\" href=\"javascript:void(0);\">" + langs[k] + "</a>";
                titles[j].innerHTML += ('<span class="monospace">[' + lnk + ']</span>');
            }
        }
    }
    note_count = 0;
    for (j=0; j < notes.length; j++) {
        if (notes[j].classList.contains(lang)) {
            note_count++;
        }
    }
    if (note_count < 1 && document.getElementById('notes')) {
        document.getElementById('notes').remove();
    }
    for (k=0; k < elems.length; k++) {
        if (!elems[k].classList.contains(lang)) {
            elems[k].remove();
        }
    }
    return false;
}

//Create image links to spawn new browser windows for full size versions
//Function taken from http://articles.sitepoint.com/article/standards-compliant-world/
function externalLinks() {   
    if (!document.getElementsByTagName) return;   
    var anchors = document.getElementsByTagName("a");   
    for (var i=0; i<anchors.length; i++) {   
        var anchor = anchors[i];   
        if (anchor.getAttribute("href") && anchor.getAttribute("rel") == "external") anchor.target = "_blank";
    }
    showLang();
}
window.onload = externalLinks;
