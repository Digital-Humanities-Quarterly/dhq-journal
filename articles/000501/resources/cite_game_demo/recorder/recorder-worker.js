var Recorder = {
    recorderRoot:"",
    worker:null,
    ready:false,
    nonce:0,
    pendingCalls:[],
    pendingStarts:{},
    pendingFinishes:{},
    
    dataBatch:[],
    batchedBuffers:[],
    dataBatchThreshold:60
};

Recorder.spawnRecorder = function() {
    if(Recorder.worker) { return; }
    Recorder.worker = new Worker(Recorder.recorderRoot+"recorder.js");
    Recorder.worker.onmessage = function(e) {
        var data = e.data;
        if(data.type == "ready") {
            Recorder.ready = true;
            for(var i = 0; i < Recorder.pendingCalls.length; i++) {
                Recorder.pendingCalls[i]();
            }
            Recorder.pendingCalls = [];
        } else if(data.type == "started") {
            if(data.nonce in Recorder.pendingStarts) {
                Recorder.pendingStarts[data.nonce](data.recordingID);
                delete Recorder.pendingStarts[data.nonce];
            }
        } else if(data.type == "finished") {
            if(data.recordingID in Recorder.pendingFinishes) {
                Recorder.pendingFinishes[data.recordingID](new Uint8Array(data.data));
                delete Recorder.pendingFinishes[data.recordingID];
            }
        } else if(data.type == "print") {
            console.log(data.message);
        } else if(data.type == "printErr") {
            console.error(data.message);
        }
    }
};

Recorder.startRecording = function(w,h,fps,sps,br,cb) {
    if(!Recorder.worker || !Recorder.ready) {
        Recorder.spawnRecorder();
        Recorder.pendingCalls.push(function() {
            Recorder.startRecording(w,h,fps,sps,br,cb);
        });
        return;
    }
    var nonce = Recorder.nonce++;
    Recorder.pendingStarts[nonce] = cb;
    Recorder.worker.postMessage({
        type:"start",
        width:w,
        height:h,
        fps:fps,
        sps:sps,
        br:br,
        nonce:nonce
    });
};

Recorder.addVideoFrame = function(recordingID, frame, imageData) {
    if(!Recorder.worker || !Recorder.ready) {
        console.error("Calling addVideoFrame too early");
    }
    Recorder.dataBatch.push({
        recordingID:recordingID,
        frame:frame,
        videoBuffer:imageData.buffer
    });
    Recorder.batchedBuffers.push(imageData.buffer);
    if(Recorder.dataBatch.length >= Recorder.dataBatchThreshold) {
        Recorder.flushDataBatches();
    }
};

//Note: frame must be in the samplerate timebase, i.e. number of samples since start.
Recorder.addAudioFrame = function(recordingID, frame, audioData) {
    if(!Recorder.worker || !Recorder.ready) {
        console.error("Calling addAudioFrame too early");
    }
    //don't really batch audio frames
    Recorder.worker.postMessage({
        type:"data",
        messages:[{
            recordingID:recordingID,
            frame:frame,
            audioBuffer:audioData.buffer
        }]
    }, [audioData.buffer]);
};

Recorder.flushDataBatches = function() {
    if(Recorder.dataBatch.length == 0) { return; }
    Recorder.worker.postMessage({
        type:"data",
        messages:Recorder.dataBatch
    }, Recorder.batchedBuffers);
    Recorder.dataBatch = [];
    Recorder.batchedBuffers = [];
};

Recorder.finishRecording = function(recordingID, cb) {
    if(!Recorder.worker || !Recorder.ready) {
        console.error("Calling finishRecording too early");
    }
    Recorder.flushDataBatches();
    Recorder.pendingFinishes[recordingID] = cb;
    Recorder.worker.postMessage({
        type:"finish",
        recordingID:recordingID
    });
};
