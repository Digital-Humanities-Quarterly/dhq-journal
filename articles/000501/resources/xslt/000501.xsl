<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xdoc="http://www.pnp-software.com/XSLTdoc"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:dhq="http://www.digitalhumanities.org/ns/dhq"
    xmlns:cc="http://web.resource.org/cc/"
    exclude-result-prefixes="tei dhq cc xdoc" version="1.0">
    
    <xsl:import href="../../../../common/xslt/template_editorial_article.xsl"/>
    
    
    <xsl:template name="customHead">
        <xsl:call-template name="citeGameDemoHeadHooks"/>
    </xsl:template>
    
    <xsl:template name="citeGameDemoHeadHooks">
        <script src="resources/cite_game_demo/test-deps/base64-js/base64js.min.js" type="text/javascript" charset="utf-8"></script>
        <script src="resources/cite_game_demo/test-deps/jszip.min.js" type="text/javascript" charset="utf-8"></script>
        <script src="resources/cite_game_demo/test-deps/FileSaver.min.js" type="text/javascript" charset="utf-8"></script>
        
        <script src="resources/cite_game_demo/citestate.js" type="text/javascript" charset="utf-8"></script>
        <script src="resources/cite_game_demo/recorder/recorder-worker.js" type="text/javascript" charset="utf-8"></script>
        <script>
            
            function manageLoadState(stateData){
            savedState = stateData;
            }
            
            function listFilePaths(emu){
            var paths = [];
            for (var fileName in emu.extraFiles){
            paths.push(fileName);
            }
            return paths;
            }
            function insertFiles(filemap) {
            var FS = window.emu.FS;
            for(k in filemap) {
            if(filemap.hasOwnProperty(k)) {
            var targetPath = k;
            var lastSlash = k.lastIndexOf("/");
            var targetBase = (lastSlash == -1) ? "/" : k.slice(0,lastSlash+1);
            var targetName = k.slice(lastSlash+1);
            var components = targetBase.slice(0, targetBase.length-1).split("/");
            var sofar = "";
            while(components.length) {
            var here = components.shift();
            sofar += here;
            if(sofar != "" &amp;&amp; sofar != "/") {
            if(!FS.analyzePath(sofar).exists) {
            FS.mkdir(sofar);
            }
            }
            sofar += "/";
            }
            if(targetName != "") {
            FS.writeFile(k, filemap[k], {encoding:"binary"});
            }
            }
            }
            }
            
            function readState(zipBytes, andThen) {
            var zip = new JSZip();
            return zip.loadAsync(zipBytes).then(function(zip) {
            var meta = zip.file("meta.json").async("text");
            var data = zip.file("data.json").async("text");
            var heap = zip.file("heap.heap").async("uint8array");
            var promises = [meta, data, heap];
            var filenames = [];
            var fold = zip.folder("files");
            fold.forEach(function(relPath, file) {
            filenames.push(relPath);
            promises.push(file.async("uint8array"));
            });
            Promise.all(promises).then(function(proms) {
            var meta = JSON.parse(proms[0]);
            var data = JSON.parse(proms[1]);
            var heap = proms[2];
            var files = {};
            proms = proms.slice(3);
            for (var i = 0; i &lt; proms.length; i++) {
            files[filenames[i]] = proms[i];
            }
            andThen({
            state: {
            heap:heap,
            stack:data.stack,
            emtStack:data.emtStack,
            time:data.time
            },
            files: files
            })
            }, function(e) { console.error(e); });
            }, function(e) { console.error(e); });
            }
            
            var doomFileMap = {
            "DEFAULT.CFG": "resources/cite_game_demo/DOOMS/DEFAULT.CFG",
            "DM.DOC": "resources/cite_game_demo/DOOMS/DM.DOC",
            "DM.EXE": "resources/cite_game_demo/DOOMS/DM.EXE",
            "DMFAQ66A.TXT": "resources/cite_game_demo/DOOMS/DMFAQ66A.TXT",
            "DMFAQ66B.TXT": "resources/cite_game_demo/DOOMS/DMFAQ66B.TXT",
            "DMFAQ66C.TXT": "resources/cite_game_demo/DOOMS/DMFAQ66C.TXT",
            "DMFAQ66D.TXT": "resources/cite_game_demo/DOOMS/DMFAQ66D.TXT",
            "DOOM1.WAD": "resources/cite_game_demo/DOOMS/DOOM1.WAD",
            "DOOM.EXE": "resources/cite_game_demo/DOOMS/DOOM.EXE",
            "DWANGO.DOC": "resources/cite_game_demo/DOOMS/DWANGO.DOC",
            "DWANGO.EXE": "resources/cite_game_demo/DOOMS/DWANGO.EXE",
            "DWANGO.STR": "resources/cite_game_demo/DOOMS/DWANGO.STR",
            "HELPME.TXT": "resources/cite_game_demo/DOOMS/HELPME.TXT",
            "IPXSETUP.EXE": "resources/cite_game_demo/DOOMS/IPXSETUP.EXE",
            "MODEM.CFG": "resources/cite_game_demo/DOOMS/MODEM.CFG",
            "MODEM.NUM": "resources/cite_game_demo/DOOMS/MODEM.NUM",
            "MODEM.STR": "resources/cite_game_demo/DOOMS/MODEM.STR",
            "ORDER.FRM": "resources/cite_game_demo/DOOMS/ORDER.FRM",
            "README.TXT": "resources/cite_game_demo/DOOMS/README.TXT",
            "SERSETUP.EXE": "resources/cite_game_demo/DOOMS/SERSETUP.EXE",
            "SETUP.EXE": "resources/cite_game_demo/DOOMS/SETUP.EXE"
            };
            var wolfFileMap = {
            "AUDIOHED.WL1": "resources/cite_game_demo/WOLF3D/AUDIOHED.WL1",
            "AUDIOT.WL1": "resources/cite_game_demo/WOLF3D/AUDIOT.WL1",
            "CONFIG.WL1": "resources/cite_game_demo/WOLF3D/CONFIG.WL1",
            "GAMEMAPS.WL1": "resources/cite_game_demo/WOLF3D/GAMEMAPS.WL1",
            "MAPHEAD.WL1": "resources/cite_game_demo/WOLF3D/MAPHEAD.WL1",
            "VGADICT.WL1": "resources/cite_game_demo/WOLF3D/VGADICT.WL1",
            "VGAGRAPH.WL1": "resources/cite_game_demo/WOLF3D/VGAGRAPH.WL1",
            "VGAHEAD.WL1": "resources/cite_game_demo/WOLF3D/VGAHEAD.WL1",
            "VSWAP.WL1": "resources/cite_game_demo/WOLF3D/VSWAP.WL1",
            "WOLF3D.EXE": "resources/cite_game_demo/WOLF3D/WOLF3D.EXE"
            };
            var wolfExe = "WOLF3D.EXE";
            var doomExe = "DOOM.EXE";
            
            function reload(statePath, wolfOrDoomExe) {
            var req = new XMLHttpRequest();
            req.responseType = 'arraybuffer';
            req.addEventListener("load", function () {
            readState(this.response, function (state) {
            var tempFileMap = wolfOrDoomExe == "DOOM.EXE" ? doomFileMap : wolfFileMap;
            if(window.emu) {
            insertFiles(state.files);
            window.emu.loadState(state.state, function(s) {
            emu.setMuted(emu.isMuted());
            console.log("DOSbox loaded state from freeze data");
            }, function(s) {
            console.error("DOSbox error loading state");
            });
            } else {
            CiteState.cite(
            "target", function (emu) {
            window.emu = emu;
            emu.setMuted(emu.isMuted());
            reload(statePath, wolfOrDoomExe);
            },
            wolfOrDoomExe,
            null,
            state.data,
            tempFileMap,
            {mute:true, recorder:{}});
            }
            });
            });
            req.open("GET", statePath);
            req.send();
            }
            
            // Chrome audio stuttering fix, sets AudioContext directly
            // in addition to emu.setMuted() wrapper function
            function muteEmulator(isMuted){
            if(window.emu){
            if(isMuted){
            if(!emu.isMuted()){
            emu.setMuted(isMuted);
            }
            emu.getAudioCaptureInfo().context.suspend();
            }else{
            if(emu.isMuted()){
            emu.setMuted(isMuted);
            }
            emu.getAudioCaptureInfo().context.resume();
            }
            }
            }
        </script>
    </xsl:template>
    
    
    <xsl:template name="customBody">
        <xsl:call-template name="galleriaBodyHooks"/>
    </xsl:template>
    
    <xsl:template name="galleriaBodyHooks">
        <script>
           (function() { 
            	// Load the Azur theme
            	Galleria.loadTheme('/dhq/common/galleria/themes/classic/galleria.classic.min.js');
            
            // Initialize Galleria
            	Galleria.run('#galleria', { trueFullscreen: true});
            	//Galleria.run('#galleria');
	   }());
            
        </script>
    </xsl:template>

    
</xsl:stylesheet>
