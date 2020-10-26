(function () {
    window.CiteState = {
        scriptRoot:""
    };

    var NES = "NES";
    var SNES = "SNES";
    var DOS = "DOS";
    var N64 = "N64";

    var FCEUX = "FCEUX";
    var SNES9X = "SNES9X";
    var DOSBOX = "DOSBOX";
    var MUPEN64PLUS = "MUPEN64PLUS";

    var EmulatorNames = {};
    EmulatorNames[NES] = FCEUX;
    EmulatorNames[SNES] = SNES9X;
    EmulatorNames[DOS] = DOSBOX;
    EmulatorNames[N64] = MUPEN64PLUS;

    var LoadedEmulators = {};
    var PendingEmulators = {};

    var EmulatorInstances = {};
    EmulatorInstances[FCEUX] = [];
    EmulatorInstances[SNES9X] = [];
    EmulatorInstances[DOSBOX] = [];
    EmulatorInstances[MUPEN64PLUS] = [];

    function determineSystem(gameFile) {
        if (gameFile.match(/\.(smc|sfc)$/i)) {
            return SNES;
        } else if (gameFile.match(/\.(exe|com|bat|dos|iso)$/i)) {
            return DOS;
        } else if (gameFile.match(/\.(nes|fds)$/i)) {
            return NES;
        } else if (gameFile.match(/\.z64$/i)) {
            return N64
        }
        throw new Error("Unrecognized System");
    }

    function realCite(targetID, onLoad, system, emulator, gameFile, freezeFile, freezeData, otherFiles, options) {
        options = options || {};
        var emuModule = LoadedEmulators[emulator];
        if (!emuModule) {
            throw new Error("Emulator Not Loaded");
        }
        //todo: compile everybody with -s modularize and export name to FCEUX, SNES9X, DOSBOX.
        //todo: and be sure that gameFile, freezeFile, freezeData and extraFiles are used appropriately.
        var targetElement = document.getElementById(targetID);
				// Allow for multiple emulators to share a div and receive the same input
				if(options && !('multiple' in options)){
						targetElement.innerHTML = "";
				}else if(options && 'multiple' in options){
					if(!options.multiple)
						targetElement.innerHTML = "";
				}
        targetElement.tabIndex = 0;
        targetElement.addEventListener("click", function() {
            targetElement.focus();
        });
        var canvas = (function() {
            var canvas = document.createElement("canvas");
            // canvas.width = targetElement.clientWidth;
            // canvas.height = targetElement.clientHeight;
            canvas.style.setProperty( "width", "inherit", "important");
            canvas.style.setProperty("height", "inherit", "important");
            targetElement.appendChild(canvas);

            // As a default initial behavior, pop up an alert when webgl context is lost. To make your
            // application robust, you may want to override this behavior before shipping!
            // See http://www.khronos.org/registry/webgl/specs/latest/1.0/#5.15.2
            canvas.addEventListener("webglcontextlost", function(e) {
                alert('WebGL context lost. You will need to destroy and recreate this widget.');
                e.preventDefault();
            }, false);

            return canvas;
        })();
        var instance;
        var moduleObject = {
            locateFile: function(url) {
                return window.CiteState.scriptRoot+"emulators/"+url;
            },
            targetID:targetID,
            instanceID: window.CiteState.getNextInstanceID(),
            keyboardListeningElement:targetElement,
            system:system,
            emulator:emulator,
            gameFile:gameFile,
            freezeFile:freezeFile,
            freezeData:freezeData,
            extraFiles:otherFiles,
            preRun: [],
            postRun: [],
            print: function(m) { console.log(m); },
            printErr: function(e) { console.error(e); },
            canvas: canvas,
            options: options || {},
            usesHeapSave: false,
            emterpreted: false,
            hasFileSystem: false,
            requiresSDL2: false,
            usesWebGLContext: false,
            inputActive: true
        };
        //Emulator specific code (might make prettier later)
        if(emulator === DOSBOX){
            moduleObject.usesHeapSave = true;
            moduleObject.hasFileSystem = true;
            moduleObject.requiresSDL2 = true;
            moduleObject.emterpreted = true;
        }else if(emulator === MUPEN64PLUS){
            moduleObject.usesHeapSave = true;
            moduleObject.usesWebGLContext = true;
        }
        //Width forcing code for multiple emulations
        if(options.width && options.height){
            moduleObject.enforcedHeight = options.height+"px";
            moduleObject.enforcedWidth = options.width+"px";
        }


        moduleObject.canvas.setAttribute("id", "moduleCanvas"+moduleObject.instanceID);
        instance = emuModule(moduleObject);
        instance.postRun.unshift(function csPostRun() {
            console.log("Post Run 2");
            //Input Management
            instance.turnOffInput = function(){
                if(!instance.inputActive){
                    console.error("Can't turn off inputs that are already off for instance "+instance.instanceID);
                    return;
                }
                var target = document.getElementById(instance.targetID);
                var eventHandlers = [];
                for(var i = 0; i < instance.JSEvents.eventHandlers.length; i++){
                    if (instance.JSEvents.eventHandlers[i].target == target){
                        eventHandlers.push(instance.JSEvents.eventHandlers[i])
                    }
                }
                window.CiteState.instanceEventHandlers[instance.instanceID] = eventHandlers;
                instance.JSEvents.removeAllHandlersOnTarget(target, null);
                instance.inputActive = false;
            };
            instance.turnOnInput = function(){
                if(instance.inputActive){
                    console.error("Can't turn on inputs that are already on for instance "+instance.instanceID);
                    return;
                }
                var handlers = window.CiteState.instanceEventHandlers[instance.instanceID];
                for(var i = 0; i < handlers.length; i++){
                    instance.JSEvents.registerOrRemoveHandler(handlers[i])
                }
                window.CiteState.instanceEventHandlers[instance.instanceID] = undefined;
                instance.inputActive = true;
            };
            //Audio and Video Recording
            instance.setMuted("mute" in options ? options.mute : true);
            if(options && ("recorder" in options)) {
                Recorder.recorderRoot = window.CiteState.scriptRoot+"recorder/";
                if(!instance.getAudioCaptureInfo) {
                    throw "Can't record unless audio recording contexts are given by the emulator";
                }
                instance.startRecording = function(cb, options) {
                    if(instance.recording) {
                        console.error("Can't record two videos at once for one emulator");
                        return;
                    }
                    instance.recording = true;
                    if(!instance.audioInfo) {
                        instance.audioInfo = instance.getAudioCaptureInfo();
                    }
                    var sampleRate = instance.audioInfo.context.sampleRate;
                    var bufferSize = 16384;
                    instance.lastCapturedFrame = 0;
                    instance.audioCaptureBuffer = new Float32Array(sampleRate*2);
                    instance.audioCaptureStartSample = 0;
                    instance.audioCaptureOffset = 0;
                    if(!instance.audioCaptureNode) {
                        //FCEUX uses a mono output
                        if(emulator === FCEUX)
                            instance.audioCaptureNode = instance.audioInfo.context.createScriptProcessor(bufferSize, 1, 1);
                        else
                            instance.audioCaptureNode = instance.audioInfo.context.createScriptProcessor(bufferSize, 2, 2);
                        instance.audioCaptureNode.onaudioprocess = function(e) {
                            var input = e.inputBuffer;
                            var output = e.outputBuffer;
                            var in0 = input.getChannelData(0);
                            var out0 = output.getChannelData(0);
                            var in1, out1;
                            // todo: change this to not have onaudioprocess care about emulator specifics
                            // also does double assignment in loop below, so not too nice
                            if(emulator === FCEUX){
                                in1 = in0;
                                out1 = out0;
                            }else{
                            		in1 = input.getChannelData(1);
                            		out1 = output.getChannelData(1);
                            }
                            var capture = instance.audioCaptureBuffer;
                            var captureOffset = instance.audioCaptureOffset;
                            var sampleRate = instance.audioSampleRate;
                            //todo: is this all right? the buffers seem to be getting too big when the worker thread finally gets them...
                            if(instance.recording) {
                                for(var i = 0; i < bufferSize; i++) {
                                    out0[i] = in0[i];
                                    out1[i] = in1[i];
                                    capture[captureOffset] = in0[i];
                                    capture[captureOffset+1] = in1[i];
                                    captureOffset+=2;
                                    if(captureOffset >= sampleRate*2) {
                                        if(capture.length > sampleRate*2) {
                                            console.error("Capture too long!");
                                        }
                                        Recorder.addAudioFrame(instance.recordingID, instance.audioCaptureStartSample, capture);
                                        instance.audioCaptureStartSample += sampleRate;
                                        capture = new Float32Array(sampleRate*2);
                                        instance.audioCaptureBuffer = capture;
                                        captureOffset = 0;
                                    }
                                }
                                instance.audioCaptureOffset = captureOffset;
                            } else {
                                for(var i = 0; i < bufferSize; i++) {
                                    out0[i] = in0[i];
                                    out1[i] = in1[i];
                                }
                            }
                        }
                    };
                    //Recording options, used to lower throughput to video encoding if needed
                    var width = instance.canvas.width;
                    var height = instance.canvas.height;
                    var fps = window.CiteState.canvasCaptureFPS;
                    var br = 400000;
                    if('fps' in options && options['fps']) fps = options['fps'];
                    if('br' in options && options['br']) br = options['br'];
                    
                    Recorder.startRecording(width, height, fps, sampleRate, br, function(rid) {
                        console.log("Aud:",instance.audioInfo);
                        var audioCtx = instance.audioInfo.context;
                        var sampleRate = audioCtx.sampleRate;
                        var dest = audioCtx.destination;
                        var src = instance.audioInfo.capturedNode;
                        var captureNode = instance.audioCaptureNode;

                        instance.recordingID = rid;
                        instance.recordingStartFrame = window.CiteState.canvasCaptureCurrentFrame();

                        if(!instance.alreadyCapturesAudio) {
                            //hook up audio capture
                            try
                            {
                                src.disconnect(dest);
                            } catch (e){
                                //pass since no need to disconnect
                            }
                            src.connect(captureNode);
                            captureNode.connect(dest);
                            instance.alreadyCapturesAudio = true;
                        }
                        //hook up video capture
                        instance.captureContext = instance.canvas.getContext("2d");
                        window.CiteState.canvasCaptureOne(instance, 0);
                        window.CiteState.liveRecordings.push(instance);
                        if(!window.CiteState.canvasCaptureTimer) {
                            window.CiteState.canvasCaptureTimer = requestAnimationFrame(window.CiteState.canvasCaptureTimerFn);
                        }
                        if(cb) {
                            cb(instance.recordingID);
                        }
                    });
                };
                instance.finishRecording = function(cb) {
                    Recorder.finishRecording(instance.recordingID, cb);
                    instance.recording = false;
                    instance.recordingID = -1;
                    window.CiteState.liveRecordings.splice(window.CiteState.liveRecordings.indexOf(instance),1);
                };
                instance.recording = false;
                if(options.recorder.autoStart) {
                    instance.startRecording(null);
                }
            }
            if(onLoad) { onLoad(instance); }
        });
        EmulatorInstances[emulator].push(instance);
        return instance;
    }

    window.CiteState.createdInstances = 0;
    window.CiteState.pendingCites = [];
    window.CiteState.getNextInstanceID = function(){ return ++window.CiteState.createdInstances; };
    window.CiteState.instanceEventHandlers = [];
    window.CiteState.liveRecordings = [];
    window.CiteState.canvasCaptureTimerRunTime = 0;
    window.CiteState.canvasCaptureStartTime = 0;
    window.CiteState.canvasCaptureLastCapturedTime = 0;
    window.CiteState.canvasCaptureFPS = 30;
    window.CiteState.timeToFrame = function(timeInSeconds) {
        //seconds * (frames/second)
        return Math.floor(timeInSeconds * (window.CiteState.canvasCaptureFPS));
    };
    window.CiteState.canvasCaptureCurrentFrame = function() {
        //seconds * (frames/second)
        return window.CiteState.timeToFrame(window.CiteState.canvasCaptureLastCapturedTime);
    };
    window.CiteState.canvasCaptureOne = function(emu, frame) {
        if(frame <= emu.lastCapturedFrame) {
            console.error("Possible redundant capture ",frame);
        }
        emu.lastCapturedFrame = frame;
        // Not needed if using dosbox.conf file, need to clean this up a bit for later, also check on SNES
        // var imArray = shrinkImageData(
        //     emu.captureContext.getImageData(0,0, emu.canvas.width, emu.canvas.height).data,
        //     emu.canvas.width,
        //     emu.canvas.height
        // );
        Recorder.addVideoFrame(
            emu.recordingID,
            frame,
            emu.captureContext.getImageData(0, 0, emu.canvas.width, emu.canvas.height).data
        );
    };
    window.CiteState.canvasCaptureTimerFn = function(timestamp) {
        //convert to seconds
        timestamp = timestamp / 1000.0;
        if(window.CiteState.canvasCaptureStartTime == 0) {
            window.CiteState.canvasCaptureStartTime = timestamp;
        }
        timestamp = timestamp - window.CiteState.canvasCaptureStartTime;
        if(window.CiteState.canvasCaptureLastCapturedTime == 0) {
            window.CiteState.canvasCaptureLastCapturedTime = timestamp;
        }
        var lastFrame = window.CiteState.canvasCaptureCurrentFrame();
        var newFrame = window.CiteState.timeToFrame(timestamp);
        if(lastFrame != newFrame) {
            window.CiteState.canvasCaptureLastCapturedTime = timestamp;
            for(var i = 0; i < window.CiteState.liveRecordings.length; i++) {
                var emu = window.CiteState.liveRecordings[i];
                if(!emu.recording) { continue; }
                window.CiteState.canvasCaptureOne(emu, newFrame - emu.recordingStartFrame);
            }
        }
        window.CiteState.canvasCaptureTimer = requestAnimationFrame(window.CiteState.canvasCaptureTimerFn);
    };

    window.CiteState.canvasCaptureScreen = function(emu){
        var context, captureData;
        if(emu.usesWebGLContext){
            context = emu.canvas.getContext("webgl");
            captureData = new Uint8Array(4 * context.drawingBufferWidth * context.drawingBufferHeight); //4 bytes per pixel * width * height
            context.readPixels(0, 0, context.drawingBufferWidth, context.drawingBufferHeight, context.RGBA, context.UNSIGNED_BYTE, captureData);
        }else{
            context = emu.canvas.getContext("2d");
            captureData = context.getImageData(0, 0, emu.canvas.width, emu.canvas.height).data;
        }
        return {width: emu.canvas.width, height: emu.canvas.height, data: captureData};
    };

    //the loaded emulator instance will implement saveState(cb), saveExtraFiles(cb), and loadState(s,cb)
    window.CiteState.cite = function (targetID, onLoad, gameFile, freezeFile, freezeData, otherFiles, options) {
        var system = determineSystem(gameFile);
        var emulator = EmulatorNames[system];
        if (!(emulator in LoadedEmulators) && !(emulator in PendingEmulators)) {
            //Need to track pending to prevent multiple loads of any emulator script if initializing more than one
            PendingEmulators[emulator] = null; //this could be any type of value, just need something there
            var script = window.CiteState.scriptRoot+"emulators/" + emulator + ".js";
            //load the script on the page
            var scriptElement = document.createElement("script");
            scriptElement.src = script;
            scriptElement.onload = function () {
                delete PendingEmulators[emulator];
                LoadedEmulators[emulator] = window[emulator];
                //Run any queued cite calls
                if(window.CiteState.pendingCites.length > 0){
                    window.CiteState.pendingCites.forEach(function(args){
                        realCite.apply(null, args);
                    });
                    window.CiteState.pendingCites = [];
                }
                //Run the most recent one
                realCite(targetID, onLoad, system, emulator, gameFile, freezeFile, freezeData, otherFiles, options);
            };
            document.body.appendChild(scriptElement);
        } else if(emulator in PendingEmulators){
            //we process this list FIFO, hopefully won't matter
            //also save system and emulator args from call
            var newArgs = Array.prototype.slice.call(arguments);
            newArgs.splice(2, 0, system, emulator);
            window.CiteState.pendingCites.push(newArgs);
        }else {
            realCite(targetID, onLoad, system, emulator, gameFile, freezeFile, freezeData, otherFiles, options);
        }
    }
})();


// Function to directly linearly shrink by 4x with a naive grab of each top left pixel value
// This works because the DOS images are 640x400 scaled from 320x200, so each quad of pixels
// has an identical value
function shrinkImageData(pixelArray, w, h){
    var retArray = new Uint8ClampedArray((w >> 1) * (h >> 1) * 4); // w / 2 and h / 2
    var w4 = w << 2;
    // Do this beforehand to avoid check if zero / initial in main loop
    retArray[0] = pixelArray[0];
    retArray[1] = pixelArray[1];
    retArray[2] = pixelArray[2];
    retArray[3] = pixelArray[3];

    var retInd = 4;
    for(var i = 8, len = pixelArray.length; i < len; i+=8){ //skip every other pixel
        //investigate a way to remove this statement
        if(i % w4 == 0){    //at the beginning of a new row, skip one
            i += w4;
        }
        retArray[retInd] = pixelArray[i];
        retArray[retInd + 1] = pixelArray[i + 1];
        retArray[retInd + 2] = pixelArray[i + 2];
        retArray[retInd + 3] = pixelArray[i + 3];
        retInd += 4;
    }
    return retArray;
}


